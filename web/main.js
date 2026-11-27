const GBA_W = 240;
const GBA_H = 160;
const PTR_CAP = 64;
const SAB_PTR_OFFSET_I32 = 16;

const PHASE_DOWN = 0;
const PHASE_MOVE = 1;
const PHASE_UP = 2;
const PHASE_RIGHT_DOWN = 3;
const PHASE_RIGHT_UP = 4;
const PHASE_SCROLL_UP = 5;
const PHASE_SCROLL_DOWN = 6;

const KEY_MAP = new Map([
  ["KeyZ", 1 << 0],       // A
  ["KeyX", 1 << 1],       // B
  ["Backspace", 1 << 2],  // Select
  ["Enter", 1 << 3],      // Start
  ["ArrowRight", 1 << 4],
  ["ArrowLeft", 1 << 5],
  ["ArrowUp", 1 << 6],
  ["ArrowDown", 1 << 7],
  ["KeyS", 1 << 8],       // R
  ["KeyA", 1 << 9],       // L
]);

const canvas = document.getElementById("screen");
const ctx = canvas.getContext("2d", { alpha: false });
const stage = document.getElementById("stage");
const dropOverlay = document.getElementById("drop-overlay");
const coepBanner = document.getElementById("coep-banner");
const statusText = document.getElementById("status-text");
const fpsText = document.getElementById("fps-text");

const romInput = document.getElementById("rom-input");
const romInputHero = document.getElementById("rom-input-hero");
const savInput = document.getElementById("sav-input");
const btnHud = document.getElementById("btn-hud");
const btnMute = document.getElementById("btn-mute");
const btnFull = document.getElementById("btn-full");
const btnExportSav = document.getElementById("btn-export-sav");
const btnStop = document.getElementById("btn-stop");

if (!window.crossOriginIsolated || typeof SharedArrayBuffer === "undefined") {
  coepBanner.hidden = false;
}

let worker = null;
let sab = null;
let sabI32 = null;
let sabF32 = null;
let currentRomKey = null;
let currentRomName = null;
let currentRomBytes = null;
let lastSaveBytes = null;
let muted = false;
let hudVisible = true;
let audioCtx = null;
let audioNode = null;
let audioInitPromise = null;
let wasmCache = null;

function setStatus(msg) {
  statusText.textContent = msg;
}

function openSaveDb() {
  return new Promise((resolve, reject) => {
    const req = indexedDB.open("awre-storage", 1);
    req.onupgradeneeded = () => {
      if (!req.result.objectStoreNames.contains("saves")) {
        req.result.createObjectStore("saves");
      }
    };
    req.onsuccess = () => resolve(req.result);
    req.onerror = () => reject(req.error);
  });
}

async function idbGetSave(key) {
  const db = await openSaveDb();
  return new Promise((resolve, reject) => {
    const tx = db.transaction("saves", "readonly");
    const req = tx.objectStore("saves").get(key);
    req.onsuccess = () => resolve(req.result ? new Uint8Array(req.result) : null);
    req.onerror = () => reject(req.error);
  });
}

async function idbPutSave(key, bytes) {
  const db = await openSaveDb();
  return new Promise((resolve, reject) => {
    const tx = db.transaction("saves", "readwrite");
    tx.objectStore("saves").put(bytes.slice().buffer, key);
    tx.oncomplete = () => resolve();
    tx.onerror = () => reject(tx.error);
  });
}

async function sha256Hex(bytes) {
  const digest = await crypto.subtle.digest("SHA-256", bytes);
  return Array.from(new Uint8Array(digest), (b) => b.toString(16).padStart(2, "0")).join("");
}

async function ensureAudio() {
  if (!audioCtx) {
    if (!audioInitPromise) {
      audioInitPromise = (async () => {
        const ac = new AudioContext({ sampleRate: 48000 });
        if (ac.state === "suspended") {
          ac.resume().catch(() => {});
        }
        await ac.audioWorklet.addModule("audio-worklet.js");
        const node = new AudioWorkletNode(ac, "awre-audio-processor", {
          numberOfInputs: 0,
          numberOfOutputs: 1,
          outputChannelCount: [2],
        });
        node.connect(ac.destination);
        node.port.onmessage = (ev) => {
          if (sabI32 && typeof ev.data === "number") {
            Atomics.store(sabI32, 4, ev.data | 0);
          }
        };
        audioCtx = ac;
        audioNode = node;
      })().catch((err) => {
        audioInitPromise = null;
        throw err;
      });
    }
    return audioInitPromise;
  }
  if (audioCtx.state === "suspended") {
    await audioCtx.resume();
  }
}

async function fetchWasmBytes() {
  if (!wasmCache) {
    const resp = await fetch("awre.wasm");
    if (!resp.ok) throw new Error(`Failed to fetch awre.wasm (${resp.status})`);
    wasmCache = await resp.arrayBuffer();
  }
  return wasmCache.slice(0);
}

