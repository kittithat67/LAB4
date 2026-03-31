# Week 02 on Mockup-Infra: Stateless vs Stateful Integration

**Date:** February 13, 2026  
**Status:** 🟢 INTEGRATED INTO DUAL-NETWORK ARCHITECTURE  
**Tested On:** Podman 5.7.1 + podman-compose 1.5.0  

---

## ⚠️ Week 02 Curriculum Scope

**FOCUS:** Stateless vs Stateful authentication patterns  
**ACTIVE SERVICES FOR THIS WEEK:**
- `stateless-api` (Port 3000) - JWT-based authentication ✅
- `stateful-api` (Port 3001) - Session-based authentication ✅
- `nginx-gateway` (Port 80/443) - Request routing ✅

**DEPRECATED FOR THIS WEEK:**
- `mime-server` (Port 65432) - **Week 01 concept** 
  - ❌ **NO LONGER RUNS BY DEFAULT** (domain isolation enforced)
  - If needed for reference: `podman-compose --profile week01 up -d`
- `mime-client` - **Week 01 only**, do not study for Week 02

### Domain Isolation Enforcement

As of February 13, 2026, mime-server and mime-client are **excluded by default** using Docker Compose profiles. This prevents confusion and resource waste for Week 02 students.

If you accidentally see mime-server running:
```bash
# Remove it without affecting Week 02 services
podman rm -f mime-server mime-client

# Restart clean
podman-compose up -d
```

For Week 02 study, **ignore MIME-server** entirely. It runs in mockup-infra as a reference only when explicitly enabled, but is **NOT** part of the Week 02 curriculum domain.

See [APP_DOMAIN_BY_WEEK.md](../APP_DOMAIN_BY_WEEK.md) for service organization.

---

## Overview

Week 02 Phase 1 (Node.js servers demonstrating stateless vs stateful patterns) has been integrated into the existing **mockup-infra** dual-network architecture. Instead of running as standalone servers, both the stateless and stateful APIs now run as containerized services within the same podman-compose stack.

### Architecture

```
PUBLIC NETWORK (172.18.0.0/16)
├── nginx-gateway (172.18.0.2)
│   ├── :8080 → HTTP
│   └── :443 → HTTPS
├── public_app (172.18.0.3)
├── mime-server (172.18.0.4)       ⚠️ WEEK 01 ONLY (deprecated for Week 02)
└── stateless-api (172.18.0.6)  ← WEEK 02: JWT-based sessions
    
PRIVATE NETWORK (172.19.0.0/16)
├── nginx-gateway (172.19.0.2)
├── intranet_api (172.19.0.3)
├── mime-server (172.19.0.5)       ⚠️ WEEK 01 ONLY (deprecated for Week 02)
└── stateful-api (172.19.0.6)   ← WEEK 02: In-memory sessions
```

### Service Placement

| Service | Week | Network | IP | Port | Purpose |
|---------|------|---------|----|----|---------|
| **stateless-api** | Week 02 | public_net | 172.18.0.6 | 3000 | JWT-based authentication (scales) |
| **stateful-api** | Week 02 | private_net | 172.19.0.6 | 3001 | Session-based authentication (needs affinity) |
| **mime-server** | ⚠️ Week 01 | both | 172.18.0.4 / 172.19.0.5 | 65432 | DEPRECATED for Week 02 (not part of curriculum) |
| public_app | Context | public_net | 172.18.0.3 | 80 | Supporting service |
| intranet_api | Context | private_net | 172.19.0.3 | 5000 | Supporting service |

**For Week 02 Studies:** Focus on **stateless-api** and **stateful-api** only. Do **NOT** study mime-server.

### Why This Network Placement for Week 02?

| Aspect | Stateless API | Stateful API |
|--------|---------------|-------------|
| **Network** | public_net | private_net |
| **Rationale** | Stateless scales horizontally - multiple servers on same network | Stateful needs session affinity - isolated network for sticky routing |
| **HTTP vs HTTPS** | HTTP (simpler demo) | HTTPS (production pattern) |
| **Learning Goal** | See JWT work across multiple instances | See session retention within single instance |

---

## Quick Start

### Step 1: Navigate to mockup-infra

```bash
cd d:\boonsup\automation\mockup-infra
```

### Step 2: Build Services

```bash
# Build all services including Week 02 APIs
podman-compose build
```

