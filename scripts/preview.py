#!/usr/bin/env python3
"""Serve o bundle de produção (apps/web/build/web) e encaminha /api/* para a API local.

Espelha o roteamento que a Vercel faz em produção: o mesmo domínio serve o bundle
estático e a API, então o app em modo release enxerga `/api` no próprio origin.

    ./scripts/preview.sh [porta] [porta_da_api]
    ./scripts/preview.sh 8090 5050

Gera o bundle antes: (cd apps/web && flutter build web)
"""
import http.server
import socketserver
import sys
import urllib.error
import urllib.request
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
ROOT = REPO / "apps" / "web" / "build" / "web"

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8090
API = f"http://127.0.0.1:{sys.argv[2] if len(sys.argv) > 2 else 5050}"

if not (ROOT / "index.html").exists():
    sys.exit(f"não encontrei o bundle em {ROOT} — rode: (cd apps/web && flutter build web)")


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(ROOT), **kwargs)

    def _proxy(self, method):
        body = None
        length = int(self.headers.get("content-length") or 0)
        if length:
            body = self.rfile.read(length)
        req = urllib.request.Request(
            API + self.path,
            data=body,
            method=method,
            headers={k: v for k, v in self.headers.items() if k.lower() not in ("host", "content-length")},
        )
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                payload, status, headers = resp.read(), resp.status, resp.headers
        except urllib.error.HTTPError as e:
            payload, status, headers = e.read(), e.code, e.headers
        except Exception as e:  # API fora do ar
            payload, status, headers = str(e).encode(), 502, {}
        self.send_response(status)
        for k, v in headers.items():
            if k.lower() in ("content-type", "content-length", "cache-control"):
                self.send_header(k, v)
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(payload)

    def do_GET(self):
        self._proxy("GET") if self.path.startswith("/api") else super().do_GET()

    def do_POST(self):
        self._proxy("POST") if self.path.startswith("/api") else self.send_error(405)

    def do_PATCH(self):
        self._proxy("PATCH") if self.path.startswith("/api") else self.send_error(405)

    def do_DELETE(self):
        self._proxy("DELETE") if self.path.startswith("/api") else self.send_error(405)

    def log_message(self, fmt, *args):
        sys.stderr.write("[preview] %s\n" % (fmt % args))


socketserver.TCPServer.allow_reuse_address = True
with socketserver.ThreadingTCPServer(("", PORT), Handler) as httpd:
    print(f"preview em http://localhost:{PORT}  (bundle {ROOT}, /api -> {API})")
    httpd.serve_forever()
