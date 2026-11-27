# Frame & State Debugging Dump Mode

Use `--dump-dir <dir>` to continuously record every rendered frame alongside the full GBA hardware and CPU state for deterministic reproduction of visual, input, or timing edge cases.

## Usage

**Live play (SDL2 window):**

```bash
cd /home/moon/Projects/zig/advancewars && rm -rf scratch/edge_dump && ./zig-out/bin/awre game/aw.gba --dump-dir scratch/edge_dump
```

**Headless script capture:**

```bash
./zig-out/bin/awre game/aw.gba --headless --input replays/field_training.txt --frames 300 --dump-dir scratch/edge_dump
```

- The target directory `<dir>` is created automatically (single directory level; e.g. place under gitignored `scratch/`).
- Progress prints `[dump-dir] frame N` every 60 frames and `[dump-dir] saved N frames in <dir>` on shutdown.
- **Storage note:** each frame writes `~537 KB` (`~32 MB/s` at 60 FPS), so close the emulator once you hit the issue you want to inspect.

## Output Files

Every frame `N` writes three artifacts indexed by 6-digit zero-padded frame number:

1. **`fNNNNNN.bmp`** (`153,654` bytes)
   - Top-down 32-bit BGRA `240x160` framebuffer (`54`-byte BMP header + raw pixels).
   - In live mode, captures `s_present_buf` including any rendered touch overlay; in headless mode, captures the raw Zig PPU framebuffer.
2. **`fNNNNNN.bin`** (`396,288` bytes / `0x60C00` bytes)
   - Complete GBA memory snapshot dumped at VBlank:
     - `0x00000..0x40000` — EWRAM (256 KB)
     - `0x40000..0x48000` — IWRAM (32 KB)
     - `0x48000..0x48400` — I/O registers (`0x04000000..0x040003FF`, 1 KB)
     - `0x48400..0x48800` — Palette RAM (1 KB)
     - `0x48800..0x60800` — VRAM (96 KB)
     - `0x60800..0x60C00` — OAM (1 KB)
3. **`frames.log`** (flushed after every frame)
   - One line per frame with LCD control/blend/window registers, input masks, Advance Wars cursor/scroll state, and CPU registers:
     ```text
     f=000931 DISPCNT=0x0F40 BLDCNT=0x0000 BLDALPHA=0x0000 BLDY=0x0000 WIN=0x0000/0x003F keyin=0x03FF live=0x0000 touch=0x0000 map=0 dlg=0 cur=(0,0) scroll=(295,217) sp=0x03007BE0 lr=0x08038819 pc=0x08038815 r0=0x00000000 r1=0x0000000F nzcv=1000
     ```

## Deterministic Headless Replay from `frames.log`

Extract button transitions (`keyin` is active-low) and replay headlessly in Podman Compose using a temporary symlink + copy of `game/aw.sav` (keeping `game/aw.sav` untouched):

```bash
python3 - << 'PY' > /tmp/replay_inputs.txt
import re
prev = 0
for line in open("scratch/edge_dump/frames.log"):
    m = re.search(r"f=(\d+).*keyin=0x([0-9A-Fa-f]+)", line)
    if not m:
        continue
    f = int(m.group(1))
    pressed = (~int(m.group(2), 16)) & 0x3FF
    if pressed != prev:
        print(f"{max(0, f - 1)} {pressed:03X}")
        prev = pressed
PY
```

Then run headless against the symlinked ROM (`--frames`, `--screenshot`, `--dump-at`).

## Related Diagnostic Flags & Environment Variables

| Option / Env Var | Purpose |
| :--- | :--- |
| `--dump-at <frame> <path>` | Save up to `16` targeted `.bin` memory snapshots at specific frames (takes precedence over `--dump-dir` on those frames) |
| `--screenshot <path>` | Write a single `240x160` `.bmp` at `--frames` (or on shutdown) |
| `--record <mp4>` | Pipe `240x160` frames to `ffmpeg` (nearest-neighbor scaled MP4) |
| `GBA_WATCH=<hex_addr>` | Log every bus write hitting the 32-bit aligned word at `<hex_addr>` with frame, value, caller `func_*`, `r14`, and `[irq]` |
| `GBA_FUNC_TRACE_AT=<n1,n2>` | Print call-count histogram of ROM functions entered on the specified frame(s) |
| `GBA_TRACE_INTERP=<N>` | Log the first `N` entries into the EWRAM/IWRAM ARM/Thumb interpreter |
