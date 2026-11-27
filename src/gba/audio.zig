const std = @import("std");

pub const output_sample_rate: u32 = 48_000;
pub const gba_cpu_hz: u32 = 16_777_216;
pub const cycles_per_frame: u32 = 280_896;
pub const max_frame_samples: usize = 512;
pub const max_out_stereo_i16: usize = 4096;
pub const sound_info_ident: u32 = 0x68736D53; // "Smsh"
pub const sound_info_ptr_addr: u32 = 0x0300_7FF0;
pub const target_queued_bytes: u32 = output_sample_rate * 4 * 55 / 1000; // 10,560 bytes (~55 ms)

pub const io_reg = struct {
    pub const soundcnt_l: u32 = 0x080;
    pub const soundcnt_h: u32 = 0x082;
    pub const soundcnt_x: u32 = 0x084;
    pub const fifo_a: u32 = 0x0400_00A0;
    pub const fifo_b: u32 = 0x0400_00A4;
    pub const dma1_sad: u32 = 0x0BC;
    pub const dma1_dad: u32 = 0x0C0;
    pub const dma1_cnt_h: u32 = 0x0C6;
    pub const dma2_sad: u32 = 0x0C8;
    pub const dma2_dad: u32 = 0x0CC;
    pub const dma2_cnt_h: u32 = 0x0D2;
    pub const tm0cnt_l: u32 = 0x100;
};

pub const SoundRegs = struct {
    soundcnt_h: u16 = 0,
    soundcnt_x: u16 = 0,
    tm0_reload: u16 = 0,
    dma1_sad: u32 = 0,
    dma1_dad: u32 = 0,
    dma1_cnt_h: u16 = 0,
    dma2_sad: u32 = 0,
    dma2_dad: u32 = 0,
    dma2_cnt_h: u16 = 0,
    sound_info_ident: u32 = 0,
    pcm_dma_counter: u8 = 0,
};

pub const SlotParams = struct {
    has_a: bool,
    has_b: bool,
    addr_a: u32,
    addr_b: u32,
    sample_count: usize,
    input_rate_hz: f64,
    slot_index: u32,
    period: u32,
};

fn isValidRamAddr(addr: u32) bool {
    const in_ewram = addr >= 0x0200_0000 and addr < 0x0204_0000;
    const in_iwram = addr >= 0x0300_0000 and addr < 0x0300_8000;
    return in_ewram or in_iwram;
}

/// Resolve the active m4a PCM ring-buffer slice for the current GBA frame.
pub fn activeSlotParams(regs: SoundRegs) ?SlotParams {
    if ((regs.soundcnt_x & 0x0080) == 0) return null;
    if (regs.sound_info_ident != sound_info_ident) return null;

    const period_cycles: u32 = 65536 - @as(u32, regs.tm0_reload);
    if (period_cycles < 256) return null;

    const has_a = ((regs.dma1_cnt_h & 0xB000) == 0xB000) and
        regs.dma1_dad == io_reg.fifo_a and
        isValidRamAddr(regs.dma1_sad);
    const has_b = ((regs.dma2_cnt_h & 0xB000) == 0xB000) and
        regs.dma2_dad == io_reg.fifo_b and
        isValidRamAddr(regs.dma2_sad);
    if (!has_a and !has_b) return null;

    const samples_per_frame: u32 = std.math.clamp(
        cycles_per_frame / period_cycles,
        16,
        @as(u32, @intCast(max_frame_samples)),
    );

    var period: u32 = 7;
    if (has_a and has_b and regs.dma2_sad > regs.dma1_sad) {
        const raw_period = (regs.dma2_sad - regs.dma1_sad) / samples_per_frame;
        if (raw_period >= 1 and raw_period <= 16) {
            period = raw_period;
        }
    }

    const ctr = std.math.clamp(@as(u32, regs.pcm_dma_counter), 1, period);
    const slot_index = (period + 1 - ctr) % period;
    const offset = slot_index * samples_per_frame;

    return .{
        .has_a = has_a,
        .has_b = has_b,
        .addr_a = if (has_a) regs.dma1_sad + offset else 0,
        .addr_b = if (has_b) regs.dma2_sad + offset else 0,
        .sample_count = @intCast(samples_per_frame),
        .input_rate_hz = @as(f64, @floatFromInt(gba_cpu_hz)) / @as(f64, @floatFromInt(period_cycles)),
        .slot_index = slot_index,
        .period = period,
    };
}

