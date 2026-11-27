import { createPresenter } from "./gl_presenter.js";

const GBA_W = 240;
const GBA_H = 160;
const PTR_CAP = 64;
const SAB_PTR_OFFSET_I32 = 16;
const MIN_EXT_HOLD_MS = 55;

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

const DIR_KEYS = {
  up: 1 << 6,
  down: 1 << 7,
  left: 1 << 5,
  right: 1 << 4,
};

const toolbar = document.getElementById("toolbar");
const barRestore = document.getElementById("bar-restore");
const loadRomBtn = document.getElementById("load-rom-btn");
const screenZone = document.getElementById("screen-zone");
const canvas = document.getElementById("screen");
const presenter = createPresenter(canvas);
const hudCanvas = document.getElementById("hud-canvas");
const hudCtx = hudCanvas.getContext("2d", { alpha: true });
const stage = document.getElementById("stage");
const padDeck = document.getElementById("pad-deck");
const dpadZone = document.getElementById("dpad-zone");
const dpadArms = {
  up: dpadZone.querySelector('[data-dir="up"]'),
  down: dpadZone.querySelector('[data-dir="down"]'),
  left: dpadZone.querySelector('[data-dir="left"]'),
  right: dpadZone.querySelector('[data-dir="right"]'),
};
const dropOverlay = document.getElementById("drop-overlay");
const coepBanner = document.getElementById("coep-banner");
const toastEl = document.getElementById("toast");

const romInput = document.getElementById("rom-input");
const romInputHero = document.getElementById("rom-input-hero");
const savInput = document.getElementById("sav-input");
const btnHud = document.getElementById("btn-hud");
const btnWide = document.getElementById("btn-wide");
const btnRotate = document.getElementById("btn-rotate");
const btnMute = document.getElementById("btn-mute");
const saveSlotSelect = document.getElementById("save-slot");
const btnExportSav = document.getElementById("btn-export-sav");
const btnHideBar = document.getElementById("btn-hide-bar");

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
let activeSaveSlot = (() => {
  try {
    const v = parseInt(localStorage.getItem("awre-save-slot") || "1", 10);
    return v >= 1 && v <= 3 ? v : 1;
  } catch (_) {
    return 1;
  }
})();
let rotated = (() => {
  try {
    return localStorage.getItem("awre-rotated") === "1";
  } catch (_) {
    return false;
  }
})();
let effectiveRotated = false;
let muted = false;
let widescreen = true;
let currentFrameW = GBA_W;
let hudVisible = window.matchMedia?.("(pointer: coarse)")?.matches ?? false;
let hudUserToggled = false;
let inFrameHud = false;
let hudWidth = GBA_W;
let stageWideWidth = GBA_W;
let audioCtx = null;
let audioNode = null;
let audioInitPromise = null;
let wasmCache = null;
let toastTimer = null;
let hasUploadedFrame = false;
let frameDirty = false;
let rafId = 0;

function renderFrameLoop() {
  rafId = 0;
  if (!hasUploadedFrame || !frameDirty) return;
  presenter.draw();
  frameDirty = false;
}

function schedulePresent() {
  if (!rafId && hasUploadedFrame) {
    rafId = requestAnimationFrame(renderFrameLoop);
  }
}

let kbKeyMask = 0;
let extKeyMask = 0;

function syncLiveKeys() {
  if (sabI32) Atomics.store(sabI32, 0, (kbKeyMask | extKeyMask) & 0x03ff);
}

