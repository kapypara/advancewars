const FRAME_MS = 280896 / 16777.216; // ~16.742706 ms (exact GBA 59.7275 Hz)
const PTR_CAP = 64;
const SAB_PTR_OFFSET_I32 = 16;

let wasm = null;
let sabI32 = null;
let sabF32 = null;
let lastHudSeq = 0;
let lastMuteSeq = 0;
let nextFrameMs = 0;
let lastFpsMs = 0;
let fpsFrames = 0;

self.onmessage = async (ev) => {
  const msg = ev.data;
  if (!msg || msg.type !== "start") return;

  try {
    const { wasmBytes, romBytes, savBytes, sab } = msg;
    sabI32 = new Int32Array(sab);
    sabF32 = new Float32Array(sab);
    lastHudSeq = 0;
    lastMuteSeq = 0;
    nextFrameMs = performance.now() + FRAME_MS;
    lastFpsMs = performance.now();
    fpsFrames = 0;

    const imports = {
      env: {
        host_present(fbPtr, fbW, fbH, audioPtr, audioLen) {
          const memBuf = wasm.memory.buffer;
          const width = fbW >>> 0;
          const height = fbH >>> 0;
          const pixels = new Uint8ClampedArray(memBuf, fbPtr >>> 0, width * height * 4).slice();
          let audioCopy = null;
          const transfers = [pixels.buffer];
          if ((audioLen >>> 0) > 0) {
            audioCopy = new Int16Array(memBuf, audioPtr >>> 0, audioLen >>> 0).slice();
            transfers.push(audioCopy.buffer);
          }
          const packedDelta = typeof wasm.awre_cam_delta === "function" ? wasm.awre_cam_delta() >>> 0 : 0;
          const camDx = (packedDelta << 16) >> 16;
          const camDy = packedDelta >> 16;
          self.postMessage({ type: "frame", width, height, pixels, audio: audioCopy, camDx, camDy }, transfers);

          fpsFrames += 1;
          const now = performance.now();
          if (now - lastFpsMs >= 500) {
            const fps = (fpsFrames * 1000) / (now - lastFpsMs);
            self.postMessage({ type: "fps", fps });
            fpsFrames = 0;
            lastFpsMs = now;
          }
        },
        host_present_hud(ptr, w, h) {
          const memBuf = wasm.memory.buffer;
          const width = w >>> 0;
          const height = h >>> 0;
          const pixels = new Uint8ClampedArray(memBuf, ptr >>> 0, width * height * 4).slice();
          self.postMessage({ type: "hud", width, height, pixels }, [pixels.buffer]);
        },
        host_poll_input() {
          const w = Atomics.load(sabI32, 5);
          let r = Atomics.load(sabI32, 6);
          while (r !== w) {
            const slot = (r >>> 0) % PTR_CAP;
            const base = SAB_PTR_OFFSET_I32 + slot * 4;
            const id = sabI32[base];
            const phase = sabI32[base + 1];
            const lx = sabF32[base + 2];
            const ly = sabF32[base + 3];
            wasm.awre_push_pointer(id, phase >>> 0, lx, ly);
            r = (r + 1) | 0;
          }
          Atomics.store(sabI32, 6, r);

          let mask = Atomics.load(sabI32, 0) & 0x03ff;
          if (Atomics.load(sabI32, 1) !== 0) mask |= 1 << 16;

          const hudSeq = Atomics.load(sabI32, 2);
          if (hudSeq !== lastHudSeq) {
            lastHudSeq = hudSeq;
            mask |= 1 << 17;
          }
          const muteSeq = Atomics.load(sabI32, 3);
          if (muteSeq !== lastMuteSeq) {
            lastMuteSeq = muteSeq;
            mask |= 1 << 18;
          }
          mask |= 1 << 19;
          if (Atomics.load(sabI32, 8) !== 0) mask |= 1 << 20;
          mask |= (Atomics.load(sabI32, 9) & 0x03ff) << 21;
          if (Atomics.load(sabI32, 10) !== 0) mask = (mask | (1 << 31)) >>> 0;
          return mask >>> 0;
        },
        host_pace() {
          if (Atomics.load(sabI32, 1) !== 0) return;
          let now = performance.now();
          if (now < nextFrameMs) {
            const waitMs = Math.floor(nextFrameMs - now);
            if (waitMs > 0) {
              Atomics.wait(sabI32, 7, 0, waitMs);
            }
            while (performance.now() < nextFrameMs && Atomics.load(sabI32, 1) === 0) {}
            now = performance.now();
          }
          if (now > nextFrameMs + FRAME_MS * 3) {
            nextFrameMs = now + FRAME_MS;
          } else {
            nextFrameMs += FRAME_MS;
          }
        },
        host_queued_audio_bytes() {
          return Atomics.load(sabI32, 4) >>> 0;
        },
        host_save_sram(ptr, len) {
          const copy = new Uint8Array(wasm.memory.buffer, ptr >>> 0, len >>> 0).slice();
          self.postMessage({ type: "save", data: copy }, [copy.buffer]);
        },
      },
    };

    const { instance } = await WebAssembly.instantiate(wasmBytes, imports);
    wasm = instance.exports;

    const hasEmbedded = typeof wasm.awre_has_embedded_rom === "function" && wasm.awre_has_embedded_rom() === 1;
    if (!romBytes && !hasEmbedded) {
      self.postMessage({ type: "needs-rom" });
      return;
    }

    let romLen = 0;
    if (romBytes) {
      const romCap = wasm.awre_rom_buf_cap() >>> 0;
      const romU8 = new Uint8Array(romBytes);
      if (romU8.length === 0 || romU8.length > romCap) {
        throw new Error(`Invalid ROM size (${romU8.length} bytes, max ${romCap})`);
      }
      const romPtr = wasm.awre_rom_buf_ptr() >>> 0;
      new Uint8Array(wasm.memory.buffer, romPtr, romU8.length).set(romU8);
      romLen = romU8.length;
    }

    if (wasm.awre_init_wasm(romLen) !== 0) {
      throw new Error("awre_init_wasm failed");
    }

    if (savBytes && savBytes.byteLength > 0) {
      const sramSize = wasm.awre_sram_size() >>> 0;
      const sramPtr = wasm.awre_sram_buf_ptr() >>> 0;
      const src = new Uint8Array(savBytes, 0, Math.min(savBytes.byteLength, sramSize));
      new Uint8Array(wasm.memory.buffer, sramPtr, src.length).set(src);
      wasm.awre_mark_sram_clean();
    }

    self.postMessage({ type: "ready", embedded: !romBytes });
    wasm.awre_run_wasm();
    self.postMessage({ type: "stopped" });
  } catch (err) {
    self.postMessage({ type: "error", message: String(err && err.stack ? err.stack : err) });
  }
};