const BiquadCoeffs = struct {
    b0: f64,
    b1: f64,
    b2: f64,
    a1: f64,
    a2: f64,
};

fn computeButterworthLowPass(fc: f64, fs: f64) BiquadCoeffs {
    const q: f64 = @sqrt(0.5);
    const omega0 = 2.0 * std.math.pi * fc / fs;
    const cos_w0 = @cos(omega0);
    const sin_w0 = @sin(omega0);
    const alpha = sin_w0 / (2.0 * q);
    const a0 = 1.0 + alpha;
    const b1_raw = 1.0 - cos_w0;
    return .{
        .b0 = (b1_raw * 0.5) / a0,
        .b1 = b1_raw / a0,
        .b2 = (b1_raw * 0.5) / a0,
        .a1 = (-2.0 * cos_w0) / a0,
        .a2 = (1.0 - alpha) / a0,
    };
}

const lpf_coeffs: BiquadCoeffs = computeButterworthLowPass(6000.0, @floatFromInt(output_sample_rate));
const dc_alpha: f64 = 0.995;

const BiquadChannel = struct {
    z1: f64 = 0,
    z2: f64 = 0,

    fn process(self: *BiquadChannel, x: f64) f64 {
        const out = lpf_coeffs.b0 * x + self.z1;
        self.z1 = lpf_coeffs.b1 * x - lpf_coeffs.a1 * out + self.z2;
        self.z2 = lpf_coeffs.b2 * x - lpf_coeffs.a2 * out;
        return out;
    }

    fn reset(self: *BiquadChannel) void {
        self.z1 = 0;
        self.z2 = 0;
    }
};

const DcBlockerChannel = struct {
    prev_x: f64 = 0,
    prev_y: f64 = 0,

    fn process(self: *DcBlockerChannel, x: f64) f64 {
        const y = x - self.prev_x + dc_alpha * self.prev_y;
        self.prev_x = x;
        self.prev_y = y;
        return y;
    }

    fn reset(self: *DcBlockerChannel) void {
        self.prev_x = 0;
        self.prev_y = 0;
    }
};

inline fn sampleAt(hist: [3]f32, cur: []const i8, k: isize) f32 {
    if (k < 2) {
        const h_idx: usize = @intCast(std.math.clamp(k + 1, 0, 2));
        return hist[h_idx];
    }
    const c_idx: usize = @intCast(k - 2);
    if (c_idx < cur.len) return @floatFromInt(cur[c_idx]);
    return @floatFromInt(cur[cur.len - 1]);
}

inline fn catmullRom(hist: [3]f32, cur: []const i8, idx: isize, frac: f32) f32 {
    const ym1 = sampleAt(hist, cur, idx - 1);
    const y0 = sampleAt(hist, cur, idx);
    const y1 = sampleAt(hist, cur, idx + 1);
    const y2 = sampleAt(hist, cur, idx + 2);

    const a0 = -0.5 * ym1 + 1.5 * y0 - 1.5 * y1 + 0.5 * y2;
    const a1 = ym1 - 2.5 * y0 + 2.0 * y1 - 0.5 * y2;
    const a2 = -0.5 * ym1 + 0.5 * y1;
    return ((a0 * frac + a1) * frac + a2) * frac + y0;
}

fn pushTail(tail: *[3]f32, cur: []const i8) void {
    if (cur.len >= 3) {
        tail.* = .{
            @floatFromInt(cur[cur.len - 3]),
            @floatFromInt(cur[cur.len - 2]),
            @floatFromInt(cur[cur.len - 1]),
        };
    } else {
        for (cur) |s| {
            tail[0] = tail[1];
            tail[1] = tail[2];
            tail[2] = @floatFromInt(s);
        }
    }
}

