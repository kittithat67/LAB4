# Nginx Logging Configuration: Thailand Digital Crime Act Compliance

## Overview

The mockup-infra gateway has been configured with comprehensive logging to comply with Thailand Digital Crime Act (พระราชบัญญัติการกระทำผิดเกี่ยวกับคอมพิวเตอร์) audit and tracking requirements.

**Key Requirements Met:**
- ✅ All connections (success and failure) logged with timestamps
- ✅ Complete request/response tracking (audit trail)
- ✅ Client IP address tracking
- ✅ User identification
- ✅ Error/failure logging with reasons
- ✅ SSL/TLS connection details
- ✅ Upstream backend status tracking
- ✅ Request timing and performance metrics
- ✅ Legal compliance audit logs in JSON format

---

## Log Files Generated

### 1. **access.log** - Main Traffic Log
📁 Location: `/var/log/nginx/access.log`

**Format:** Pipe-separated values with detailed information
```
<Client-IP>|<User>|<Timestamp>|<Request>|<Status>|<Bytes>|<Referer>|<UserAgent>|<ForwardedFor>|<RequestTime>|<UpstreamTime>|<UpstreamAddr>|<UpstreamStatus>
```

**Example:**
```
172.18.0.3||[2025-02-13T15:30:45+07:00]|GET / HTTP/1.1|200|1024|<none>|curl/7.68.0|172.18.0.2|0.045|0.032|172.18.0.2:80|200
```

**Usage:** Real-time traffic monitoring, performance analysis

---

### 2. **audit.log** - Detailed Audit Trail (JSON Format)
📁 Location: `/var/log/nginx/audit.log`

**Format:** JSON objects (one per line), suitable for parsing and archiving

**Example:**
```json
{
  "timestamp": "2025-02-13T15:30:45+07:00",
  "client_ip": "172.18.0.3",
  "remote_user": "admin",
  "request_method": "GET",
  "request_uri": "/status",
  "request_protocol": "HTTP/1.1",
  "response_status": 200,
  "response_bytes_sent": 512,
  "request_time": 0.045,
  "upstream_addr": "172.18.0.2:80",
  "upstream_status": "200",
  "upstream_response_time": 0.032,
  "http_referer": "-",
  "user_agent": "curl/7.68.0",
  "x_forwarded_for": "172.18.0.2",
  "x_forwarded_proto": "https",
  "ssl_protocol": "TLSv1.3",
  "ssl_cipher": "TLS_AES_256_GCM_SHA384",
  "connection_id": "12345",
  "request_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Usage:** Legal compliance, detailed auditing, forensics

---

### 3. **connection_error.log** - Failed Connections
📁 Location: `/var/log/nginx/connection_error.log`

**Format:** JSON objects for all HTTP 4xx and 5xx errors

**Example:**
```json
{
  "timestamp": "2025-02-13T15:31:20+07:00",
  "event": "CONNECTION_ERROR",
  "client_ip": "192.168.1.100",
  "request": "GET /invalid HTTP/1.1",
  "status": 404,
  "upstream": "172.18.0.2:80",
  "upstream_status": "404",
  "upstream_connect_time": "0.015",
  "error_reason": "/invalid attempted",
  "ssl_protocol": "TLSv1.3"
}
```

**Usage:** Error tracking, failure analysis, debugging

---

### 4. **ssl_connection.log** - SSL/TLS Connection Details
📁 Location: `/var/log/nginx/intranet_ssl.log`

**Format:** JSON objects with SSL/TLS handshake details

**Example:**
```json
{
  "timestamp": "2025-02-13T15:32:00+07:00",
  "event": "SSL_CONNECTION",
  "client_ip": "172.19.0.3",
  "ssl_protocol": "TLSv1.3",
  "ssl_cipher": "TLS_AES_256_GCM_SHA384",
  "ssl_client_cert": "CN=client.example.com",
  "ssl_session_id": "a1b2c3d4e5f6...",
  "ssl_session_reused": "r"
}
```

**Usage:** Security audit, encryption verification

---

### 5. **Service-Specific Logs** - Per-Endpoint Tracking

#### Public Web Server
- `/var/log/nginx/public_app.log` - HTTP traffic
- `/var/log/nginx/public_app_audit.log` - Detailed audit
- `/var/log/nginx/public_app_error.log` - Error details
- `/var/log/nginx/health_check.log` - Health check requests

#### Intranet API Server
- `/var/log/nginx/intranet_api.log` - HTTPS traffic
- `/var/log/nginx/intranet_api_audit.log` - Detailed audit
- `/var/log/nginx/intranet_api_error.log` - Error details
- `/var/log/nginx/intranet_ssl.log` - SSL connections

#### API Endpoints
- `/var/log/nginx/status_endpoint.log` - /status calls
- `/var/log/nginx/data_endpoint.log` - /data calls
- `/var/log/nginx/config_endpoint.log` - /config calls
- `/var/log/nginx/not_found.log` - Invalid endpoints
- `/var/log/nginx/health_check_https.log` - HTTPS health checks

---

## Thailand Digital Crime Act Compliance Features

### 1. **Complete Audit Trail**
```
Every connection is logged with:
- Precise timestamp (ISO 8601 format with timezone)
- Client IP address
- User identification (if available)
- Full request details
- Response status
- Upstream backend information
```

**Legal Requirement Met:** Ability to trace all activities by date, time, and user

---

### 2. **Connection Success Logging**
All successful HTTP/HTTPS requests (2xx, 3xx status codes) are logged to:
- `access.log` - Summary format
- `audit.log` - Detailed JSON format with all request/response details
- Service-specific logs - Per-endpoint tracking

**Legal Requirement Met:** Complete record of all access attempts

---

### 3. **Connection Failure Logging**
All failed requests (4xx, 5xx status codes) are logged to:
- `connection_error.log` - JSON format with error context
- Service-specific error logs - Error details and stack traces
- `error.log` - Debug information

**Legal Requirement Met:** Documentation of failed access attempts and errors

---

### 4. **Security Event Logging**
SSL/TLS connections logged with:
- Protocol version (TLS 1.2, TLS 1.3)
- Cipher suite
- Client certificate (if applicable)
- Session ID and reuse information

**Legal Requirement Met:** Secure communication verification

---

### 5. **Request Tracing**
Each request includes:
- `X-Request-ID` header - Unique identifier for request tracking
- Client IP address (original and forwarded)
- Request path and method
- Response time measurements
- Upstream backend response times

**Legal Requirement Met:** Ability to trace requests through entire system

---

### 6. **Timestamp Precision**
All logs use ISO 8601 format with timezone information:
```
2025-02-13T15:30:45+07:00
```

**Legal Requirement Met:** Accurate time tracking for legal proceedings

---

## Log File Locations (Docker Container)

Inside the container, logs are available at:
```
/var/log/nginx/
├── access.log                    # Main traffic log
├── audit.log                     # Detailed audit trail
├── connection_error.log          # Failed connections
├── error.log                     # Error log (debug level)
├── ssl_connection.log            # SSL connections
├── public_app.log                # Public web traffic
├── intranet_api.log              # Intranet API traffic
├── status_endpoint.log           # /status endpoint
├── data_endpoint.log             # /data endpoint
├── config_endpoint.log           # /config endpoint
├── health_check.log              # HTTP health checks
├── health_check_https.log        # HTTPS health checks
└── not_found.log                 # 404 errors
```

---

## Accessing Logs

### From Host (View Logs in Real-time)
```bash
# View all logs
docker-compose logs -f nginx-gateway

