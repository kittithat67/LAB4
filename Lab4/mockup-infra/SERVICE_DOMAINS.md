# Mockup-Infra Service Domains

**Last Updated:** February 13, 2026  
**Purpose:** Clarify which services belong to which curriculum week

---

## ✅ Domain Enforcement: MIME-Server Isolated

**IMPORTANT:** mime-server (Week 01) is **NO LONGER** running by default to enforce domain boundaries.

### What Changed?
- Added Docker Compose `profiles` to separate services by curriculum week
- mime-server and mime-client now require explicit profile activation
- Default behavior: Only Week 02 and supporting services run

### Default Stack (Week 02 Focus) ✅
```bash
cd mockup-infra
podman-compose up -d

# Running services:
# ✅ stateless-api (3000)
# ✅ stateful-api (3001)
# ✅ nginx-gateway (80/443)
# ✅ public_app (80)
# ✅ intranet_api (5000)
# ❌ mime-server (DISABLED - Week 01)
```

### Optional: Include Week 01 Services
If you need to reference or review Week 01 MIME-server:
```bash
cd mockup-infra

# Run WITH Week 01 services
podman-compose --profile week01 up -d

# Or use reference profile
podman-compose --profile reference up -d

# This will include:
# ✅ mime-server (65432)
# ✅ mime-client (manual)
```

### Running Specific Services
```bash
# ONLY Week 02 APIs (without context services)
podman-compose up -d stateless-api stateful-api nginx-gateway

# ONLY Week 01 (for reference)
podman-compose --profile week01 up -d mime-server mime-client
```

---

## ✅ Service Organization

This mockup-infra contains services for multiple curriculum weeks. Understand which services to focus on for each week:

### ✅ Week 01 Services (Completed - Reference Only)

| Service | Port | Network | Status | Role |
|---------|------|---------|--------|------|
| **mime-server** | 65432 | public + private | ✅ Complete | MIME-aware file transfer (Protocol Deep-Dive) |
| **mime-client** | Manual | private | ✅ Complete | File transfer client (Manual execution only) |

**For Week 01 Students:**
- Study these services for TCP protocol and MIME-typing concepts
- All protocol documentation in `../week01-mime-typing/`

**For Week 02+ Students:**
- ⚠️ **DEPRECATED for your curriculum**
- Ignore mime-server metrics and functionality
- Do NOT modify or study these services

---

### 🚀 Week 02 Services (In Progress - PRIMARY FOCUS)

| Service | Port | Network | Status | Role |
|---------|------|---------|--------|------|
| **stateless-api** | 3000 | public_net | ✅ Active | JWT-based authentication (stateless sessions) |
| **stateful-api** | 3001 | private_net | ✅ Active | Session-based authentication (in-memory state) |
| **nginx-gateway** | 80/443 | public + private | ✅ Active | Reverse proxy & TLS termination |

**For Week 02 Students:**
- ✅ Focus **EXCLUSIVELY** on these three services
- Test endpoints via: `http://localhost:8080/api/stateless/` and `https://localhost/api/stateful/`
- Study: `WEEK02_ON_MOCKUP_INFRA.md` for detailed integration guide

**Key Learning Objectives:**
1. Understand stateless (JWT) vs stateful (session) differences
2. See how both patterns work in containerized environments
3. Observe Nginx routing to different services
4. Compare performance and scaling implications

---

### 📦 Context Services (Always Running - Supporting)

| Service | Port | Network | Status | Role |
|---------|------|---------|--------|------|
| **public_app** | 80 | public_net | ✅ Active | Demo public web application |
| **intranet_api** | 5000 | private_net | ✅ Active | Demo internal API service |

**These support the overall mockup-infra context and are not curriculum focus.**

---

## Network Architecture

```
PUBLIC NETWORK (172.18.0.0/16) - Internet-facing
│
├── nginx-gateway (172.18.0.2)
│   ├── HTTP :8080 → routes to services
│   └── HTTPS :443 → secure routes
│
├── public_app (172.18.0.3)
│   └── Simple web app (supporting)
│
├── mime-server (172.18.0.4)
│   └── Port 65432 (WEEK 01: deprecated for Week 02)
│
└── stateless-api (172.18.0.6) ✅ WEEK 02
    └── Port 3000: JWT authentication service


PRIVATE NETWORK (172.19.0.0/16) - Internal only
│
├── nginx-gateway (172.19.0.2)
│   └── Routes HTTPS :443 to private services
│
├── intranet_api (172.19.0.3)
│   └── Internal API (supporting)
│
├── mime-server (172.19.0.5)
│   └── Port 65432 (WEEK 01: deprecated for Week 02)
│
└── stateful-api (172.19.0.6) ✅ WEEK 02
    └── Port 3001: Session authentication service
```