function unlockAudio() {
  if (muted) return;
  if (!audioCtx) {
    ensureAudio().catch(() => {});
  } else if (audioCtx.state === "suspended") {
    audioCtx.resume().catch(() => {});
  }
}

function fitCanvas() {
  const cs = getComputedStyle(stage);
  const padX = parseFloat(cs.paddingLeft) + parseFloat(cs.paddingRight);
  const padY = parseFloat(cs.paddingTop) + parseFloat(cs.paddingBottom);
  const availW = Math.max(0, stage.clientWidth - padX);
  const availH = Math.max(0, stage.clientHeight - padY);
  let w = availW;
  let h = (w * GBA_H) / GBA_W;
  if (h > availH) {
    h = availH;
    w = (h * GBA_W) / GBA_H;
  }
  canvas.style.width = `${Math.floor(w)}px`;
  canvas.style.height = `${Math.floor(h)}px`;
}

if (typeof ResizeObserver !== "undefined") {
  new ResizeObserver(fitCanvas).observe(stage);
}
window.addEventListener("resize", fitCanvas);
document.addEventListener("fullscreenchange", fitCanvas);
fitCanvas();

function pushPointerEvent(id, phase, lx, ly) {
  if (!sabI32) return;
  const w = Atomics.load(sabI32, 5);
  const r = Atomics.load(sabI32, 6);
  if (((w - r) >>> 0) >= PTR_CAP) return;
  const slot = (w >>> 0) % PTR_CAP;
  const base = SAB_PTR_OFFSET_I32 + slot * 4;
  sabI32[base] = id | 0;
  sabI32[base + 1] = phase | 0;
  sabF32[base + 2] = lx;
  sabF32[base + 3] = ly;
  Atomics.store(sabI32, 5, (w + 1) | 0);
}

const activePointers = new Set();
let rightMouseDown = false;
let rightPointerId = null;

function releaseAllInputs() {
  if (sabI32) Atomics.store(sabI32, 0, 0);
  for (const pid of activePointers) {
    pushPointerEvent(pid, PHASE_UP, -1, -1);
  }
  activePointers.clear();
  if (rightMouseDown) {
    pushPointerEvent(-2, PHASE_RIGHT_UP, 0, 0);
    rightMouseDown = false;
  }
  rightPointerId = null;
}

function clientToLogical(ev) {
  const rect = canvas.getBoundingClientRect();
  if (rect.width <= 0 || rect.height <= 0) return { lx: 0, ly: 0 };
  return {
    lx: ((ev.clientX - rect.left) * GBA_W) / rect.width,
    ly: ((ev.clientY - rect.top) * GBA_H) / rect.height,
  };
}

function stopGame() {
  releaseAllInputs();
  if (!worker) return;
  const w = worker;
  worker = null;
  if (sabI32) {
    Atomics.store(sabI32, 1, 1);
    Atomics.store(sabI32, 7, 1);
    Atomics.notify(sabI32, 7);
  }
  btnStop.disabled = true;
  fpsText.textContent = "";
  setTimeout(() => {
    try {
      w.terminate();
    } catch (_) {}
  }, 250);
}