/// Pure Zig GBA DirectSound A/B stereo resampler (`input_rate_hz` -> 48 kHz `i16` stereo)
/// using a 2-sample-shifted 4-tap Catmull-Rom spline, 6 kHz Butterworth LPF, DC blocker,
/// and dynamic rate control to prevent SDL buffer underruns/skips.
pub const Mixer = struct {
    muted: bool = false,
    has_history: bool = false,
    tail_a: [3]f32 = @splat(0),
    tail_b: [3]f32 = @splat(0),
    phase: f64 = 0,
    lpf_l: BiquadChannel = .{},
    lpf_r: BiquadChannel = .{},
    dc_l: DcBlockerChannel = .{},
    dc_r: DcBlockerChannel = .{},
    has_dma_counter: bool = false,
    last_dma_counter: u8 = 0,
    stale_frames: u32 = 0,

    fn resetFilterState(self: *Mixer) void {
        self.has_history = false;
        self.tail_a = @splat(0);
        self.tail_b = @splat(0);
        self.lpf_l.reset();
        self.lpf_r.reset();
        self.dc_l.reset();
        self.dc_r.reset();
    }

    pub fn toggleMute(self: *Mixer) void {
        self.muted = !self.muted;
        if (self.muted) {
            self.resetFilterState();
        }
    }

    /// Resample one GBA frame of signed 8-bit DirectSound A/B channels to stereo `i16`.
    /// `queued_bytes` feeds dynamic rate control (`target_queued_bytes`, clamped to ±1.5%).
    /// Returns the number of `i16` values written into `out_stereo_i16` (always even).
    pub fn mixFrame(
        self: *Mixer,
        regs: SoundRegs,
        input_rate_hz: f64,
        pcm_a: []const i8,
        pcm_b: []const i8,
        queued_bytes: u32,
        out_stereo_i16: []i16,
    ) usize {
        const n = @min(pcm_a.len, pcm_b.len);
        if (n == 0 or input_rate_hz <= 0 or out_stereo_i16.len < 2) return 0;

        var is_stale = false;
        if (regs.sound_info_ident == sound_info_ident) {
            if (!self.has_dma_counter) {
                self.has_dma_counter = true;
                self.last_dma_counter = regs.pcm_dma_counter;
                self.stale_frames = 0;
            } else if (regs.pcm_dma_counter == self.last_dma_counter) {
                self.stale_frames +|= 1;
                if (self.stale_frames >= 2) is_stale = true;
            } else {
                self.last_dma_counter = regs.pcm_dma_counter;
                self.stale_frames = 0;
            }
        } else {
            self.has_dma_counter = false;
            self.stale_frames = 0;
        }

        const silenced = self.muted or is_stale or ((regs.soundcnt_x & 0x0080) == 0);
        if (!silenced and !self.has_history) {
            self.tail_a = @splat(@floatFromInt(pcm_a[0]));
            self.tail_b = @splat(@floatFromInt(pcm_b[0]));
            self.has_history = true;
        }

        // Bit 2: FIFO A volume (0=50%, 1=100%); bit 3: FIFO B volume.
        const gain_a: f32 = if ((regs.soundcnt_h & 0x0004) != 0) 128.0 else 64.0;
        const gain_b: f32 = if ((regs.soundcnt_h & 0x0008) != 0) 128.0 else 64.0;

        const a_right = (regs.soundcnt_h & 0x0100) != 0;
        const a_left = (regs.soundcnt_h & 0x0200) != 0;
        const b_right = (regs.soundcnt_h & 0x1000) != 0;
        const b_left = (regs.soundcnt_h & 0x2000) != 0;

        const a_l: f32 = if (a_left) gain_a else 0.0;
        const a_r: f32 = if (a_right) gain_a else 0.0;
        const b_l: f32 = if (b_left) gain_b else 0.0;
        const b_r: f32 = if (b_right) gain_b else 0.0;

        const target_f: f64 = @floatFromInt(target_queued_bytes);
        const norm_err = (@as(f64, @floatFromInt(queued_bytes)) - target_f) / target_f;
        const rate_scale = 1.0 + std.math.clamp(0.02 * norm_err, -0.015, 0.015);
        const step = (input_rate_hz * rate_scale) / @as(f64, @floatFromInt(output_sample_rate));
        const n_f64: f64 = @floatFromInt(n);

        var out_idx: usize = 0;
        while (self.phase < n_f64 and out_idx + 1 < out_stereo_i16.len) {
            if (silenced) {
                out_stereo_i16[out_idx] = 0;
                out_stereo_i16[out_idx + 1] = 0;
            } else {
                const idx_floor: isize = @intFromFloat(@floor(self.phase));
                const frac: f32 = @floatCast(self.phase - @as(f64, @floatFromInt(idx_floor)));

                const va = catmullRom(self.tail_a, pcm_a[0..n], idx_floor, frac);
                const vb = catmullRom(self.tail_b, pcm_b[0..n], idx_floor, frac);

                const raw_l: f64 = @floatCast(va * a_l + vb * b_l);
                const raw_r: f64 = @floatCast(va * a_r + vb * b_r);

                const filt_l = self.dc_l.process(self.lpf_l.process(raw_l));
                const filt_r = self.dc_r.process(self.lpf_r.process(raw_r));

                out_stereo_i16[out_idx] = @intFromFloat(std.math.clamp(filt_l, -32767.0, 32767.0));
                out_stereo_i16[out_idx + 1] = @intFromFloat(std.math.clamp(filt_r, -32767.0, 32767.0));
            }
            out_idx += 2;
            self.phase += step;
        }

        self.phase -= n_f64;
        if (silenced) {
            self.resetFilterState();
        } else {
            pushTail(&self.tail_a, pcm_a[0..n]);
            pushTail(&self.tail_b, pcm_b[0..n]);
        }
        return out_idx;
    }
};

