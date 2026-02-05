#!/usr/bin/env python3
import http.server
import logging

# Colors
RESET = '\033[0m'
GREY = '\033[90m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
RED = '\033[31m'
CYAN = '\033[36m'

class ColorFormatter(logging.Formatter):
    COLORS = {
        logging.DEBUG: GREY,
        logging.INFO: GREEN,
        logging.WARNING: YELLOW,
        logging.ERROR: RED,
        logging.CRITICAL: RED,
    }

    def format(self, record):
        color = self.COLORS.get(record.levelno, RESET)
        record.levelname = f'{color}{record.levelname}{RESET}'
        record.msg = f'{color}{record.msg}{RESET}'
        return super().format(record)

handler = logging.StreamHandler()
handler.setFormatter(ColorFormatter('%(asctime)s %(levelname)s: %(message)s', datefmt='%H:%M:%S'))
logging.root.addHandler(handler)
logging.root.setLevel(logging.INFO)

PORT = 8080

class LoggingHandler(http.server.SimpleHTTPRequestHandler):
    def log_message(self, format, *args):
        status = args[1] if len(args) > 1 else ''
        if status.startswith('2'):
            color = GREEN
        elif status.startswith('3'):
            color = CYAN
        elif status.startswith('4'):
            color = YELLOW
        elif status.startswith('5'):
            color = RED
        else:
            color = RESET
        logging.info(f'{color}{args[0]}{RESET} {color}{status}{RESET}')

logging.info(f'Serving on http://localhost:{PORT}')

try:
    http.server.HTTPServer(('', PORT), LoggingHandler).serve_forever()
except KeyboardInterrupt:
    logging.info("Bye!")
    raise SystemExit(0)
