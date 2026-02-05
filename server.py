#!/usr/bin/env python3
"""Simple HTTP server for serving markdown files"""

import http.server
import subprocess
import sys

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8080

class MarkdownHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        path = self.path.lstrip('/')
        if path == '':
            path = 'test.md'

        if path.endswith('.md'):
            try:
                result = subprocess.run(
                    ['luajit', 'markdown.lua', '-l', path],
                    capture_output=True,
                    text=True
                )
                if result.returncode == 0:
                    content = result.stdout.encode()
                    self.send_response(200)
                    self.send_header('Content-Type', 'text/html')
                    self.send_header('Content-Length', len(content))
                    self.end_headers()
                    self.wfile.write(content)
                else:
                    self.send_error(500, result.stderr)
            except FileNotFoundError:
                self.send_error(404, f'File not found: {path}')
        else:
            super().do_GET()

print(f'Serving on http://localhost:{PORT}')
http.server.HTTPServer(('', PORT), MarkdownHandler).serve_forever()
