#!/usr/bin/env python3
import http.server
import sys

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8080

print(f'Serving on http://localhost:{PORT}')
http.server.HTTPServer(('', PORT), http.server.SimpleHTTPRequestHandler).serve_forever()
