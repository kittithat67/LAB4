#!/usr/bin/env python3
"""
Mockup Infrastructure Manager
Bare Metal → L3 → L4 → L5/6 → L7 Full Stack Automation
"""

import os
import sys
import subprocess
import argparse
import json
import ipaddress
from pathlib import Path
from datetime import datetime, timedelta
from dotenv import load_dotenv

# Cryptography imports for TLS certificate generation
from cryptography import x509
from cryptography.x509.oid import NameOID
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa

class NetworkLayers:
    """Implementation of OSI Layers 3-7"""
    
    L3_NETWORK = "IP/Podman Bridge"
    L4_TRANSPORT = "TCP"
    L5_SESSION = "TLS 1.3"
    L7_APPLICATION = "HTTP/HTTPS"

class InfraManager:
    def __init__(self):
        self.base_dir = Path(__file__).parent.absolute()
        self.env_file = self.base_dir / '.env'
        load_dotenv(self.env_file)
    
    def init(self):
        """Initialize the infrastructure"""
        print("\n🔧 Initializing Mockup Infrastructure...")
        print("=" * 50)
        
        # Create necessary directories
        (self.base_dir / 'certs').mkdir(exist_ok=True)
        (self.base_dir / 'gateway').mkdir(exist_ok=True)
        (self.base_dir / 'services').mkdir(exist_ok=True)
        
        # Generate certificates
        self.generate_tls_certificates()
        
        # Verify network isolation
        self.verify_network_isolation()
        
        print("\n✅ Infrastructure initialized successfully")
        return 0
        
    def run_command(self, cmd, capture=False):
        """Run shell command and stream output"""
        print(f"🔧 Executing: {cmd}")
        process = subprocess.Popen(
            cmd,
            stdout=subprocess.PIPE if capture else subprocess.PIPE,
            stderr=subprocess.STDOUT,
            text=True,
            shell=True
        )
        
        output = []
        for line in process.stdout:
            print(line, end='')
            output.append(line)
            
        process.wait()
        return process.returncode, ''.join(output)
    
    def generate_tls_certificates(self):
        """Generate self-signed TLS certificates for Session Layer (L5/6)"""
        print("\n🔐 [Layer 5/6 - Session] Generating TLS Certificates...")
        
        # Create certs directory
        cert_dir = self.base_dir / 'certs'
        cert_dir.mkdir(exist_ok=True)
        
        # Generate private key (RSA 2048)
        private_key = rsa.generate_private_key(
            public_exponent=65537,
            key_size=2048,
        )
        
        # Certificate metadata from .env
        subject = issuer = x509.Name([
            x509.NameAttribute(NameOID.COUNTRY_NAME, os.getenv('CERT_COUNTRY', 'US')),
            x509.NameAttribute(NameOID.STATE_OR_PROVINCE_NAME, os.getenv('CERT_STATE', 'California')),
            x509.NameAttribute(NameOID.LOCALITY_NAME, os.getenv('CERT_LOCATION', 'San Francisco')),
            x509.NameAttribute(NameOID.ORGANIZATION_NAME, os.getenv('CERT_ORG', 'Mockup Infra')),
            x509.NameAttribute(NameOID.COMMON_NAME, os.getenv('CERT_CN', 'api.mockup.test')),
        ])
        
        # Subject Alternative Names for multiple domains - FIXED: Use ipaddress objects
        san_list = [
            x509.DNSName(u"localhost"),
            x509.DNSName(u"api.mockup.test"),
            x509.DNSName(u"gateway.mockup.test"),
            x509.DNSName(u"nginx-gateway"),
            x509.DNSName(u"public_app"),
            x509.DNSName(u"intranet_api"),
            x509.IPAddress(ipaddress.IPv4Address("127.0.0.1")),
            x509.IPAddress(ipaddress.IPv4Address("172.18.0.1")),
            x509.IPAddress(ipaddress.IPv4Address("172.19.0.1")),
        ]
        
        # Build certificate
        cert = (
            x509.CertificateBuilder()
            .subject_name(subject)
            .issuer_name(issuer)
            .public_key(private_key.public_key())
            .serial_number(x509.random_serial_number())
            .not_valid_before(datetime.utcnow())
            .not_valid_after(datetime.utcnow() + timedelta(days=365))
            .add_extension(x509.SubjectAlternativeName(san_list), critical=False)
            .add_extension(x509.BasicConstraints(ca=False, path_length=None), critical=False)
            .add_extension(x509.KeyUsage(
                digital_signature=True,
                content_commitment=False,
                key_encipherment=True,
                data_encipherment=False,
                key_agreement=False,
                key_cert_sign=False,
                crl_sign=False,
                encipher_only=False,
                decipher_only=False
            ), critical=False)
            .add_extension(x509.ExtendedKeyUsage([
                x509.ExtendedKeyUsageOID.SERVER_AUTH,
                x509.ExtendedKeyUsageOID.CLIENT_AUTH
            ]), critical=False)
            .sign(private_key, hashes.SHA256())
        )
        
        # Write private key
        key_path = cert_dir / 'server.key'
        with open(key_path, 'wb') as f:
            f.write(private_key.private_bytes(
                encoding=serialization.Encoding.PEM,
                format=serialization.PrivateFormat.TraditionalOpenSSL,
                encryption_algorithm=serialization.NoEncryption(),
            ))
        
        # Write certificate
        cert_path = cert_dir / 'server.crt'
        with open(cert_path, 'wb') as f:
            f.write(cert.public_bytes(serialization.Encoding.PEM))
        
        print(f"✅ Certificates generated successfully:")
        print(f"   - Private Key: {key_path}")
        print(f"   - Certificate: {cert_path}")
        print(f"   - Common Name: {os.getenv('CERT_CN', 'api.mockup.test')}")
        print(f"   - Subject Alt Names: localhost, api.mockup.test, 127.0.0.1, 172.18.0.1, 172.19.0.1")
        
        return 0
    
    def verify_network_isolation(self):
        """Test L3 network isolation"""
        print("\n🌐 [Layer 3 - Network] Testing Isolation...")
        
        # Check if private network is truly isolated
        result, output = self.run_command(
            "podman network inspect private_net 2>/dev/null || echo '{}'",
            capture=True
        )
        
        if "internal" in output and "true" in output:
            print("✅ Private network is isolated (internal: true)")
        else:
            print("⚠️  Private network not found or not isolated. Creating networks...")
            self.run_command("podman network create public_net 2>/dev/null || true")
            self.run_command("podman network create --internal private_net 2>/dev/null || true")
            print("✅ Networks created successfully")
        
        return 0
    
    def deploy_stack(self):
        """Deploy full infrastructure stack"""
        print("\n🚀 Deploying Mockup Infrastructure Stack")
        print("   Bare Metal → L3 → L4 → L5/6 → L7")
        print("=" * 50)
        
        # Verify podman-compose is installed
        try:
            subprocess.run("podman compose --version", shell=True, capture_output=True, check=True)
        except subprocess.CalledProcessError:
            print("❌ podman-compose not found. Please install it first.")
            print("   pip install podman-compose")
            return 1
        
        # Generate certificates if they don't exist
        cert_file = self.base_dir / 'certs' / 'server.crt'
        if not cert_file.exists():
            self.generate_tls_certificates()
        
        # Ensure networks exist
        self.verify_network_isolation()
        
        # Deploy with podman-compose
        os.chdir(self.base_dir)
        return self.run_command("podman compose up -d --remove-orphans")[0]
    
    def stop_stack(self):
        """Stop all services"""
        print("\n🛑 Stopping Mockup Infrastructure...")
        os.chdir(self.base_dir)
        return self.run_command("podman compose down")[0]
    
    def restart_stack(self):
        """Restart all services"""
        self.stop_stack()
        return self.deploy_stack()
    
    def status(self):
        """Show service status"""
        print("\n📊 Service Status:")
        print("=" * 50)
        os.chdir(self.base_dir)
        return self.run_command("podman compose ps")[0]
  
    def logs(self, service=None):
        """Show service logs"""
        os.chdir(self.base_dir)
        cmd = "podman compose logs"
        if service:
            cmd += f" {service}"
        cmd += " -f"
        return self.run_command(cmd)[0]
    
    def inspect_tls(self):
        """Inspect TLS certificate (L5/6 Session Layer)"""
        print("\n🔒 [Layer 5/6 - Session] TLS Certificate Inspection:")
        print("=" * 50)
        
        # Check if certificate exists
        cert_file = self.base_dir / 'certs' / 'server.crt'
        if not cert_file.exists():
            print("❌ Certificate not found. Generate with: ./manage.py certs")
            return 1
        
        # Inspect certificate with openssl
        cmd = "openssl x509 -in certs/server.crt -text -noout | grep -E 'Subject:|Issuer:|DNS:|IP Address:|Not Before:|Not After:'"
        return self.run_command(cmd)[0]
    
    def test_endpoints(self):
        """Test all endpoints through the gateway - Windows compatible"""
        print("\n🧪 Testing Layer 7 Endpoints:")
        print("=" * 50)
        
        # Wait for services to be ready
        import time
        time.sleep(5)
        
        tests = [
            ("Public Web (L7 HTML)", "http://localhost:8080/"),
            ("Intranet API Status (L7 JSON)", "https://localhost:443/status", "-k"),
            ("Intranet API Data (L7 JSON)", "https://localhost:443/data", "-k -X POST -H \"Content-Type: application/json\" -d \"{\\\"test\\\":\\\"data\\\"}\""),
            ("Intranet API Config (L7 JSON)", "https://localhost:443/config", "-k"),
            ("Health Check", "http://localhost:8080/health"),
        ]
        
        success_count = 0
        for name, url, *args in tests:
            cmd = f"curl -s -w '\\n%{{http_code}}' {' '.join(args)} {url}"
            print(f"\n📡 Testing: {name}")
            print(f"   URL: {url}")
            
            try:
                # Use explicit encoding to handle Windows charset issues
                result = subprocess.run(cmd, shell=True, capture_output=True, timeout=10)
                
                # Try multiple encodings to handle Windows output
                output = None
                for encoding in ['utf-8', 'cp1252', 'latin-1']:
                    try:
                        output = result.stdout.decode(encoding, errors='ignore')
                        break
                    except:
                        continue
                
                if output is None:
                    output = result.stdout.decode('utf-8', errors='replace')
                
                # Parse response and status code
                lines = output.strip().split('\n')
                if len(lines) >= 2:
                    status_code = lines[-1].strip().strip("'\"")
                    response = '\n'.join(lines[:-1])
                else:
                    status_code = "000"
                    response = output
                
                print(f"   Status Code: {status_code}")
                
                # Check for success (200-299 range)
                try:
                    status_int = int(status_code)
                    is_success = 200 <= status_int < 300
                except:
                    is_success = False
                
                if is_success:
                    print(f"   ✅ Success")
                    
                    # Try to parse and display response
                    if response:
                        try:
                            json_data = json.loads(response)
                            print(f"   Response: {json.dumps(json_data, indent=6)}")
                        except (json.JSONDecodeError, UnicodeDecodeError):
                            preview = response[:150].replace('\n', ' ')
                            print(f"   Response: {preview}...")
                    
                    success_count += 1
                else:
                    print(f"   ❌ Failed (HTTP {status_code})")
                    if response:
                        preview = response[:150].replace('\n', ' ')
                        print(f"   Response: {preview}...")
                        
            except subprocess.TimeoutExpired:
                print("   ⚠️  Timeout")
            except Exception as e:
                print(f"   ⚠️  Error: {str(e)[:100]}")
        
        print(f"\n📊 Test Results: {success_count}/{len(tests)} passed")
        return 0 if success_count == len(tests) else 1
    