function showToast(msg, { isError = false, durationMs = 2200 } = {}) {
  clearTimeout(toastTimer);
  toastEl.textContent = msg;
  toastEl.classList.toggle("error", isError);
  toastEl.hidden = false;
  toastEl.style.opacity = "1";
  toastTimer = setTimeout(() => {
    toastEl.style.opacity = "0";
    setTimeout(() => {
      if (toastEl.style.opacity === "0") toastEl.hidden = true;
    }, 220);
  }, durationMs);
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

function updateHudButton() {
  btnHud.textContent = hudVisible ? "HUD On" : "HUD";
  btnHud.classList.toggle("active", hudVisible);
}

function updateWideButton() {
  btnWide.textContent = widescreen ? "Wide On" : "Wide";
  btnWide.classList.toggle("active", widescreen);
}

function updateRotateButton() {
  btnRotate.textContent = rotated ? "Rot 90°" : "Rot";
  btnRotate.classList.toggle("active", rotated);
}

function activeSaveKey(baseKey) {
  if (!baseKey) return null;
  return activeSaveSlot === 1 ? baseKey : `${baseKey}:slot${activeSaveSlot}`;
}

saveSlotSelect.value = String(activeSaveSlot);

const extButtonPointers = new Map();
const latchedExtTimers = new Map();
let dpadPointerId = null;
let dpadDirMask = 0;
let dpadDownAt = 0;
let dpadLatchTimer = null;

function setDpadVisual(mask) {
  for (const [dir, el] of Object.entries(dpadArms)) {
    el.classList.toggle("pressed", (mask & DIR_KEYS[dir]) !== 0);
  }
}

function recomputeExtKeys() {
  let mask = dpadDirMask;
  for (const entry of extButtonPointers.values()) {
    mask |= entry.keyBit;
  }
  for (const bit of latchedExtTimers.keys()) {
    mask |= bit;
  }
  extKeyMask = mask & 0x03ff;
  syncLiveKeys();
}

function clearExternalPadState() {
  for (const timer of latchedExtTimers.values()) clearTimeout(timer);
  latchedExtTimers.clear();
  for (const entry of extButtonPointers.values()) {
    entry.el.classList.remove("pressed");
  }
  extButtonPointers.clear();
  if (dpadLatchTimer) {
    clearTimeout(dpadLatchTimer);
    dpadLatchTimer = null;
  }
  dpadPointerId = null;
  dpadDirMask = 0;
  setDpadVisual(0);
  recomputeExtKeys();
}

function computeHudWidthPx(availW, gameH) {
  if (availW <= 0 || gameH <= 0) return GBA_W;
  const raw = Math.floor((availW * GBA_H) / gameH);
  const clamped = Math.max(GBA_W, Math.min(512, raw));
  return clamped - (clamped % 2);
}

function fitCanvas() {
  const rawW = stage.clientWidth;
  const rawH = stage.clientHeight;
  const isRealPortrait = rawH > rawW;
  effectiveRotated = rotated && isRealPortrait;
  btnRotate.hidden = !isRealPortrait;
  document.body.classList.toggle("is-rotated", effectiveRotated);
  const isPortrait = !effectiveRotated && isRealPortrait;
  document.body.classList.toggle("is-portrait", isPortrait);

  const isPortraitHud =
    hudVisible &&
    isPortrait &&
    rawH >= (rawW * 2) / 3 + 220 &&
    rawW >= 260;

  const layoutClass = isPortraitHud ? "layout-portrait" : "layout-tight";
  stage.classList.remove("layout-portrait", "layout-tight");
  stage.classList.add(layoutClass);

  const cs = getComputedStyle(stage);
  const padX = parseFloat(cs.paddingLeft) + parseFloat(cs.paddingRight);
  const padY = parseFloat(cs.paddingTop) + parseFloat(cs.paddingBottom);
  const availW = Math.max(0, rawW - padX);
  const availH = Math.max(0, rawH - padY);
  const effW = effectiveRotated ? availH : availW;
  const effH = effectiveRotated ? availW : availH;

  let targetW = effW;
  let targetH = effH;

  if (isPortraitHud) {
    const minDeckH = 256;
    const maxDeckH = 370;
    const natGameH = Math.floor((Math.max(0, rawW - 32) * GBA_H) / GBA_W);
    const halfH = Math.round(rawH * 0.45);
    const maxZoneH = Math.max(120, rawH - minDeckH);
    const minZoneForMaxDeck = Math.max(0, rawH - maxDeckH);
    const zoneH = Math.min(Math.max(halfH, natGameH + 34, minZoneForMaxDeck), maxZoneH);
    screenZone.style.height = `${zoneH}px`;
    targetW = Math.max(0, rawW - 32);
    targetH = Math.max(0, zoneH - 34);
    padDeck.hidden = false;
    inFrameHud = false;
  } else {
    screenZone.style.height = "";
    if (!padDeck.hidden) clearExternalPadState();
    padDeck.hidden = true;
    inFrameHud = hudVisible;
  }

  const dispW =
    widescreen && !isPortraitHud && targetH > 0
      ? computeHudWidthPx(targetW, Math.floor(targetH))
      : GBA_W;

  let w = targetW;
  let h = (w * GBA_H) / dispW;
  if (h > targetH) {
    h = targetH;
    w = (h * dispW) / GBA_H;
  }
  const cw = Math.floor(Math.max(0, w));
  const ch = Math.floor(Math.max(0, h));
  canvas.style.width = `${cw}px`;
  canvas.style.height = `${ch}px`;
  presenter.resize(cw, ch, window.devicePixelRatio || 1);
  if (hasUploadedFrame) {
    frameDirty = true;
    schedulePresent();
  }

  stageWideWidth = !isPortraitHud && ch > 0 ? computeHudWidthPx(effW, ch) : GBA_W;
  hudWidth = inFrameHud && ch > 0 ? stageWideWidth : GBA_W;
  if (inFrameHud && cw > 0 && ch > 0) {
    const hudCssW = hudWidth === GBA_W ? cw : Math.round((hudWidth * ch) / GBA_H);
    hudCanvas.hidden = false;
    hudCanvas.style.width = `${hudCssW}px`;
    hudCanvas.style.height = `${ch}px`;
  } else {
    hudCanvas.hidden = true;
  }

  if (sabI32) {
    Atomics.store(sabI32, 8, inFrameHud ? 1 : 0);
    Atomics.store(sabI32, 9, (inFrameHud ? hudWidth : stageWideWidth) | 0);
    Atomics.store(sabI32, 10, widescreen ? 1 : 0);
  }
}

if (typeof ResizeObserver !== "undefined") {
  new ResizeObserver(fitCanvas).observe(stage);
}
window.addEventListener("resize", fitCanvas);
document.addEventListener("fullscreenchange", fitCanvas);
updateHudButton();
updateWideButton();
updateRotateButton();
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
  kbKeyMask = 0;
  clearExternalPadState();
  syncLiveKeys();
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
  const padL = (currentFrameW - GBA_W) * 0.5;
  const sx = (ev.clientX - rect.left) / rect.width;
  const sy = (ev.clientY - rect.top) / rect.height;
  const u = effectiveRotated ? sy : sx;
  const v = effectiveRotated ? 1 - sx : sy;
  return {
    lx: u * currentFrameW - padL,
    ly: v * GBA_H,
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
  setTimeout(() => {
    try {
      w.terminate();
    } catch (_) {}
  }, 250);
}

async function startSession({ name, key, romBytes }) {
  if (typeof SharedArrayBuffer === "undefined") {
    coepBanner.hidden = false;
    loadRomBtn.hidden = false;
    showToast("SharedArrayBuffer unavailable (serve with COOP/COEP headers)", {
      isError: true,
      durationMs: 5000,
    });
    return;
  }

  stopGame();
  currentRomKey = key;
  currentRomName = name;
  currentRomBytes = romBytes;

  let savBytes = null;
  const saveKey = activeSaveKey(currentRomKey);
  try {
    savBytes = await idbGetSave(saveKey);
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
  Atomics.store(sabI32, 8, inFrameHud ? 1 : 0);
  Atomics.store(sabI32, 9, (inFrameHud ? hudWidth : stageWideWidth) | 0);
  Atomics.store(sabI32, 10, widescreen ? 1 : 0);

  worker = new Worker("worker.js", { type: "module" });
  currentFrameW = GBA_W;
  hasUploadedFrame = false;
  frameDirty = false;
  let hudImgData = null;

  worker.onmessage = async (ev) => {
    const msg = ev.data;
    if (!msg) return;
    if (msg.type === "frame") {
      const fw = msg.width || GBA_W;
      const fh = msg.height || GBA_H;
      currentFrameW = fw;
      presenter.upload(fw, fh, msg.pixels);
      hasUploadedFrame = true;
      frameDirty = true;
      schedulePresent();
      if (msg.audio && audioNode && audioCtx && audioCtx.state === "running" && !muted) {
        audioNode.port.postMessage(msg.audio, [msg.audio.buffer]);
      }
    } else if (msg.type === "hud") {
      if (hudCanvas.width !== msg.width || hudCanvas.height !== msg.height) {
        hudCanvas.width = msg.width;
        hudCanvas.height = msg.height;
        hudImgData = null;
      }
      if (!hudImgData) {
        hudImgData = hudCtx.createImageData(msg.width, msg.height);
      }
      hudImgData.data.set(msg.pixels);
      hudCtx.putImageData(hudImgData, 0, 0);
    } else if (msg.type === "ready") {
      dropOverlay.hidden = true;
      loadRomBtn.hidden = true;
      fitCanvas();
    } else if (msg.type === "needs-rom") {
      worker = null;
      dropOverlay.hidden = false;
      loadRomBtn.hidden = false;
      showToast("Select or drop a .gba ROM to play", { durationMs: 3000 });
    } else if (msg.type === "save") {
      lastSaveBytes = msg.data;
      try {
        await idbPutSave(activeSaveKey(currentRomKey), msg.data);
        showToast(`Flash saved to Slot ${activeSaveSlot}`);
      } catch (err) {
        showToast(`Save error: ${err}`, { isError: true, durationMs: 4000 });
      }
    } else if (msg.type === "stopped") {
      worker = null;
    } else if (msg.type === "error") {
      loadRomBtn.hidden = false;
      showToast(`WASM error: ${msg.message}`, { isError: true, durationMs: 5000 });
      console.error(msg.message);
    }
  };

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
      name: "Advance Wars",
      key: "awre-save:embedded",
      romBytes: null,
    });
  } catch (err) {
    dropOverlay.hidden = false;
    loadRomBtn.hidden = false;
    showToast(`Boot error: ${err}`, { isError: true, durationMs: 4000 });
  }
}

