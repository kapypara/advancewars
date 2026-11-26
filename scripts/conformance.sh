#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXE="${1:-$ROOT/zig-out/bin/awre}"
ROM="${2:-$ROOT/game/aw.gba}"

if [[ ! -e "$EXE" ]]; then
    echo "conformance: skipped -- needs the build at $EXE"
    exit 0
fi
if [[ ! -e "$ROM" ]]; then
    echo "conformance: skipped -- needs the ROM at $ROM"
    exit 0
fi

mkdir -p "$ROOT/scratch"
ROM_ABS="$(cd "$(dirname "$ROM")" && pwd)/$(basename "$ROM")"
TMP_ROM="$ROOT/scratch/conformance.gba"
TMP_SAV="$ROOT/scratch/conformance.sav"

cleanup() {
    rm -f "$TMP_ROM" "$TMP_SAV"
}
trap cleanup EXIT

rm -f "$TMP_ROM" "$TMP_SAV"
ln -s "$ROM_ABS" "$TMP_ROM"

cd "$ROOT"
python3 ext/gbarecomp/tools/conformance.py \
    --exe "$EXE" \
    --rom "$TMP_ROM" \
    --baseline conformance_baseline.txt \
    --input tools/title.txt \
    --frames 760