# View specific log file
docker exec mockup-gateway tail -f /var/log/nginx/audit.log

# Follow audit log with JSON pretty-print
docker exec mockup-gateway tail -f /var/log/nginx/audit.log | jq .
```

### From Container
```bash
# Interactive shell
docker exec -it mockup-gateway sh

# View logs
tail -f /var/log/nginx/audit.log
grep "ERROR" /var/log/nginx/error.log
grep "172.18" /var/log/nginx/access.log
```

### Archiving for Compliance
```bash
# Copy logs to host
docker cp mockup-gateway:/var/log/nginx /path/to/backup/location

# Create audit dump (JSON)
docker exec mockup-gateway cat /var/log/nginx/audit.log > audit_backup_$(date +%Y%m%d).log

# Compress for long-term storage
docker exec mockup-gateway sh -c 'gzip /var/log/nginx/*.log'
```

---

## Log Analysis Examples

### 1. Find All Failed Connections
```bash
# JSON format (audit log)
docker exec mockup-gateway grep '"status":4\|"status":5' /var/log/nginx/audit.log | jq .

# Simple format (error log)
docker exec mockup-gateway grep -E '4[0-9]{2}|5[0-9]{2}' /var/log/nginx/access.log
```

### 2. Track Requests by Client IP
```bash
docker exec mockup-gateway grep '172.18.0.3' /var/log/nginx/audit.log | jq '.client_ip, .request_uri, .response_status'
```

### 3. Find Slow Requests
```bash
# Requests taking more than 1 second
docker exec mockup-gateway jq 'select(.request_time > 1.0)' /var/log/nginx/audit.log
```

### 4. SSL/TLS Connection Analysis
```bash
docker exec mockup-gateway cat /var/log/nginx/intranet_ssl.log | jq '.ssl_protocol, .ssl_cipher'
```

### 5. Upstream Backend Failures
```bash
docker exec mockup-gateway grep '"upstream_status":"5' /var/log/nginx/audit.log | jq '.upstream_addr, .upstream_status'
```

### 6. Search by Time Range
```bash
# All requests from 15:30:00 to 15:30:59
docker exec mockup-gateway grep '15:30' /var/log/nginx/audit.log | jq '.timestamp, .client_ip, .request_method'
```

---

## Log Retention & Archival

### Recommended Retention Periods
**Thailand Digital Crime Act suggests:**
- Active logs: Minimum 90 days
- Archive logs: 1-3 years (depending on criticality)
- Critical events: Indefinite (or per regulation requirements)

### Automated Log Rotation (Docker)
```bash
# Add to docker-compose.yml logging configuration
logging:
  driver: "json-file"
  options:
    max-size: "100m"
    max-file: "10"
    labels: "com.example.env=production"