// External outside-frame buttons & D-Pad
for (const btn of document.querySelectorAll(".pad-btn[data-key]")) {
  const keyBit = parseInt(btn.dataset.key, 10) | 0;
  btn.addEventListener("contextmenu", (ev) => ev.preventDefault());
  btn.addEventListener("pointerdown", (ev) => {
    if (ev.pointerType === "mouse" && ev.button !== 0) return;
    ev.preventDefault();
    ev.stopPropagation();
    if (latchedExtTimers.has(keyBit)) {
      clearTimeout(latchedExtTimers.get(keyBit));
      latchedExtTimers.delete(keyBit);
    }
    extButtonPointers.set(ev.pointerId, { keyBit, el: btn, downAt: performance.now() });
    btn.classList.add("pressed");
    try {
      btn.setPointerCapture(ev.pointerId);
    } catch (_) {}
    recomputeExtKeys();
  });

  function releaseExtBtn(ev) {
    const entry = extButtonPointers.get(ev.pointerId);
    if (!entry) return;
    extButtonPointers.delete(ev.pointerId);
    entry.el.classList.remove("pressed");
    const elapsed = performance.now() - entry.downAt;
    if (elapsed < MIN_EXT_HOLD_MS) {
      if (latchedExtTimers.has(entry.keyBit)) clearTimeout(latchedExtTimers.get(entry.keyBit));
      const rem = Math.ceil(MIN_EXT_HOLD_MS - elapsed);
      const t = setTimeout(() => {
        latchedExtTimers.delete(entry.keyBit);
        recomputeExtKeys();
      }, rem);
      latchedExtTimers.set(entry.keyBit, t);
    }
    recomputeExtKeys();
  }

  btn.addEventListener("pointerup", releaseExtBtn);
  btn.addEventListener("pointercancel", releaseExtBtn);
}

