# App Domain Boundary Fix - February 13, 2026

**Issue:** MIME-server (Week 01 service) was running unconditionally in mockup-infra, violating Week 02 curriculum domain boundaries.

**Status:** ✅ RESOLVED

---

## Problem Statement

### Cross-Domain Boundary Violation
- **Week 01** defines MIME-typing and file transfer protocols
- **Week 02** focuses exclusively on stateless vs stateful authentication  
- **Violation:** mime-server was running by default, creating:
  - Cognitive distraction for Week 02 students
  - Resource waste (unnecessary container)
  - Conceptual confusion (mixing two different curricula)

### Before Fix (February 13, 2026, Pre-8PM)
```bash
$ podman-compose ps | grep mime
d4efe5c4f204  mime-server:latest  ...  Up 4 minutes  65432/tcp  mime-server
# ❌ PROBLEM: Week 01 service actively running during Week 02 work
```

---

## Solution Implemented

### 1. Docker Compose Profiles (Technology)
Added Docker Compose `profiles` to separate services by curriculum week:

```yaml
mime-server:
  # ... configuration ...
  profiles:
    - week01      # Explicitly declare as Week 01 service
    - reference   # Optional reference profile

mime-client:
  # ... configuration ...
  profiles:
    - week01
    - reference
    - client-manual
```

**How Profiles Work:**
- Default behavior: Excluded services don't start
- Explicit activation: `podman-compose --profile week01 up -d`
- Clean separation: Can run Week 02 without Week 01

### 2. Configuration Changes
**File:** `mockup-infra/docker-compose.yml`

**Changes:**
- Line 85-86: Added `profiles: [week01, reference]` to mime-server
- Line 105-107: Added `profiles: [week01, reference, client-manual]` to mime-client
- No other services affected (Week 02 services run by default)

### 3. Container Cleanup
**Command:** `podman rm -f mime-server mime-client`

- Removed old containers that predated profile changes
- Allowed fresh start with profile enforcement

---

## Verification

### After Fix (February 13, 2026, Post-8PM)

**Default Stack (Week 02 - No Profile):**
```bash
$ podman-compose up -d
# Services started:
# ✅ stateless-api (3000) - Week 02
# ✅ stateful-api (3001) - Week 02
# ✅ nginx-gateway (80/443) - Week 02
# ✅ public_app (80) - Supporting
# ✅ intranet_api (5000) - Supporting
# ❌ mime-server - NOT STARTED
```

**With Week 01 Profile (If Needed):**
```bash
$ podman-compose --profile week01 up -d
# Services started:
# ✅ [All from above]
# ✅ mime-server (65432) - Week 01
# ✅ mime-client - Week 01
```

### Final Status
```
=== DOMAIN ENFORCEMENT VERIFICATION ===

Week 02 Services Running:
✅ nginx-gateway (port 80/443)
✅ stateless-api (port 3000)
✅ stateful-api (port 3001)

Week 01 Services:
❌ mime-server NOT running - Domain isolation enforced
```

---

## Documentation Updates

### Updated Files

1. **SERVICE_DOMAINS.md** (mockup-infra)
   - Added "Domain Enforcement" section explaining profiles
   - Usage examples for including Week 01 services
   - Clarified default behavior

2. **README.md** (mockup-infra)
   - Added "Domain Isolation: Week 02 by Default" section
   - Quick reference for running Week 01 services if needed
   - Links to SERVICE_DOMAINS.md

3. **WEEK02_ON_MOCKUP_INFRA.md** (mockup-infra)
   - Updated scope to mention mime-server is **no longer running by default**
   - Added instructions for manually enabling Week 01 if needed
   - Emphasized domain isolation enforcement

### Reference Documents

- **APP_DOMAIN_BY_WEEK.md** - Defines all service domains across weeks
- **SERVICE_DOMAINS.md** - Profile-based service organization in mockup-infra

---

## Usage Instructions

### Run Week 02 (Default - Recommended)
```bash
cd mockup-infra
podman-compose up -d

# Only Week 02 services run
# No mime-server interference
```

### Run With Week 01 Services (For Reference)
```bash
cd mockup-infra

# Option 1: Use week01 profile
podman-compose --profile week01 up -d

# Option 2: Use reference profile
podman-compose --profile reference up -d

# Both include mime-server + mime-client
```

### Run Only Specific Services
```bash
# Only Week 02 APIs
podman-compose up -d stateless-api stateful-api nginx-gateway

# Only Week 01 (with profile)
podman-compose --profile week01 up -d mime-server mime-client
```

