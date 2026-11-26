#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXE="${1:-$ROOT/zig-out/bin/awre}"
ROM="${2:-$ROOT/game/aw.gba}"
OUT_BMP="${3:-$ROOT/scratch/zig_field_training.bmp}"

if [[ ! -x "$EXE" ]]; then
    echo "error: executable not found: $EXE" >&2
    exit 1
fi
if [[ ! -e "$ROM" ]]; then
    echo "error: ROM not found: $ROM" >&2
    exit 1
fi

mkdir -p "$ROOT/scratch" "$(dirname "$OUT_BMP")"
ROM_ABS="$(cd "$(dirname "$ROM")" && pwd)/$(basename "$ROM")"
TMP_ROM="$ROOT/scratch/smoke.gba"
TMP_SAV="$ROOT/scratch/smoke.sav"

cleanup() {
    rm -f "$TMP_ROM" "$TMP_SAV"
}
trap cleanup EXIT

rm -f "$TMP_ROM" "$TMP_SAV"
ln -s "$ROM_ABS" "$TMP_ROM"

cd "$ROOT"
"$EXE" "$TMP_ROM" --headless --input tools/field_training.txt --frames 8000 --log-every 0 --screenshot "$OUT_BMP"

if command -v ffmpeg >/dev/null 2>&1; then
    OUT_PNG="${OUT_BMP%.bmp}.png"
    ffmpeg -loglevel error -y -i "$OUT_BMP" "$OUT_PNG"
    echo "smoke: wrote $OUT_PNG"
else
    echo "smoke: wrote $OUT_BMP"
fi