function evalDpadDir(ev) {
  const rect = dpadZone.getBoundingClientRect();
  if (rect.width <= 0 || rect.height <= 0) return 0;
  const dx = ev.clientX - (rect.left + rect.width * 0.5);
  const dy = ev.clientY - (rect.top + rect.height * 0.5);
  const dist = Math.hypot(dx, dy);
  if (dist < rect.width * 0.14) return 0;
  if (Math.abs(dx) >= Math.abs(dy)) {
    return dx < 0 ? DIR_KEYS.left : DIR_KEYS.right;
  }
  return dy < 0 ? DIR_KEYS.up : DIR_KEYS.down;
}

dpadZone.addEventListener("contextmenu", (ev) => ev.preventDefault());
dpadZone.addEventListener("pointerdown", (ev) => {
  if (ev.pointerType === "mouse" && ev.button !== 0) return;
  ev.preventDefault();
  ev.stopPropagation();
  if (dpadLatchTimer) {
    clearTimeout(dpadLatchTimer);
    dpadLatchTimer = null;
  }
  dpadPointerId = ev.pointerId;
  dpadDownAt = performance.now();
  dpadDirMask = evalDpadDir(ev);
  setDpadVisual(dpadDirMask);
  try {
    dpadZone.setPointerCapture(ev.pointerId);
  } catch (_) {}
  recomputeExtKeys();
});

