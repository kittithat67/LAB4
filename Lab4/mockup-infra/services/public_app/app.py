#!/usr/bin/env python3
"""
Public Internet Server - Layer 7 Application Mockup
Serves HTML content to simulate a public-facing website
"""

import http.server
import socketserver
import socket
import os
import json
from datetime import datetime

PORT = int(os.environ.get('SERVICE_PORT', 80))
SERVICE_NAME = os.environ.get('SERVICE_NAME', 'public_app')

class MockPublicHandler(http.server.SimpleHTTPRequestHandler):
    
    def get_internal_ip(self):
        try:
            hostname = socket.gethostname()
            return socket.gethostbyname(hostname)
        except:
            return "172.18.0.x"
    
    def do_GET(self):
        """Handle GET requests"""
        
        if self.path == '/' or self.path == '/index.html':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            
            html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Public Internet Server</title>
    <style>
        body {{
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            max-width: 800px;
            margin: 40px auto;
            padding: 20px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border-radius: 10px;
        }}
        h1 {{ color: #fff; border-bottom: 2px solid #fff; }}
        .info {{ background: rgba(255,255,255,0.1); padding: 20px; border-radius: 8px; }}
        .layer {{ background: rgba(0,0,0,0.2); padding: 10px; margin: 10px 0; border-left: 4px solid #ffd700; }}
    </style>
</head>
<body>
    <h1>Public Network Server</h1>
    <div class="info">
        <p><strong>Service:</strong> {SERVICE_NAME}</p>
        <p><strong>Status:</strong> Online</p>
        <p><strong>Time:</strong> {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</p>
    </div>
    <div class="layer">
        <h3>Layer 3 (Network)</h3>
        <p>IP: <code>{self.get_internal_ip()}</code> (public_net)</p>
    </div>
    <div class="layer">
        <h3>Layer 4 (Transport)</h3>
        <p>TCP Port: {PORT}</p>
    </div>
    <div class="layer">
        <h3>Layer 7 (Application)</h3>
        <p>HTTP/1.1 - text/html</p>
    </div>
</body>
</html>"""
            self.wfile.write(html.encode('utf-8'))
            
        elif self.path == '/health':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            health = {
                'service': SERVICE_NAME,
                'status': 'healthy',
                'network': 'public_net',
                'ip': self.get_internal_ip()
            }
            self.wfile.write(json.dumps(health).encode())
        else:
            self.send_response(404)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'error': 'Not found'}).encode())
    
    def log_message(self, format, *args):
        print(f"[{SERVICE_NAME}] {format % args}")

def run_server():
    print(f"\nStarting Public Server on port {PORT}")
    with socketserver.TCPServer(("0.0.0.0", PORT), MockPublicHandler) as httpd:
        httpd.serve_forever()

if __name__ == "__main__":
    run_server()
