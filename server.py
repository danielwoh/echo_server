#!/usr/bin/env python3
"""
HTTP Echo Server
Gibt alle eingehenden Requests als JSON-Antwort zurück.
"""

import json
import argparse
from http.server import BaseHTTPRequestHandler, HTTPServer

HOST = "0.0.0.0"
PORT = 8080


class EchoHandler(BaseHTTPRequestHandler):
    def do_request(self):
        # Body lesen, falls vorhanden
        content_length = int(self.headers.get("Content-Length", 0))
        body_bytes = self.rfile.read(content_length) if content_length > 0 else b""

        try:
            body = body_bytes.decode("utf-8")
        except UnicodeDecodeError:
            body = body_bytes.hex()

        response = {
            "method": self.command,
            "path": self.path,
            "headers": dict(self.headers),
            "body": body,
        }

        response_bytes = json.dumps(response, indent=2, ensure_ascii=False).encode("utf-8")

        self.send_response(200)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(response_bytes)))
        self.end_headers()
        self.wfile.write(response_bytes)

    # Alle gängigen HTTP-Methoden weiterleiten
    do_GET = do_request
    do_POST = do_request
    do_PUT = do_request
    do_PATCH = do_request
    do_DELETE = do_request
    do_OPTIONS = do_request
    do_HEAD = do_request

    def log_message(self, fmt, *args):
        print(f"[{self.address_string()}] {fmt % args}")


def main():
    parser = argparse.ArgumentParser(description="HTTP Echo Server")
    parser.add_argument("--host", default=HOST, help=f"Bind-Adresse (Standard: {HOST})")
    parser.add_argument("--port", type=int, default=PORT, help=f"Port (Standard: {PORT})")
    args = parser.parse_args()

    server = HTTPServer((args.host, args.port), EchoHandler)
    print(f"Echo-Server läuft auf http://{args.host}:{args.port}")
    print("Zum Beenden: Ctrl+C\n")

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nServer gestoppt.")
        server.server_close()


if __name__ == "__main__":
    main()