dpadZone.addEventListener("pointermove", (ev) => {
  if (dpadPointerId !== ev.pointerId) return;
  const nextMask = evalDpadDir(ev);
  if (nextMask !== dpadDirMask) {
    dpadDirMask = nextMask;
    setDpadVisual(dpadDirMask);
    recomputeExtKeys();
  }
});

function releaseDpad(ev) {
  if (dpadPointerId !== ev.pointerId) return;
  const prevMask = dpadDirMask;
  const elapsed = performance.now() - dpadDownAt;
  dpadPointerId = null;
  if (prevMask !== 0 && elapsed < MIN_EXT_HOLD_MS) {
    dpadLatchTimer = setTimeout(() => {
      dpadLatchTimer = null;
      dpadDirMask = 0;
      setDpadVisual(0);
      recomputeExtKeys();
    }, Math.ceil(MIN_EXT_HOLD_MS - elapsed));
  } else {
    dpadDirMask = 0;
    setDpadVisual(0);
    recomputeExtKeys();
  }
}

dpadZone.addEventListener("pointerup", releaseDpad);
dpadZone.addEventListener("pointercancel", releaseDpad);

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
  if (ev.code === "F4") {
    ev.preventDefault();
    toggleWidescreen();
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
    kbKeyMask |= bit;
    syncLiveKeys();
  }
});

window.addEventListener("keyup", (ev) => {
  const bit = KEY_MAP.get(ev.code);
  if (bit) {
    ev.preventDefault();
    kbKeyMask &= ~bit;
    syncLiveKeys();
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
      if (stage.hasPointerCapture?.(pid)) stage.releasePointerCapture(pid);
    } catch (_) {}
  }
}

window.addEventListener(
  "pointerdown",
  (ev) => {
    unlockAudio();
    if (ev.pointerType === "touch" && !hudUserToggled && !hudVisible) {
      hudVisible = true;
      updateHudButton();
      fitCanvas();
    }
  },
  { capture: true }
);

stage.addEventListener("pointerdown", (ev) => {
  if (ev.target.closest("#pad-deck, #drop-overlay")) return;
  const { lx, ly } = clientToLogical(ev);
  if (ev.button === 2) {
    ev.preventDefault();
    rightMouseDown = true;
    rightPointerId = ev.pointerId;
    try {
      stage.setPointerCapture(ev.pointerId);
    } catch (_) {}
    pushPointerEvent(-2, PHASE_RIGHT_DOWN, lx, ly);
    return;
  }
  if (ev.pointerType === "mouse" && ev.button !== 0) return;
  activePointers.add(ev.pointerId);
  try {
    stage.setPointerCapture(ev.pointerId);
  } catch (_) {}
  pushPointerEvent(ev.pointerId, PHASE_DOWN, lx, ly);
});