test "activeSlotParams matches probed Advance Wars m4a DMA ring buffers" {
    const base_regs = SoundRegs{
        .soundcnt_h = 0xA90E,
        .soundcnt_x = 0x008F,
        .tm0_reload = 0xFB1A,
        .dma1_sad = 0x0300_5540,
        .dma1_dad = io_reg.fifo_a,
        .dma1_cnt_h = 0xB600,
        .dma2_sad = 0x0300_5B70,
        .dma2_dad = io_reg.fifo_b,
        .dma2_cnt_h = 0xB600,
        .sound_info_ident = sound_info_ident,
        .pcm_dma_counter = 2,
    };

    const s2 = activeSlotParams(base_regs).?;
    try std.testing.expectEqual(@as(usize, 224), s2.sample_count);
    try std.testing.expectEqual(@as(u32, 7), s2.period);
    try std.testing.expectEqual(@as(u32, 6), s2.slot_index);
    try std.testing.expectEqual(@as(u32, 0x0300_5540 + 1344), s2.addr_a);
    try std.testing.expectEqual(@as(u32, 0x0300_5B70 + 1344), s2.addr_b);

    var r1 = base_regs;
    r1.pcm_dma_counter = 1;
    try std.testing.expectEqual(@as(u32, 0), activeSlotParams(r1).?.slot_index);

    var r7 = base_regs;
    r7.pcm_dma_counter = 7;
    try std.testing.expectEqual(@as(u32, 1), activeSlotParams(r7).?.slot_index);

    var r6 = base_regs;
    r6.pcm_dma_counter = 6;
    try std.testing.expectEqual(@as(u32, 2), activeSlotParams(r6).?.slot_index);
}

test "activeSlotParams rejects disabled sound or invalid DMA" {
    var regs = SoundRegs{
        .soundcnt_h = 0xA90E,
        .soundcnt_x = 0x0000,
        .tm0_reload = 0xFB1A,
        .dma1_sad = 0x0300_5540,
        .dma1_dad = io_reg.fifo_a,
        .dma1_cnt_h = 0xB600,
        .sound_info_ident = sound_info_ident,
        .pcm_dma_counter = 1,
    };
    try std.testing.expect(activeSlotParams(regs) == null);

    regs.soundcnt_x = 0x008F;
    regs.sound_info_ident = 0;
    try std.testing.expect(activeSlotParams(regs) == null);
}

test "Mixer resamples 224-sample stereo frame cleanly and respects mute" {
    const regs = SoundRegs{
        .soundcnt_h = 0xA90E, // A->Right (100%), B->Left (100%)
        .soundcnt_x = 0x008F,
        .tm0_reload = 0xFB1A,
    };
    var pcm_a: [224]i8 = undefined;
    var pcm_b: [224]i8 = undefined;
    var out: [max_out_stereo_i16]i16 = @splat(0);

    var mixer = Mixer{};
    var written: usize = 0;
    var sample_idx: usize = 0;
    // Run 4 continuous frames so the 38 Hz DC blocker startup transient settles cleanly.
    for (0..4) |_| {
        for (0..224) |i| {
            const theta = 2.0 * std.math.pi * 500.0 * @as(f64, @floatFromInt(sample_idx)) / 13379.0;
            pcm_a[i] = @intFromFloat(@round(60.0 * @sin(theta)));
            pcm_b[i] = @intFromFloat(@round(-40.0 * @sin(theta)));
            sample_idx += 1;
        }
        written = mixer.mixFrame(regs, 13379.0, &pcm_a, &pcm_b, target_queued_bytes, &out);
    }
    // 224 * (48000 / 13379) ~= 803.65 stereo pairs => ~1608 i16 samples.
    try std.testing.expect(written >= 1580 and written <= 1640);
    try std.testing.expectEqual(@as(usize, 0), written % 2);

    var peak_l: u32 = 0;
    var peak_r: u32 = 0;
    for (0..written / 2) |p| {
        peak_l = @max(peak_l, @abs(@as(i32, out[p * 2])));
        peak_r = @max(peak_r, @abs(@as(i32, out[p * 2 + 1])));
    }
    // 40 * 128 = 5120 on Left, 60 * 128 = 7680 on Right
    try std.testing.expect(peak_l >= 4800 and peak_l <= 5300);
    try std.testing.expect(peak_r >= 7200 and peak_r <= 7900);

    mixer.toggleMute();
    const muted_written = mixer.mixFrame(regs, 13379.0, &pcm_a, &pcm_b, target_queued_bytes, &out);
    try std.testing.expect(muted_written > 0);
    for (0..muted_written) |i| {
        try std.testing.expectEqual(@as(i16, 0), out[i]);
    }
}

