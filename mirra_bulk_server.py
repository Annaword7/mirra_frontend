"""
Serve mirra_bulk.html over localhost so browser CORS works.

Usage:
    python3 mirra_bulk_server.py
    Then open: http://localhost:8765/
"""

import http.server, os, webbrowser, threading

PORT = 8765
DIR  = os.path.dirname(os.path.abspath(__file__))

class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *a, **kw):
        super().__init__(*a, directory=DIR, **kw)
    def log_message(self, fmt, *args):
        pass  # quiet

if __name__ == '__main__':
    server = http.server.HTTPServer(('localhost', PORT), Handler)
    url    = f'http://localhost:{PORT}/mirra_bulk.html'
    print(f'MiRRA Bulk  →  {url}  (Ctrl+C to stop)')
    threading.Timer(0.6, lambda: webbrowser.open(url)).start()
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print('Stopped.')
