#!/usr/bin/env python3
import http.server
import logging

logging.basicConfig(level=logging.INFO, format='%(asctime)s %(levelname)s: %(message)s', datefmt='%H:%M:%S')

PORT = 8080

logging.info(f'Serving on http://localhost:{PORT}')

try:
    http.server.HTTPServer(('', PORT), http.server.SimpleHTTPRequestHandler).serve_forever()
except KeyboardInterrupt:
    logging.info("Caught keyboard interrupt... Exiting.")
    raise SystemExit(0)
