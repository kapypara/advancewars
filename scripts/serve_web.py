#!/usr/bin/env python3
"""Static HTTP server for zig-out/web/ with COOP/COEP headers for SharedArrayBuffer."""
import http.server
import os
import sys


ROOT = os.path.abspath(
    sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(__file__), "..", "zig-out", "web")
)
PORT = int(sys.argv[2]) if len(sys.argv) > 2 else 8080


class CoepHandler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=ROOT, **kwargs)

    def end_headers(self):
        self.send_header("Cross-Origin-Opener-Policy", "same-origin")
        self.send_header("Cross-Origin-Embedder-Policy", "require-corp")
        self.send_header("Cross-Origin-Resource-Policy", "same-origin")
        self.send_header("Cache-Control", "no-store")
        super().end_headers()


CoepHandler.extensions_map[".wasm"] = "application/wasm"
CoepHandler.extensions_map[".js"] = "application/javascript"

if __name__ == "__main__":
    print(f"Serving {ROOT} on http://127.0.0.1:{PORT} (COOP/COEP enabled)")
    http.server.ThreadingHTTPServer(("0.0.0.0", PORT), CoepHandler).serve_forever()