async function startSession({ name, key, romBytes }) {
  if (typeof SharedArrayBuffer === "undefined") {
    coepBanner.hidden = false;
    setStatus("Error: SharedArrayBuffer unavailable (serve with COOP/COEP headers)");
    return;
  }

  stopGame();
  currentRomKey = key;
  currentRomName = name;
  currentRomBytes = romBytes;

  let savBytes = null;
  try {
    savBytes = await idbGetSave(currentRomKey);
  } catch (err) {
    console.warn("IndexedDB load failed:", err);
  }
  lastSaveBytes = savBytes;

  if (!muted && (audioCtx || navigator.userActivation?.hasBeenActive)) {
    ensureAudio().catch((err) => console.warn("AudioWorklet init deferred:", err));
  }

  const wasmBytes = await fetchWasmBytes();
  sab = new SharedArrayBuffer(4096);
  sabI32 = new Int32Array(sab);
  sabF32 = new Float32Array(sab);
  if (muted) Atomics.store(sabI32, 3, 1);
  if (!hudVisible) Atomics.store(sabI32, 2, 1);

  worker = new Worker("worker.js", { type: "module" });
  const imgData = ctx.createImageData(GBA_W, GBA_H);

  worker.onmessage = async (ev) => {
    const msg = ev.data;
    if (!msg) return;
    if (msg.type === "frame") {
      imgData.data.set(msg.pixels);
      ctx.putImageData(imgData, 0, 0);
      if (msg.audio && audioNode && audioCtx && audioCtx.state === "running" && !muted) {
        audioNode.port.postMessage(msg.audio, [msg.audio.buffer]);
      }
    } else if (msg.type === "fps") {
      fpsText.textContent = `${msg.fps.toFixed(1)} FPS`;
    } else if (msg.type === "ready") {
      dropOverlay.hidden = true;
      btnStop.disabled = false;
      setStatus(`Running ${currentRomName}${lastSaveBytes ? " (save loaded)" : " (new save)"}`);
    } else if (msg.type === "needs-rom") {
      worker = null;
      btnStop.disabled = true;
      dropOverlay.hidden = false;
      setStatus("Select or drop a .gba ROM to play");
    } else if (msg.type === "save") {
      lastSaveBytes = msg.data;
      try {
        await idbPutSave(currentRomKey, msg.data);
        setStatus(`Running ${currentRomName} — Flash saved locally`);
      } catch (err) {
        setStatus(`Save error: ${err}`);
      }
    } else if (msg.type === "stopped") {
      btnStop.disabled = true;
      setStatus("Stopped");
    } else if (msg.type === "error") {
      btnStop.disabled = true;
      setStatus(`WASM error: ${msg.message}`);
      console.error(msg.message);
    }
  };

  setStatus(`Starting ${name}...`);
  const romTransfer = romBytes ? romBytes.slice() : null;
  const savTransfer = savBytes ? savBytes.slice() : null;
  const transfers = [wasmBytes];
  if (romTransfer) transfers.push(romTransfer.buffer);
  if (savTransfer) transfers.push(savTransfer.buffer);
  worker.postMessage(
    {
      type: "start",
      wasmBytes,
      romBytes: romTransfer ? romTransfer.buffer : null,
      savBytes: savTransfer ? savTransfer.buffer : null,
      sab,
    },
    transfers
  );
}

async function startRom(file) {
  const romBuf = await file.arrayBuffer();
  const romBytes = new Uint8Array(romBuf);
  const hash = await sha256Hex(romBytes);
  await startSession({
    name: file.name,
    key: `awre-save:${hash}`,
    romBytes,
  });
}

async function startEmbedded() {
  try {
    await startSession({
      name: "Advance Wars (Bundled)",
      key: "awre-save:embedded",
      romBytes: null,
    });
  } catch (err) {
    dropOverlay.hidden = false;
    setStatus(`Boot error: ${err}`);
  }
}

// Keyboard input
window.addEventListener("keydown", (ev) => {
  unlockAudio();
  if (ev.code === "F2") {
    ev.preventDefault();
    toggleHud();
    return;
  }
  if (ev.code === "F3" || ev.code === "KeyM") {
    ev.preventDefault();
    toggleMute();
    return;
  }
  if (ev.code === "F11") {
    ev.preventDefault();
    toggleFullscreen();
    return;
  }
  const bit = KEY_MAP.get(ev.code);
  if (bit && sabI32 && worker) {
    ev.preventDefault();
    Atomics.or(sabI32, 0, bit);
  }
});

window.addEventListener("keyup", (ev) => {
  const bit = KEY_MAP.get(ev.code);
  if (bit && sabI32) {
    ev.preventDefault();
    Atomics.and(sabI32, 0, ~bit);
  }
});

window.addEventListener("blur", releaseAllInputs);
document.addEventListener("visibilitychange", () => {
  if (document.hidden) releaseAllInputs();
});

// Pointer + touch + right-click (B) + scroll wheel (Up/Down)
stage.addEventListener("contextmenu", (ev) => ev.preventDefault());
window.addEventListener("contextmenu", (ev) => {
  if (rightMouseDown) ev.preventDefault();
});

function releaseRightMouse(ev) {
  if (!rightMouseDown) return;
  const { lx, ly } = clientToLogical(ev);
  pushPointerEvent(-2, PHASE_RIGHT_UP, lx, ly);
  rightMouseDown = false;
  const pid = rightPointerId;
  rightPointerId = null;
  if (pid !== null) {
    try {
      if (canvas.hasPointerCapture?.(pid)) canvas.releasePointerCapture(pid);
    } catch (_) {}
  }
}

window.addEventListener("pointerdown", unlockAudio, { capture: true });

canvas.addEventListener("pointerdown", (ev) => {
  const { lx, ly } = clientToLogical(ev);
  if (ev.button === 2) {
    ev.preventDefault();
    rightMouseDown = true;
    rightPointerId = ev.pointerId;
    try {
      canvas.setPointerCapture(ev.pointerId);
    } catch (_) {}
    pushPointerEvent(-2, PHASE_RIGHT_DOWN, lx, ly);
    return;
  }
  if (ev.pointerType === "mouse" && ev.button !== 0) return;
  activePointers.add(ev.pointerId);
  try {
    canvas.setPointerCapture(ev.pointerId);
  } catch (_) {}
  pushPointerEvent(ev.pointerId, PHASE_DOWN, lx, ly);
});

