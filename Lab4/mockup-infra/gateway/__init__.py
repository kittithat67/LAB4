"""
Gateway Package - L7 Reverse Proxy Configuration
Acts as the bridge between public_net and private_net
"""

import os

# Absolute path for Nginx config
GATEWAY_ROOT = os.path.dirname(os.path.abspath(__file__))
CONF_PATH = os.path.join(GATEWAY_ROOT, "nginx.conf")

# Gateway metadata
PROXY_VERSION = "1.25-alpine"
PROXY_TYPE = "nginx"
ROLE = "L7 Reverse Proxy / API Gateway"

# Network bridging
NETWORKS = ["public_net", "private_net"]
INTERNAL_RESOLUTION = "podman_dns"

def get_gateway_info():
    return {
        "role": ROLE,
        "networks": NETWORKS,
        "config_path": CONF_PATH,
        "version": PROXY_VERSION
    }