test "Mixer maintains C1 continuity across frame boundaries on 440 Hz sine" {
    const regs = SoundRegs{
        .soundcnt_h = 0xA90E,
        .soundcnt_x = 0x008F,
        .tm0_reload = 0xFB1A,
    };
    const input_rate = 13379.0;
    const freq = 440.0;
    // Ideal max step per 48 kHz sample for amplitude 10240 at 440 Hz:
    // 10240 * 2 * pi * 440 / 48000 ~= 590.
    var mixer = Mixer{};
    var out: [max_out_stereo_i16]i16 = @splat(0);
    var pcm_a: [224]i8 = undefined;
    var pcm_b: [224]i8 = undefined;

    var prev_last_l: i32 = 0;
    var prev_last_r: i32 = 0;
    var max_boundary_jump: u32 = 0;
    var max_intra_jump: u32 = 0;

    var sample_idx: usize = 0;
    for (0..8) |frame| {
        for (0..224) |i| {
            const theta = 2.0 * std.math.pi * freq * @as(f64, @floatFromInt(sample_idx)) / input_rate;
            const s: i8 = @intFromFloat(@round(80.0 * @sin(theta)));
            pcm_a[i] = s;
            pcm_b[i] = s;
            sample_idx += 1;
        }
        const n = mixer.mixFrame(regs, input_rate, &pcm_a, &pcm_b, target_queued_bytes, &out);
        try std.testing.expect(n >= 1580);

        if (frame >= 2) {
            max_boundary_jump = @max(max_boundary_jump, @abs(@as(i32, out[0]) - prev_last_l));
            max_boundary_jump = @max(max_boundary_jump, @abs(@as(i32, out[1]) - prev_last_r));
        }
        var p: usize = 1;
        while (p < n / 2) : (p += 1) {
            if (frame >= 2) {
                max_intra_jump = @max(max_intra_jump, @abs(@as(i32, out[p * 2]) - @as(i32, out[(p - 1) * 2])));
                max_intra_jump = @max(max_intra_jump, @abs(@as(i32, out[p * 2 + 1]) - @as(i32, out[(p - 1) * 2 + 1])));
            }
        }
        prev_last_l = out[n - 2];
        prev_last_r = out[n - 1];
    }

    // Boundary deltas must stay smooth and close to intra-frame 440 Hz slew rate (~590).
    try std.testing.expect(max_intra_jump < 750);
    try std.testing.expect(max_boundary_jump <= max_intra_jump + 80);
}