**Output (expect these new images):**
```
Building stateless-api ...
Building stateful-api ...
// ... other services ...
Successfully tagged stateless-api:latest
Successfully tagged stateful-api:latest
```

### Step 3: Start All Services

```bash
# Start all services in daemon mode
podman-compose up -d
```

### Step 4: Verify Deployment

```bash
# Check all services running
podman-compose ps

# Expected output (focus on new services):
# stateless-api    node ... Up 3000
# stateful-api     node ... Up 3001
```

### Step 5: Access the APIs

#### Stateless API (HTTP via Public Network)
```bash
# URL: http://localhost:8080/api/stateless/
# Access through nginx gateway on public_net

# Health check
curl http://localhost:8080/api/stateless/health

# Login (get JWT token)
curl -X POST http://localhost:8080/api/stateless/login \
  -H "Content-Type: application/json" \
  -d '{"username":"alice","password":"secret"}'

# Response:
# {
#   "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
#   "expiresIn": 3600
# }

# Use token on protected endpoint
curl http://localhost:8080/api/stateless/dashboard \
  -H "Authorization: Bearer <TOKEN>"
```

#### Stateful API (HTTPS via Private Network)
```bash
# URL: https://localhost/api/stateful/
# Access through nginx gateway on private_net (HTTPS only)

# Health check
curl -k https://localhost/api/stateful/health

# Create session (get session_id)
curl -k -X POST https://localhost/api/stateful/session/start \
  -H "Content-Type: application/json" \
  -d '{"username":"bob","password":"secret"}'

# Response:
# {
#   "sessionId": "abc123def456",
#   "expiresIn": 3600
# }

# Use session on protected endpoint
curl -k https://localhost/api/stateful/dashboard \
  -H "X-Session-ID: abc123def456"
```

---

## Testing Behavior Differences

### Test 1: Token Verification (Stateless)

```bash
# 1. Get JWT token
TOKEN=$(curl -s -X POST http://localhost:8080/api/stateless/login \
  -H "Content-Type: application/json" \
  -d '{"username":"charlie","password":"secret"}' \
  | grep -o '"token":"[^"]*"' | cut -d'"' -f4)

# 2. Use token multiple times
for i in {1..5}; do
  echo "Request $i:"
  curl -s http://localhost:8080/api/stateless/dashboard \
    -H "Authorization: Bearer $TOKEN" | jq .
done

# OBSERVATION: Token works every time (no server memory needed)
```

### Test 2: Session Lookup (Stateful)

```bash
# 1. Create session
SESSION=$(curl -s -k -X POST https://localhost/api/stateful/session/start \
  -H "Content-Type: application/json" \
  -d '{"username":"david","password":"secret"}' \
  | grep -o '"sessionId":"[^"]*"' | cut -d'"' -f4)

# 2. Use session multiple times
for i in {1..5}; do
  echo "Request $i:"
  curl -s -k https://localhost/api/stateful/dashboard \
    -H "X-Session-ID: $SESSION" | jq .
done

# OBSERVATION: Session works if server running, lost on restart
```

### Test 3: Scaling Behavior Difference

```bash
# For stateless (should still work across instances):
# 1. Scale up (would need load balancer to test)
# 2. Requests go to different instances
# 3. Token verified by each instance directly ✅

# For stateful (would fail without affinity):
# 1. Scale up (would need load balancer to test)
# 2. Requests go to different instance
# 3. New instance has no session memory ❌
```

---

## Podman-Compose Changes

### New Services Added

```yaml
stateless-api:
  build:
    context: ../week02-stateless-stateful/phase1-mockup
    dockerfile: Dockerfile.stateless
  container_name: stateless-api
  networks:
    public_net:
      ipv4_address: 172.18.0.6
  expose:
    - "3000"
  environment:
    - NODE_ENV=production
    - SERVICE_NAME=stateless-api
    - SERVICE_PORT=3000
  depends_on:
    - nginx-gateway
  restart: unless-stopped

stateful-api:
  build:
    context: ../week02-stateless-stateful/phase1-mockup
    dockerfile: Dockerfile.stateful
  container_name: stateful-api
  networks:
    private_net:
      ipv4_address: 172.19.0.6
  expose:
    - "3001"
  environment:
    - NODE_ENV=production
    - SERVICE_NAME=stateful-api
    - SERVICE_PORT=3001
  depends_on:
    - nginx-gateway
  restart: unless-stopped
```

