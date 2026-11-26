#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TK="$ROOT/ext/gbarecomp"

if [[ ! -f "$ROOT/game/aw.gba" ]]; then
    echo "error: $ROOT/game/aw.gba not found" >&2
    exit 1
fi
if [[ ! -f "$TK/CMakeLists.txt" ]]; then
    echo "error: $TK/CMakeLists.txt not found (run git submodule update --init)" >&2
    exit 1
fi

echo "[1/3] Building gbarecomp toolkit"
cmake -S "$TK" -B "$TK/build" -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build "$TK/build" --parallel

echo "[2/3] Translating game/aw.gba to C (gen/)"
mkdir -p "$ROOT/gen"
# Note: gbarecomp copies runtime sources by relative path from its cwd.
(
    cd "$TK"
    "$TK/build/gbarecomp" translate "$ROOT/game/aw.gba" -o "$ROOT/gen" --multi --entries "$ROOT/entries.txt"
)

echo "[3/3] Compiling build/AWRE"
cmake -S "$ROOT" -B "$ROOT/build" -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build "$ROOT/build" --parallel

echo "Built $ROOT/build/AWRE"
echo "--- ldd summary ---"
ldd "$ROOT/build/AWRE" | grep -E "SDL2|libm|libc" || true