test "Mixer low-pass attenuates Nyquist imaging noise relative to 500 Hz tone" {
    const regs = SoundRegs{
        .soundcnt_h = 0xA90E,
        .soundcnt_x = 0x008F,
        .tm0_reload = 0xFB1A,
    };
    const input_rate = 13379.0;
    var out: [max_out_stereo_i16]i16 = @splat(0);

    // Measure 500 Hz passband RMS after settling
    var m_pass = Mixer{};
    var pcm_pass: [224]i8 = undefined;
    var rms_pass_sq: f64 = 0;
    var pass_count: usize = 0;
    var idx: usize = 0;
    for (0..6) |f| {
        for (0..224) |i| {
            const theta = 2.0 * std.math.pi * 500.0 * @as(f64, @floatFromInt(idx)) / input_rate;
            pcm_pass[i] = @intFromFloat(@round(64.0 * @sin(theta)));
            idx += 1;
        }
        const n = m_pass.mixFrame(regs, input_rate, &pcm_pass, &pcm_pass, target_queued_bytes, &out);
        if (f >= 3) {
            for (0..n / 2) |p| {
                const v: f64 = @floatFromInt(out[p * 2]);
                rms_pass_sq += v * v;
                pass_count += 1;
            }
        }
    }
    const rms_pass = @sqrt(rms_pass_sq / @as(f64, @floatFromInt(pass_count)));

    // Measure alternating +64/-64 Nyquist square wave (6.69 kHz fundamental + 13.38 kHz harmonics)
    var m_nyq = Mixer{};
    var pcm_nyq: [224]i8 = undefined;
    for (0..224) |i| {
        pcm_nyq[i] = if ((i & 1) == 0) 64 else -64;
    }
    var rms_nyq_sq: f64 = 0;
    var nyq_count: usize = 0;
    for (0..6) |f| {
        const n = m_nyq.mixFrame(regs, input_rate, &pcm_nyq, &pcm_nyq, target_queued_bytes, &out);
        if (f >= 3) {
            for (0..n / 2) |p| {
                const v: f64 = @floatFromInt(out[p * 2]);
                rms_nyq_sq += v * v;
                nyq_count += 1;
            }
        }
    }
    const rms_nyq = @sqrt(rms_nyq_sq / @as(f64, @floatFromInt(nyq_count)));

    try std.testing.expect(rms_pass > 5000.0);
    // Nyquist square peak amplitude (64) is sqrt(2)*rms of 64 sine, yet after 6 kHz LPF must drop well below 500 Hz RMS.
    try std.testing.expect(rms_nyq < rms_pass * 0.65);
}

test "Mixer dynamic rate control reduces output samples when queued bytes are high" {
    const regs = SoundRegs{
        .soundcnt_h = 0xA90E,
        .soundcnt_x = 0x008F,
        .tm0_reload = 0xFB1A,
    };
    var pcm: [224]i8 = @splat(0);
    var out: [max_out_stereo_i16]i16 = @splat(0);

    var m_low = Mixer{};
    const n_low = m_low.mixFrame(regs, 13379.0, &pcm, &pcm, 0, &out);

    var m_nom = Mixer{};
    const n_nom = m_nom.mixFrame(regs, 13379.0, &pcm, &pcm, target_queued_bytes, &out);

    var m_high = Mixer{};
    const n_high = m_high.mixFrame(regs, 13379.0, &pcm, &pcm, target_queued_bytes * 2, &out);

    try std.testing.expect(n_high < n_nom);
    try std.testing.expect(n_nom < n_low);
}

test "Mixer silences audio when m4a pcm_dma_counter freezes for 2+ frames" {
    var regs = SoundRegs{
        .soundcnt_h = 0xA90E,
        .soundcnt_x = 0x008F,
        .tm0_reload = 0xFB1A,
        .sound_info_ident = sound_info_ident,
        .pcm_dma_counter = 5,
    };
    var pcm: [224]i8 = undefined;
    for (0..224) |i| {
        const theta = 2.0 * std.math.pi * 500.0 * @as(f64, @floatFromInt(i)) / 13379.0;
        pcm[i] = @intFromFloat(@round(60.0 * @sin(theta)));
    }
    var out: [max_out_stereo_i16]i16 = @splat(0);
    var mixer = Mixer{};

    // Frame 0: fresh counter=5 -> audible
    const n0 = mixer.mixFrame(regs, 13379.0, &pcm, &pcm, target_queued_bytes, &out);
    try std.testing.expect(n0 > 0);
    var any_nz0 = false;
    for (0..n0) |i| if (out[i] != 0) {
        any_nz0 = true;
        break;
    };
    try std.testing.expect(any_nz0);

    // Frame 1: stale_frames = 1 -> still tolerated
    const n1 = mixer.mixFrame(regs, 13379.0, &pcm, &pcm, target_queued_bytes, &out);
    try std.testing.expect(n1 > 0);

    // Frame 2: stale_frames = 2 -> silenced to pure zeros
    const n2 = mixer.mixFrame(regs, 13379.0, &pcm, &pcm, target_queued_bytes, &out);
    try std.testing.expect(n2 > 0);
    for (0..n2) |i| {
        try std.testing.expectEqual(@as(i16, 0), out[i]);
    }

    // Frame 3: counter advances to 4 -> audio resumes
    regs.pcm_dma_counter = 4;
    const n3 = mixer.mixFrame(regs, 13379.0, &pcm, &pcm, target_queued_bytes, &out);
    try std.testing.expect(n3 > 0);
    var any_nz3 = false;
    for (0..n3) |i| if (out[i] != 0) {
        any_nz3 = true;
        break;
    };
    try std.testing.expect(any_nz3);
}
