const std = @import("std");

/// ARM condition codes (bits 31..28 of ARM instructions, bits 11..8 of Thumb Format 16).
pub const ArmCondition = enum(u4) {
    eq = 0x0,
    ne = 0x1,
    cs = 0x2,
    cc = 0x3,
    mi = 0x4,
    pl = 0x5,
    vs = 0x6,
    vc = 0x7,
    hi = 0x8,
    ls = 0x9,
    ge = 0xA,
    lt = 0xB,
    gt = 0xC,
    le = 0xD,
    al = 0xE,
    nv = 0xF,
};

/// ARM barrel shifter operations.
pub const ShiftType = enum(u2) {
    lsl = 0,
    lsr = 1,
    asr = 2,
    ror = 3,
};

/// ARM7TDMI register indices (`r0..r15`).
pub const ArmRegister = enum(u4) {
    r0 = 0,
    r1 = 1,
    r2 = 2,
    r3 = 3,
    r4 = 4,
    r5 = 5,
    r6 = 6,
    r7 = 7,
    r8 = 8,
    r9 = 9,
    r10 = 10,
    r11 = 11,
    r12 = 12,
    sp = 13,
    lr = 14,
    pc = 15,
};

/// Code map classification per ROM halfword.
pub const CodeType = enum(u8) {
    unknown = 0,
    arm = 1,
    thumb = 2,
    data = 3,
};

pub const gba_rom_start: u32 = 0x0800_0000;
pub const gba_rom_end: u32 = 0x0E00_0000;
pub const gba_rom_max_size: usize = 0x0200_0000;
pub const gba_entry_point: u32 = 0x0800_0000;

pub fn condName(cond: ArmCondition) []const u8 {
    return switch (cond) {
        .eq => "EQ",
        .ne => "NE",
        .cs => "CS",
        .cc => "CC",
        .mi => "MI",
        .pl => "PL",
        .vs => "VS",
        .vc => "VC",
        .hi => "HI",
        .ls => "LS",
        .ge => "GE",
        .lt => "LT",
        .gt => "GT",
        .le => "LE",
        .al => "",
        .nv => "NV",
    };
}

pub fn regName(reg: u4) []const u8 {
    const names = [16][]const u8{
        "r0", "r1", "r2",  "r3",  "r4",  "r5", "r6", "r7",
        "r8", "r9", "r10", "r11", "r12", "sp", "lr", "pc",
    };
    return names[reg];
}

pub fn shiftName(st: ShiftType) []const u8 {
    return switch (st) {
        .lsl => "LSL",
        .lsr => "LSR",
        .asr => "ASR",
        .ror => "ROR",
    };
}
