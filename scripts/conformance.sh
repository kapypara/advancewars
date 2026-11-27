#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXE="${1:-$ROOT/zig-out/bin/awre}"
ROM="${2:-$ROOT/game/aw.gba}"
BASELINE="$ROOT/conformance_baseline.txt"
LOG="$ROOT/scratch/conformance.log"

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
rc=0
GBA_VALIDATE=3 timeout 1800 "$EXE" "$TMP_ROM" --headless --frames 760 --log-every 0 --input "$ROOT/replays/title.txt" >"$LOG" 2>&1 || rc=$?
if [[ $rc -eq 124 ]]; then
    echo "conformance: FAIL -- run timed out"
    exit 1
fi

summary="$(grep -oE 'validate: [0-9]+/[0-9]+ functions agree' "$LOG" | head -n 1 || true)"
if [[ $rc -ne 0 || -z "$summary" ]]; then
    echo "conformance: FAIL -- run exited $rc without a result (see scratch/conformance.log)"
    exit 1
fi

counts="${summary#validate: }"
counts="${counts% functions agree}"
passed="${counts%/*}"
total="${counts#*/}"

echo "conformance: ${passed}/${total} functions agree (details: scratch/conformance.log)"
grep '^VALIDATE ' "$LOG" | sed 's/^/  /' || true

failed=$((total - passed))
if [[ -f "$BASELINE" ]]; then
    read -r base_passed base_total < "$BASELINE" || true
    base_failed=0
    if [[ -n "${base_total:-}" && -n "${base_passed:-}" ]]; then
        base_failed=$((base_total - base_passed))
    fi
    if [[ $failed -gt $base_failed ]]; then
        echo "REGRESSION: ${failed} failing > baseline ${base_failed}"
        exit 1
    fi
fi
