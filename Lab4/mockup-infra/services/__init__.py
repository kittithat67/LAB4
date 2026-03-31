"""
Services Package - L7 Application Mockups
Tracks services across public_net and private_net
"""

import os
import socket
from pathlib import Path

# Service registry metadata
AVAILABLE_SERVICES = {
    "public": ["public_app"],
    "private": ["intranet_api"]
}

SERVICE_PORTS = {
    "public_app": 80,
    "intranet_api": 5000
}

SERVICE_PROTOCOLS = {
    "public_app": "HTTP",
    "intranet_api": "HTTP"
}

NETWORK_ISOLATION = {
    "public_app": "public_net",
    "intranet_api": "private_net"
}

def get_service_info(service_name=None):
    """Get metadata for services"""
    if service_name:
        if service_name in SERVICE_PORTS:
            return {
                "name": service_name,
                "port": SERVICE_PORTS[service_name],
                "protocol": SERVICE_PROTOCOLS[service_name],
                "network": NETWORK_ISOLATION[service_name]
            }
        return None
    
    return {
        "services": AVAILABLE_SERVICES,
        "total_public": len(AVAILABLE_SERVICES["public"]),
        "total_private": len(AVAILABLE_SERVICES["private"])
    }

def get_internal_ip():
    """Get container's internal L3 IP address"""
    try:
        hostname = socket.gethostname()
        return socket.gethostbyname(hostname)
    except:
        return "0.0.0.0"

# Create global service registry
registry = get_service_info()