stage.addEventListener("pointermove", (ev) => {
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
    if (rightMouseDown || ev.target === stage || stage.contains(ev.target)) {
      ev.preventDefault();
    }
    releaseRightMouse(ev);
    return;
  }
  if (!activePointers.delete(ev.pointerId)) return;
  const { lx, ly } = clientToLogical(ev);
  pushPointerEvent(ev.pointerId, PHASE_UP, lx, ly);
  try {
    if (stage.hasPointerCapture?.(ev.pointerId)) stage.releasePointerCapture(ev.pointerId);
  } catch (_) {}
}

window.addEventListener("pointerup", handlePointerUp);
window.addEventListener("pointercancel", handlePointerUp);
window.addEventListener("pointermove", (ev) => {
  if (rightMouseDown && ev.pointerType === "mouse" && (ev.buttons & 2) === 0) {
    releaseRightMouse(ev);
  }
});

stage.addEventListener(
  "wheel",
  (ev) => {
    if (ev.target.closest("#pad-deck, #drop-overlay")) return;
    ev.preventDefault();
    if (ev.deltaY === 0) return;
    const { lx, ly } = clientToLogical(ev);
    pushPointerEvent(-3, ev.deltaY < 0 ? PHASE_SCROLL_UP : PHASE_SCROLL_DOWN, lx, ly);
  },
  { passive: false }
);

function toggleHud() {
  hudVisible = !hudVisible;
  hudUserToggled = true;
  updateHudButton();
  fitCanvas();
}

function toggleWidescreen() {
  widescreen = !widescreen;
  updateWideButton();
  fitCanvas();
}

function toggleRotate() {
  releaseAllInputs();
  rotated = !rotated;
  try {
    localStorage.setItem("awre-rotated", rotated ? "1" : "0");
  } catch (_) {}
  updateRotateButton();
  fitCanvas();
}

function toggleMute() {
  muted = !muted;
  btnMute.textContent = muted ? "Unmute" : "Mute";
  btnMute.classList.toggle("active", muted);
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
btnWide.addEventListener("click", toggleWidescreen);
btnRotate.addEventListener("click", toggleRotate);
btnMute.addEventListener("click", toggleMute);
saveSlotSelect.addEventListener("change", async () => {
  const next = parseInt(saveSlotSelect.value, 10);
  if (!(next >= 1 && next <= 3) || next === activeSaveSlot) return;
  activeSaveSlot = next;
  try {
    localStorage.setItem("awre-save-slot", String(activeSaveSlot));
  } catch (_) {}
  if (currentRomKey) {
    await startSession({
      name: currentRomName,
      key: currentRomKey,
      romBytes: currentRomBytes,
    });
  }
  showToast(`Switched to Save Slot ${activeSaveSlot}`);
});
btnHideBar.addEventListener("click", () => {
  toolbar.hidden = true;
  barRestore.hidden = false;
  fitCanvas();
});
barRestore.addEventListener("click", () => {
  toolbar.hidden = false;
  barRestore.hidden = true;
  fitCanvas();
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
    showToast("No Flash save data available yet");
    return;
  }
  const blob = new Blob([lastSaveBytes], { type: "application/octet-stream" });
  const a = document.createElement("a");
  a.href = URL.createObjectURL(blob);
  const saveBase =
    currentRomKey === "awre-save:embedded"
      ? "advancewars"
      : currentRomName?.replace(/\.gba$/i, "") || "advancewars";
  const slotSuffix = activeSaveSlot > 1 ? `_slot${activeSaveSlot}` : "";
  a.download = `${saveBase}${slotSuffix}.sav`;
  a.click();
  setTimeout(() => URL.revokeObjectURL(a.href), 1000);
  showToast(`Exported ${a.download}`);
});

savInput.addEventListener("change", async (ev) => {
  const file = ev.target.files?.[0];
  ev.target.value = "";
  if (!file || !currentRomKey) {
    showToast("Load a ROM before importing a .sav");
    return;
  }
  const bytes = new Uint8Array(await file.arrayBuffer());
  await idbPutSave(activeSaveKey(currentRomKey), bytes);
  lastSaveBytes = bytes;
  await startSession({
    name: currentRomName,
    key: currentRomKey,
    romBytes: currentRomBytes,
  });
  showToast(`Imported ${file.name} into Slot ${activeSaveSlot}`);
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
