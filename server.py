#!/usr/bin/env python3
import http.server

PORT = 8080

print(f'Serving on http://localhost:{PORT}')

try:
    http.server.HTTPServer(('', PORT), http.server.SimpleHTTPRequestHandler).serve_forever()
except KeyboardInterrupt:
    raise SystemExit(0)
