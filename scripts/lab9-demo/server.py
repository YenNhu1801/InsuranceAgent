#!/usr/bin/env python3
"""Same-origin demo page for the running Lab 9 services. No extra dependencies."""
import urllib.error
import urllib.request
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

ROOT = Path(__file__).resolve().parent
UPSTREAM = {
    "/up/pricing": "http://localhost:5040",
    "/up/policy": "http://localhost:5050",
    "/up/search": "http://localhost:5065",
    "/up/payment": "http://localhost:5070",
}


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        self._serve()

    def do_POST(self):
        self._serve()

    def _serve(self):
        path = self.path.split("?", 1)[0]
        if path in ("/", "/index.html"):
            body = (ROOT / "index.html").read_bytes()
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)
            return
        for prefix, origin in UPSTREAM.items():
            if path == prefix or path.startswith(prefix + "/"):
                self._proxy(prefix, origin)
                return
        self.send_error(404)

    def _proxy(self, prefix, origin):
        rest = self.path[len(prefix):] or "/"
        url = origin + rest
        length = int(self.headers.get("Content-Length", "0") or 0)
        data = self.rfile.read(length) if length else None
        req = urllib.request.Request(url, data=data, method=self.command)
        if self.headers.get("Content-Type"):
            req.add_header("Content-Type", self.headers["Content-Type"])
        if self.headers.get("AgentLogin"):
            req.add_header("AgentLogin", self.headers["AgentLogin"])
        try:
            with urllib.request.urlopen(req, timeout=30) as resp:
                body = resp.read()
                self.send_response(resp.status)
                self.send_header("Content-Type", resp.headers.get("Content-Type", "application/json"))
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)
        except urllib.error.HTTPError as exc:
            body = exc.read()
            self.send_response(exc.code)
            self.send_header("Content-Type", exc.headers.get("Content-Type", "text/plain"))
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

    def log_message(self, fmt, *args):
        print("%s - %s" % (self.address_string(), fmt % args))


if __name__ == "__main__":
    ThreadingHTTPServer(("127.0.0.1", 8090), Handler).serve_forever()