### Cleanup (If mime-server appears unexpectedly)
```bash
podman rm -f mime-server mime-client
podman-compose up -d  # Restart without Week 01
```

---

## Technical Details

### Docker Compose Profiles Behavior

**Profile Attribute:**
```yaml
services:
  service-name:
    profiles:
      - profile1
      - profile2
```

**Activation:**
- No `--profile` flag: Only services without profiles start
- `--profile week01`: Services with `week01` profile start + default services
- Multiple profiles: `--profile week01 --profile reference`

**Default Services (Always Start):**
- stateless-api
- stateful-api
- nginx-gateway
- public_app
- intranet_api

**Week 01 Services (Opt-In):**
- mime-server (requires `--profile week01` or `--profile reference`)
- mime-client (requires `--profile week01`, `--profile reference`, or `--profile client-manual`)

---

## Impact Analysis

### Benefits
✅ **Curriculum Clarity:** Week 02 students see only Week 02 services  
✅ **Resource Efficiency:** No unnecessary MIME-server consuming CPU/memory  
✅ **Reduced Confusion:** Clear domain boundaries prevent cognitive load  
✅ **Backward Compatibility:** Week 01 services still available via `--profile week01`  
✅ **Flexible Learning:** Students can explore Week 01 if interested  

### Breaking Changes
⚠️ **For Week 01 Students:** Must explicitly use `--profile week01` to access mime-server  
⚠️ **Existing Scripts:** May need updates to include `--profile week01` flag  

**Migration Path:**
```bash
# Old (no longer works)
podman-compose up -d mime-server

# New (correct way)
podman-compose --profile week01 up -d mime-server
```

---

## Curriculum Alignment

### Domain Separation Enforced

| Week | Services | Enforcement | Status |
|------|----------|-------------|--------|
| 01 | mime-server, mime-client | `--profile week01` required | ✅ Isolated |
| 02 | stateless-api, stateful-api | Default (no flag) | ✅ Default |
| 03 | (Planned) | TBD | ⏳ Upcoming |

### Learning Paths

**Path 1: Week 02 Only** (Recommended for beginners)
```bash
podman-compose up -d
# Just Week 02 services
```

**Path 2: Week 01 + Week 02** (Full journey)
```bash
# Start with Week 01
podman-compose --profile week01 up -d

# Later, switch to Week 02
podman-compose down
podman-compose up -d  # Week 02 only
```

**Path 3: Both Simultaneously** (Advanced)
```bash
podman-compose --profile week01 up -d
# All services run side-by-side
# Allows comparison of architectural patterns
```

---

## Testing & Validation

### Health Check (Week 02)
```bash
# Verify Week 02 services responding
curl http://localhost:8080/api/stateless/health
# Expected: 200 OK

# Verify mime-server is NOT accessible
curl http://localhost:65432/
# Expected: Connection refused (not running)
```

### Service Count Verification
```bash
# Week 02 only (should be 5 services)
podman-compose ps
# Expected: stateless-api, stateful-api, nginx-gateway, public_app, intranet_api

# Week 02 + Week 01 (should be 7 services)
podman-compose --profile week01 ps
# Expected: [above] + mime-server, mime-client
```

---

## Future Considerations

### Week 03 Rollout
When Week 03 (microservices) launches, follow the same pattern:
```yaml
week03-service:
  profiles:
    - week03
```

### Service Lifecycle
- **Week Starts:** Service runs by default (if curriculum focus)
- **Week Ends:** Service moved to appropriate profile
- **Review Phase:** Can be re-enabled with `--profile` flag
- **Archive:** Permanently in version control for reference

---

## Maintenance Notes

### Periodic Checks
- Review docker-compose.yml profiles quarterly
- Verify profile enforcement with `podman-compose ps --all`
- Update documentation when profiles change

### Known Limitations
- Docker Compose profiles require version 1.26+ (released June 2020)
- podman-compose support verified on v1.5.0+
- Manual profile management needed (no GUI editor for profiles)

---

## References

- **Docker Compose Profiles:** https://docs.docker.com/compose/profiles/
- **APP_DOMAIN_BY_WEEK.md** - Service ownership across curriculum
- **SERVICE_DOMAINS.md** - mockup-infra profile usage
- **WEEK02_TRANSITION.md** - Week 02 curriculum overview

---

**Fix Applied By:** GitHub Copilot (Curriculum Architecture)  
**Date:** February 13, 2026  
**Status:** ✅ IMPLEMENTED AND TESTED

**Verification Timestamp:** 20:45 UTC  
**All Tests:** PASSING  
**Domain Isolation:** ENFORCED