---

## Quick Reference: What to Test

### Week 02 Health Checks (Do This)

```bash
# Stateless API - HTTP via public network
curl http://localhost:8080/api/stateless/health

# Stateful API - HTTPS via private network  
curl -k https://localhost/api/stateful/health
```

### Week 01 Reference (Ignore for Week 02)

```bash
# MIME-server - NOT part of Week 02 curriculum
# curl http://[mime-server-ip]:65432/...  # DO NOT STUDY FOR WEEK 02
```

---

## Starting Mockup-Infra

### Full Stack (All Services)
```bash
cd d:\boonsup\automation\mockup-infra
podman-compose up -d
```

### View Logs for Week 02 Services
```bash
podman-compose logs stateless-api
podman-compose logs stateful-api
podman-compose logs nginx-gateway
```

### View All Running Services
```bash
podman-compose ps

# Expected output (focus on these for Week 02):
# stateless-api    Running    Port 3000
# stateful-api     Running    Port 3001
# nginx-gateway    Running    Port 80, 443
```

### Stop All Services
```bash
podman-compose down
```

---

## Service Dependencies

```
nginx-gateway
├── depends_on: public_app, intranet_api
├── uses: stateless-api (routes /api/stateless/*)
└── uses: stateful-api (routes /api/stateful/*)

stateless-api
└── depends_on: nginx-gateway

stateful-api
└── depends_on: nginx-gateway

public_app (standalone)

intranet_api (standalone)

mime-server (standalone - no dependencies)
```

---

## Curriculum Mapping

### Choose Your Path

#### Path A: Week 02 Only (Recommended for Week 02)
```
Focus Services:
✅ stateless-api
✅ stateful-api  
✅ nginx-gateway

Skip:
⚠️ mime-server (Week 01 only)
⚠️ mime-client (Week 01 only)

Time: 1 week
```

#### Path B: Week 01 + Week 02 (Full Journey)
```
Week 01:
✅ mime-server
✅ mime-client

Week 02:
✅ stateless-api
✅ stateful-api
✅ nginx-gateway

Time: 2-3 weeks
```

#### Path C: Week 02 Production (Phase 2)
```
After mastering Phase 1 stateless/stateful concepts:
- Python/FastAPI implementation
- PostgreSQL database
- Redis session store
- Production-grade infrastructure

Time: 2 weeks additional
```

---

## Files Referenced in This Service Domain

### Week 02 Learning Resources
- `WEEK02_ON_MOCKUP_INFRA.md` - Detailed integration guide
- `../week02-stateless-stateful/WEEK02_TRANSITION.md` - Curriculum overview
- `../APP_DOMAIN_BY_WEEK.md` - Full domain structure across all weeks
- `gateway/nginx.conf` - Routing configuration to Week 02 APIs

### Week 01 Learning Resources (Reference)
- `../week01-mime-typing/` - All MIME-server source code
- `../week01-mime-typing/README.md` - Week 01 documentation

---

## Troubleshooting

### Service Not Running?
```bash
# Check status
podman-compose ps

# View logs
podman-compose logs <service-name>

# Restart single service
podman-compose restart <service-name>

# Full restart
podman-compose down
podman-compose up -d
```

### Week 02 Endpoints Returning 404?
```bash
# Check nginx routing
podman-compose logs nginx-gateway

# Verify services are up
podman-compose ps | grep -E "(stateless|stateful)"

# Test direct container access
podman exec stateless-api curl http://localhost:3000/health
podman exec stateful-api curl http://localhost:3001/health
```

### Port Already in Use?
```bash
# List processes using ports
netstat -ano | findstr :8080
netstat -ano | findstr :443

# Kill process and restart
podman-compose down
podman-compose up -d
```

---

## Summary: What This File Tells You

| Question | Answer |
|----------|--------|
| What should I study this week? | Check service table for your week |
| What services should I ignore? | Services marked for different weeks |
| How do services communicate? | See network architecture diagram |
| Where are the APIs? | Ports 3000 (stateless) and 3001 (stateful) |
| What about MIME-server? | Week 01 only, deprecated for Week 02 |
| How do I test? | Use curl commands in quick reference |
| How do I restart? | `podman-compose down && podman-compose up -d` |

---

**Last Updated:** February 13, 2026  
**Maintained by:** Curriculum Development  
**Reference:** See `APP_DOMAIN_BY_WEEK.md` for organization across all weeks