def main():
    parser = argparse.ArgumentParser(
        description="Mockup Infrastructure Manager - Full Stack (L3-L7)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
OSI Layer Implementation:
  L3 (Network)    : Podman Bridge Networks (public_net/private_net)
  L4 (Transport)  : TCP/IP via Podman
  L5/6 (Session)  : TLS 1.3 with self-signed certificates
  L7 (Application): HTTP/HTTPS with Nginx + Python services
        """
    )
    
    subparsers = parser.add_subparsers(dest="command", help="Commands")
    
    # Core commands
    subparsers.add_parser("deploy", help="Deploy full stack")
    subparsers.add_parser("stop", help="Stop all services")
    subparsers.add_parser("restart", help="Restart all services")
    subparsers.add_parser("status", help="Show service status")
    subparsers.add_parser("logs", help="Show logs")
    subparsers.add_parser("init", help="Initialize infrastructure")
    
    # Security commands
    subparsers.add_parser("certs", help="Generate TLS certificates")
    subparsers.add_parser("tls", help="Inspect TLS certificate")
    
    # Testing commands
    subparsers.add_parser("test", help="Test all endpoints")
    subparsers.add_parser("isolate", help="Verify network isolation")
    
    args = parser.parse_args()
    
    manager = InfraManager()
    
    commands = {
        "deploy": manager.deploy_stack,
        "stop": manager.stop_stack,
        "restart": manager.restart_stack,
        "status": manager.status,
        "logs": lambda: manager.logs(None),
        "init": manager.init,
        "certs": manager.generate_tls_certificates,
        "tls": manager.inspect_tls,
        "test": manager.test_endpoints,
        "isolate": manager.verify_network_isolation,
    }
    
    if args.command in commands:
        try:
            sys.exit(commands[args.command]())
        except KeyboardInterrupt:
            print("\n\n⚠️  Interrupted by user")
            sys.exit(130)
        except Exception as e:
            print(f"\n❌ Error: {e}")
            sys.exit(1)
    else:
        parser.print_help()
        sys.exit(1)

if __name__ == "__main__":
    main()
