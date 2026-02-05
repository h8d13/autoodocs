#!/usr/bin/env python3
import http.server
import logging

PORT = 8080

print(f'Serving on http://localhost:{PORT}')

try:
    http.server.HTTPServer(('', PORT), http.server.SimpleHTTPRequestHandler).serve_forever()
except KeyboardInterrupt:
    logging.info("Caught keyboard interrupt... Exiting.")
    raise SystemExit(0)