```

### Manual Archival Script
```bash
#!/bin/bash
# Archive logs daily
BACKUP_DIR="/path/to/backup/$(date +%Y-%m-%d)"
mkdir -p $BACKUP_DIR

docker cp mockup-gateway:/var/log/nginx/audit.log \
  $BACKUP_DIR/audit_$(date +%H%M%S).log

# Compress
gzip $BACKUP_DIR/*.log

# Upload to secure storage (example: S3, encrypted backup)
# aws s3 cp $BACKUP_DIR s3://log-backup-bucket/ --sse AES256 --recursive
```

---

## Monitoring & Alerting

### Real-time Monitoring
```bash
# Count requests per endpoint in last 5 minutes
watch -n 5 'docker exec mockup-gateway tail -n 100 /var/log/nginx/audit.log | \
  jq -r ".request_uri" | sort | uniq -c | sort -rn'
```

### Alert on Errors
```bash
# Monitor for connection errors
docker exec mockup-gateway bash -c \
  'while true; do 
    count=$(grep -c "5[0-9]{2}" /var/log/nginx/access.log); 
    [ $count -gt 10 ] && echo "ALERT: $count errors detected"; 
    sleep 30; 
  done'
```

### Security Event Alerting
```bash
# Alert on SSL failures or protocol downgrade
docker exec mockup-gateway jq 'select(.ssl_protocol != "TLSv1.3")' \
  /var/log/nginx/intranet_ssl.log | \
  mail -s "Non-TLS1.3 Connection Detected" security@example.com
```

---

## Log Format Reference

### Main Log Variables
| Variable | Description | Example |
|----------|-------------|---------|
| `$remote_addr` | Client IP | 172.18.0.3 |
| `$remote_user` | Authenticated user | admin |
| `$time_iso8601` | ISO 8601 timestamp | 2025-02-13T15:30:45+07:00 |
| `$request_method` | HTTP method | GET, POST, PUT |
| `$request_uri` | Full request URI | /api/status?format=json |
| `$server_protocol` | HTTP protocol | HTTP/1.1, HTTP/2.0 |
| `$status` | Response status code | 200, 404, 500 |
| `$body_bytes_sent` | Response size | 1024 |
| `$request_time` | Request duration | 0.045 (seconds) |
| `$upstream_addr` | Upstream server | 172.18.0.2:80 |
| `$upstream_status` | Upstream response | 200, 502 |
| `$upstream_response_time` | Upstream duration | 0.032 |
| `$ssl_protocol` | TLS version | TLSv1.3 |
| `$ssl_cipher` | Cipher suite | TLS_AES_256_GCM_SHA384 |
| `$connection` | Connection ID | 12345 |

---

## Compliance Checklist

- [x] All HTTP connections logged (success and failure)
- [x] Complete audit trail in JSON format
- [x] Timestamps with timezone (ISO 8601)
- [x] Client IP tracking
- [x] User identification
- [x] Request/response details
- [x] Error logging with reasons
- [x] SSL/TLS details logged
- [x] Request tracing (X-Request-ID)
- [x] Performance metrics (request time)
- [x] Upstream backend tracking
- [x] Separate error and access logs
- [x] JSON format for legal compliance
- [x] Service-specific audit logs
- [x] Endpoint-specific tracking

---

## Next Steps

1. **Deploy Changes:**
   ```bash
   docker-compose down
   docker-compose up -d
   ```

2. **Verify Logging:**
   ```bash
   docker exec mockup-gateway ls -lh /var/log/nginx/
   docker logs mockup-gateway | grep -i nginx
   ```

3. **Test Connections:**
   ```bash
   # Success (should log to audit.log)
   curl -s https://localhost/status 2>&1 | head -20
   
   # Failure (should log to connection_error.log)
   curl -s https://localhost/invalid 2>&1
   ```

4. **Review Logs:**
   ```bash
   docker exec mockup-gateway tail -f /var/log/nginx/audit.log | jq .
   ```

5. **Archive Logs (for compliance):**
   Set up daily backup/archive script as shown above

---

**Status:** ✅ Complete - Thailand Digital Crime Act Compliance Logging Implemented

Generated: 2025-02-13  
Compliance Standard: Thailand Computer Crime Act, ISO 27001, Digital Audit Trail Requirements
