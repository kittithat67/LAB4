"""
Intranet API Package
Private backend service mockup (L7 - JSON)
Network: private_net (Isolated Intranet)
"""

SERVICE_NAME = "intranet_api"
INTERNAL_PORT = 5000
PROTOCOL = "TCP"
NETWORK = "private_net"
CONTENT_TYPE = "application/json"

__all__ = ['SERVICE_NAME', 'INTERNAL_PORT', 'PROTOCOL', 'NETWORK']
