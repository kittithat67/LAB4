"""
Public Application Package
Internet-facing server mockup (L7 - HTML)
"""

SERVICE_NAME = "public_app"
INTERNAL_PORT = 80
PROTOCOL = "TCP"
NETWORK = "public_net"
CONTENT_TYPE = "text/html"

__all__ = ['SERVICE_NAME', 'INTERNAL_PORT', 'PROTOCOL', 'NETWORK']
