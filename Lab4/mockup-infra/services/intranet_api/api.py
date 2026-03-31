#!/usr/bin/env python3
"""
Intranet API Server - Private Backend Mockup
Serves JSON API in isolated network
"""

from flask import Flask, jsonify, request
import socket
import os
from datetime import datetime

app = Flask(__name__)

SERVICE_NAME = os.environ.get('SERVICE_NAME', 'intranet_api')
PORT = int(os.environ.get('SERVICE_PORT', 5000))

def get_internal_ip():
    try:
        hostname = socket.gethostname()
        return socket.gethostbyname(hostname)
    except:
        return "172.19.0.x"

@app.route('/status', methods=['GET'])
def get_status():
    """Status endpoint showing network isolation"""
    return jsonify({
        "service": SERVICE_NAME,
        "network": "private_net",
        "internal_ip": get_internal_ip(),
        "status": "operational",
        "timestamp": datetime.now().isoformat(),
        "authenticated": True,
        "layer": "L7 Application",
        "protocol": "HTTP/1.1"
    }), 200

@app.route('/data', methods=['GET', 'POST'])
def handle_data():
    """Data endpoint for POST requests"""
    if request.method == 'POST':
        data = request.get_json(silent=True) or {}
        return jsonify({
            "message": "Data received in secure zone",
            "received": data,
            "timestamp": datetime.now().isoformat(),
            "network": "private_net"
        }), 201
    else:
        return jsonify({
            "message": "Send POST request with JSON data",
            "example": {"test": "data"}
        }), 200

@app.route('/config', methods=['GET'])
def get_config():
    """Internal configuration"""
    return jsonify({
        "environment": "secure_intranet",
        "api_version": "v1",
        "network_isolation": True,
        "features": ["encryption", "audit", "rate_limit"]
    }), 200

@app.route('/health', methods=['GET'])
def health():
    """Health check"""
    return jsonify({
        "service": SERVICE_NAME,
        "status": "healthy",
        "network": "private_net"
    }), 200

@app.errorhandler(404)
def not_found(e):
    return jsonify({"error": "Endpoint not found"}), 404

if __name__ == "__main__":
    print(f"\nStarting Intranet API on port {PORT} (isolated network)")
    app.run(host='0.0.0.0', port=PORT, debug=False)