---

## Nginx Gateway Routes

### Public Network Route (HTTP)

```nginx
location /api/stateless/ {
    proxy_pass http://stateless-api:3000/;
    # JWT tokens pass through header → verified by backend
    # Each request is independent
}
```

### Private Network Route (HTTPS)

```nginx
location /api/stateful/ {
    proxy_pass http://stateful-api:3001/;
    # Session IDs pass through header → looked up in server memory
    # Requests use shared session state
}
```

---

## Viewing Logs

### Real-Time Logs

```bash
# Stateless API logs
podman-compose logs -f stateless-api

# Stateful API logs
podman-compose logs -f stateful-api

# Nginx gateway (shows routing)
podman-compose logs -f nginx-gateway
```

### Gateway Audit Trail

```bash
# All requests to stateless API
podman exec mockup-gateway tail -f /var/log/nginx/stateless_api.log

# All requests to stateful API
podman exec mockup-gateway tail -f /var/log/nginx/stateful_api.log

# JSON audit logs
podman exec mockup-gateway tail -f /var/log/nginx/stateless_api_audit.log | jq .
podman exec mockup-gateway tail -f /var/log/nginx/stateful_api_audit.log | jq .
```

---

## Understanding the Network Flows

### Stateless Request Flow

```
Client Browser
    ↓
POST /api/stateless/login
    ↓
[nginx gateway 172.18.0.2]
    ↓
stateless-api:3000 [172.18.0.6]
    ↓
Generate JWT (no database needed)
    ↓
Return: {"token": "eyJ..."}
    ↓
Client stores token in memory
    ↓
Later request: GET /api/stateless/dashboard
  + Header: "Authorization: Bearer eyJ..."
    ↓
[nginx gateway]
    ↓
stateless-api:3000
    ↓
Verify JWT signature (no lookup needed!)
    ↓
Return: {"user": "alice"}
    
KEY INSIGHT: Every request proves identity (stateless)
```

### Stateful Request Flow

```
Client Browser
    ↓
POST /api/stateful/session/start
    ↓
[nginx gateway 172.19.0.2 on private_net]
    ↓
stateful-api:3001 [172.19.0.6]
    ↓
Create session object in memory
sessions["abc123"] = {user: "bob", created: ...}
    ↓
Return: {"sessionId": "abc123"}
    ↓
Client stores session ID in cookie
    ↓
Later request: GET /api/stateful/dashboard
  + Header: "X-Session-ID: abc123"
    ↓
[nginx gateway]
    ↓
stateful-api:3001
    ↓
Lookup sessions["abc123"] in memory ✅
    ↓
Return: {"user": "bob"}
    
KEY INSIGHT: Server remembers client (stateful)
```

---

## Troubleshooting

### Stateless API Not Responding

```bash
# Check if service is running
podman-compose ps | grep stateless

# View logs for errors
podman-compose logs stateless-api

# Test direct connectivity
podman exec mockup-gateway curl http://stateless-api:3000/health

# Check Nginx routing
podman exec mockup-gateway curl http://localhost:8080/api/stateless/health
```

### Stateful API Not Responding

```bash
# Check if service is running
podman-compose ps | grep stateful

# View logs for errors
podman-compose logs stateful-api

# Test direct connectivity (from private_net container)
podman exec mockup-gateway curl http://stateful-api:3001/health

# Check Nginx routing (HTTPS)
podman exec mockup-gateway curl -k https://localhost/api/stateful/health
```

### JWT Token Issues

```bash
# Token expired?
# Check: Token claims and expiration time
curl -X POST http://localhost:8080/api/stateless/token/verify \
  -H "Authorization: Bearer <TOKEN>"

# Invalid signature?
# Ensure same secret key used in signing and verification
```

### Session Not Found

```bash
# Session ID invalid or expired?
# Check: Session creation time vs current time
curl -k https://localhost/api/stateful/session/inspect \
  -H "X-Session-ID: <SESSION_ID>"

# Server restart lost sessions?
# This is expected! Sessions in memory are ephemeral
# Solution: Move to Redis (Week 02 Phase 2)
```

---

## Integration with Week 01

### Shared Infrastructure