canvas.addEventListener("pointermove", (ev) => {
  if (rightMouseDown && ev.pointerType === "mouse" && (ev.buttons & 2) === 0) {
    releaseRightMouse(ev);
  }
  if (!activePointers.has(ev.pointerId)) return;
  if (ev.pointerType === "mouse" && (ev.buttons & 1) === 0) {
    activePointers.delete(ev.pointerId);
    pushPointerEvent(ev.pointerId, PHASE_UP, -1, -1);
    return;
  }
  const { lx, ly } = clientToLogical(ev);
  pushPointerEvent(ev.pointerId, PHASE_MOVE, lx, ly);
});

function handlePointerUp(ev) {
  if (ev.button === 2 || (rightPointerId !== null && ev.pointerId === rightPointerId)) {
    if (rightMouseDown || ev.target === canvas || stage.contains(ev.target)) {
      ev.preventDefault();
    }
    releaseRightMouse(ev);
    return;
  }
  if (!activePointers.delete(ev.pointerId)) return;
  const { lx, ly } = clientToLogical(ev);
  pushPointerEvent(ev.pointerId, PHASE_UP, lx, ly);
  try {
    if (canvas.hasPointerCapture?.(ev.pointerId)) canvas.releasePointerCapture(ev.pointerId);
  } catch (_) {}
}

window.addEventListener("pointerup", handlePointerUp);
window.addEventListener("pointercancel", handlePointerUp);
window.addEventListener("pointermove", (ev) => {
  if (rightMouseDown && ev.pointerType === "mouse" && (ev.buttons & 2) === 0) {
    releaseRightMouse(ev);
  }
});

canvas.addEventListener(
  "wheel",
  (ev) => {
    ev.preventDefault();
    if (ev.deltaY === 0) return;
    const { lx, ly } = clientToLogical(ev);
    pushPointerEvent(-3, ev.deltaY < 0 ? PHASE_SCROLL_UP : PHASE_SCROLL_DOWN, lx, ly);
  },
  { passive: false }
);

function toggleHud() {
  hudVisible = !hudVisible;
  btnHud.textContent = hudVisible ? "HUD" : "HUD Off";
  if (sabI32) Atomics.add(sabI32, 2, 1);
}

function toggleMute() {
  muted = !muted;
  btnMute.textContent = muted ? "Unmute" : "Mute";
  if (sabI32) Atomics.add(sabI32, 3, 1);
  if (!muted) unlockAudio();
}

function toggleFullscreen() {
  if (!document.fullscreenElement) {
    stage.requestFullscreen?.().catch(() => {});
  } else {
    document.exitFullscreen?.().catch(() => {});
  }
}

btnHud.addEventListener("click", toggleHud);
btnMute.addEventListener("click", toggleMute);
btnFull.addEventListener("click", toggleFullscreen);
btnStop.addEventListener("click", () => {
  stopGame();
  dropOverlay.hidden = false;
});

function onRomFileSelected(ev) {
  const file = ev.target.files?.[0];
  if (file) startRom(file);
  ev.target.value = "";
}

romInput.addEventListener("change", onRomFileSelected);
romInputHero.addEventListener("change", onRomFileSelected);

btnExportSav.addEventListener("click", () => {
  if (!lastSaveBytes) {
    setStatus("No Flash save data available yet");
    return;
  }
  const blob = new Blob([lastSaveBytes], { type: "application/octet-stream" });
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  const saveBase =
    currentRomKey === "awre-save:embedded"
      ? "advancewars"
      : currentRomName?.replace(/\.gba$/i, "") || "advancewars";
  a.download = `${saveBase}.sav`;
  a.click();
  setTimeout(() => URL.revokeObjectURL(a.href), 1000);
});

savInput.addEventListener("change", async (ev) => {
  const file = ev.target.files?.[0];
  ev.target.value = "";
  if (!file || !currentRomKey) {
    setStatus("Start the game first before importing a .sav");
    return;
  }
  const bytes = new Uint8Array(await file.arrayBuffer());
  await idbPutSave(currentRomKey, bytes);
  lastSaveBytes = bytes;
  await startSession({
    name: currentRomName,
    key: currentRomKey,
    romBytes: currentRomBytes,
  });
  setStatus(`Imported ${file.name} and restarted`);
});

stage.addEventListener("dragover", (ev) => {
  ev.preventDefault();
  stage.classList.add("dragover");
});

stage.addEventListener("dragleave", () => stage.classList.remove("dragover"));

stage.addEventListener("drop", (ev) => {
  ev.preventDefault();
  stage.classList.remove("dragover");
  const file = ev.dataTransfer?.files?.[0];
  if (file) startRom(file);
});

startEmbedded();