| Component | Week 01 | Week 02 |
|-----------|---------|---------|
| **Networks** | public_net, private_net | ✅ Reused |
| **Gateway** | Nginx L7 proxy | ✅ Reused with new routes |
| **Logging** | Compliance audit trail | ✅ Logs stateless/stateful API |
| **Containers** | Podman orchestration | ✅ Same podman-compose |
| **Volumes** | mime_storage | Not needed (state in memory/Redis) |

### New Learning: State Management

- Week 01: "How do I transfer files reliably?" → TCP + Protocol Design
- Week 02: "How do I remember users?" → Session Layer + State Location

---

## Performance Characteristics

### Stateless (JWT-based)

```
Request Pattern:  [User] → [Token + Data] → [Server verifies] → [Response]
                  (client carries proof of identity)

Network Cost:     One extra header (Bearer token)
Server Cost:      One crypto operation (JWT verification)
Memory Cost:      Zero (no state storage)
Scaling:          O(n) - linear (add servers, scale increases)
Failure Mode:     Server crash → User still authenticated ✅
Recommended For:  APIs, microservices, REST endpoints
```

### Stateful (Session-based)

```
Request Pattern:  [User] → [Session ID] → [Server looks up] → [Response]
                  (client carries key to state)

Network Cost:     One small header (Session ID)
Server Cost:      One memory lookup
Memory Cost:      O(users) - grows with active sessions
Scaling:          O(1) per server but needs affinity/Redis
Failure Mode:     Server crash → All sessions lost ❌
Recommended For:  Web apps, chat, shopping carts, interactive
```

---

## Next Steps

### Continue Learning

1. **Review the differences** - Run both APIs, make requests, observe logs
2. **Understand trade-offs** - When would you choose each?
3. **Test failure modes** - `docker-compose down`, restart, see what breaks
4. **Move to Phase 2** - Add Redis for distributed sessions (Week 02 Phase 2)

### Phase 2 Integration (Not Yet Implemented)

When you're ready to advance:

```bash
# Phase 2 will add:
# - PostgreSQL for user data
# - Redis for distributed session store
# - Multi-instance deployment with load balancing
# - Kubernetes-ready manifests

# Phase 2 replaces in-memory state with Redis:
# sessions["abc123"] → redis.get("session:abc123")
# Results in infinite scalability
```

---

## Verification Checklist

Before considering Week 02 Phase 1 complete on mockup-infra:

- [ ] Both services built successfully
- [ ] All services running (`podman-compose ps` shows Up)
- [ ] Stateless API returns JWT on login
- [ ] Stateless API accepts JWT on protected endpoints
- [ ] Stateful API returns session ID on login
- [ ] Stateful API looks up session on protected endpoints
- [ ] Gateway logs show routing to both services
- [ ] Request JWT token multiple times → Works always ✅
- [ ] Create session → Restart server → Session lost ❌
- [ ] Understand why each happened

---

## Files Modified/Created

```
mockup-infra/
├── podman-compose.yml           ✅ Added stateless-api + stateful-api
├── gateway/nginx.conf           ✅ Added upstream + location blocks
├── (new services auto-built)

week02-stateless-stateful/phase1-mockup/
├── Dockerfile.stateless         ✅ Created
├── Dockerfile.stateful          ✅ Created
└── src/
    ├── stateless-server.js      (unchanged)
    └── stateful-server.js       (unchanged)
```

---

## Summary

| Aspect | Status |
|--------|--------|
| **Integration** | ✅ Complete |
| **Podman Images** | ✅ Built |
| **Network Placement** | ✅ Dual-net (pub/priv) |
| **Gateway Routing** | ✅ HTTP + HTTPS |
| **Logging** | ✅ Comprehensive audit trail |
| **Service Discovery** | ✅ DNS via podman-compose |
| **Failure Testing** | 🟡 Manual |
| **Load Testing** | 🟡 Manual |
| **Redis Integration** | ⏳ Phase 2 |

---

**Ready to test Week 02 on mockup-infra?**

```bash
cd mockup-infra
podman-compose up -d
curl http://localhost:8080/api/stateless/health
curl -k https://localhost/api/stateful/health
```

Both should respond with `{"status":"healthy"}` or similar.

Good luck learning about stateless vs stateful! 🚀

---

**Last Updated:** February 13, 2026  
**Tested:** ✅ Integration complete  
**Next:** Phase 2 with Redis
