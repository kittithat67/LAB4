# 🖥️ Shell Integration Guide

This guide explains how to set up and use shell integration for the Mockup Infrastructure project across Windows, Linux, and macOS.

## Quick Reference

| Shell | Setup | Use | Features |
|-------|-------|-----|----------|
| **PowerShell** | `. .\setup-shell.ps1` | `minit`, `mdeploy`, `mtest` | Colored output, 20+ functions |
| **Bash/Git Bash** | `source .bashrc` | `minit`, `mdeploy`, `mtest` | 15+ functions, aliases |
| **Windows CMD** | `setup-shell.bat` | `manage init`, `manage deploy` | Command parser, help menu |

---

## 🔵 PowerShell (Windows)

### Installation

**Option A: Permanent Installation (Recommended)**

```powershell
# Navigate to mockup-infra directory
cd D:\boonsup\automation\mockup-infra

# Run setup script
. .\setup-shell.ps1

# Select option 1 from the menu
```

This will:
- Install `init-powershell.ps1` to your PowerShell Profile
- Make commands available in all future PowerShell windows
- Set up custom prompt with git branch detection

**Option B: One-Session Installation**

```powershell
# Navigate to mockup-infra directory
. .\init-powershell.ps1

# Now use commands in this window only
minit
```

### Available Commands

**Infrastructure Management:**
```powershell
minit                    # Initialize infrastructure
  ├─ Generate TLS certificates
  ├─ Create public_net (172.18.0.0/16)
  └─ Create private_net (172.19.0.0/16)

mdeploy                  # Deploy all services
  ├─ Start nginx-gateway
  ├─ Start public_app
  └─ Start intranet_api

mstop                    # Stop all services
mrestart                 # Restart all services
mstatus                  # Check service status
mlogs [service]          # View logs (optional: specific service)
```

**Security & Configuration:**
```powershell
mcerts                   # Generate/regenerate TLS certificates
mtls                     # Inspect TLS certificate details
misolate                 # Verify network isolation
```

**Testing:**
```powershell
mtest                    # Run all endpoint tests
infratest                # Run tests with detailed output
```

**Advanced:**
```powershell
infrasetup               # Full setup (init + deploy)
infracheck               # Health check all services
infraquickdeploy         # Deploy without init
infralogsservice         # View specific service logs (interactive)
```

### Examples

```powershell
# Full initialization and deployment
minit
mdeploy
mtest

# Or use combined command
infrasetup

# Check status
mstatus

# View logs for specific service
mlogs public_app

# Run comprehensive test
infratest

# Health check
infracheck
```

### Features

✅ **Colored Output**
- Yellow headers for major operations
- Cyan for information and prompts
- Green for success messages
- Red for errors

✅ **Custom Prompt**
Shows:
- Current directory
- Git branch name (if in a git repo)
- ⚙️ if infrastructure is running
- 🔄 if services need restart

Example: `D:\automation\mockup-infra [main] ⚙️ `

✅ **25+ Functions & Aliases**
- Quick commands: `minit`, `mdeploy`, `mtest`
- Descriptive functions: `infrasetup`, `infratest`, `infracheck`
- Aliases for alternative access: `infra-setup`, `infra-deploy`

---

## 🟢 Bash / Git Bash / WSL (Linux-like)

### Installation

**Copy .bashrc to your home directory:**

```bash
# From mockup-infra directory
cp .bashrc ~/.bashrc

# Source it
source ~/.bashrc
```

**For Git Bash on Windows:**
```bash
# Make sure .bashrc loads on startup
cat >> ~/.bash_profile << 'EOF'
if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi
EOF
```

### Available Commands

**Infrastructure Management:**
```bash
minit                    # Initialize infrastructure
mdeploy                  # Deploy all services
mstop                    # Stop services
mrestart                 # Restart services
mstatus                  # Show status
mlogs [service]          # View logs
```

**Security:**
```bash
mcerts                   # Generate certificates
mtls                     # Inspect TLS
misolate                 # Verify isolation
```

**Testing:**
```bash
mtest                    # Run tests
```

**Advanced Functions:**
```bash
infra-setup              # Full setup (init + deploy)
infra-test               # Run tests with details
infra-check              # Health check
infra-logs-service       # View specific service logs
infra-restart-all        # Restart all services
```

### Examples

```bash
# Quick initialization
minit
mdeploy
mtest

# Or use longer function names
infra-setup
infra-test
infra-check

# View specific service logs
infra-logs-service public_app
infra-logs-service intranet_api

# Comprehensive test
infra-test
```

### Features

✅ **OS Detection**
- Automatically detects Windows Bash, Linux, macOS
- Sets appropriate environment variables
- Adjusts commands for platform differences

✅ **Environment Variables**
- `PYTHONIOENCODING=utf-8` for Windows compatibility
- `INFRA_ROOT` for project directory
- `INFRA_CERTS`, `INFRA_GATEWAY`, `INFRA_SERVICES` paths

✅ **Welcome Message**
Shows available commands and functions on shell startup

---

## 🟡 Windows CMD (Command Prompt)

### Setup

**Interactive Setup:**
```cmd
setup-shell.bat
```

This displays a menu with options:
1. Use manage.bat from current directory (recommended)
2. Add to Windows PATH (advanced)
3. View setup instructions

### Usage

**From the mockup-infra directory:**

```cmd
manage init              # Initialize
manage deploy            # Deploy
manage stop              # Stop services
manage restart           # Restart services
manage status            # Show status
manage logs [service]    # View logs
manage certs             # Generate certificates
manage tls               # Inspect TLS
manage isolate           # Verify isolation
manage test              # Run tests
manage test-standalone   # Run test_infra.py
manage test-all          # Run both test methods
manage help              # Show help menu
```

### Examples

```cmd
# Basic workflow
manage init
manage deploy
manage test

# Check status and logs
manage status
manage logs

# Health check
manage isolate
manage tls

# Run all tests
manage test-all
```

### Features

✅ **Command Parsing**
- Recognizes commands case-insensitively
- Provides detailed help with examples
- Supports service name with logs command

✅ **Error Handling**
- Checks if manage.py exists before running
- Validates project directory
- Clear error messages

✅ **Help Menu**
- Built-in help system
- Command examples
- Usage instructions

---

## 📊 Comparison Table

| Feature | PowerShell | Bash | CMD |
|---------|-----------|------|-----|
| **Setup Time** | 2 min | 1 min | 1 min |
| **Colored Output** | Yes | Optional | No |
| **Available Functions** | 25+ | 15+ | 10+ |
| **Custom Prompt** | Yes | Yes | No |
| **Platform** | Windows | Linux/WSL/Git Bash | Windows |
| **Easy to Use** | Yes | Yes | Yes |
| **Recommended** | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |

---

## 🎯 Workflow Examples

### Complete Initialization (All Shells)

**PowerShell:**
```powershell
minit        # ~15 seconds
mdeploy      # ~20 seconds
mtest        # ~10 seconds
```

**Bash:**
```bash
minit        # ~15 seconds
mdeploy      # ~20 seconds
mtest        # ~10 seconds
```

**CMD:**
```cmd
manage init      # ~15 seconds
manage deploy    # ~20 seconds
manage test      # ~10 seconds
```

### Daily Development (PowerShell Example)

```powershell
# Morning check
mstatus

# Run tests
mtest

# View logs if needed
mlogs

# Evening restart
mrestart

# Final verification
infracheck
```

### Troubleshooting Workflow

```powershell
# Check what's running
mstatus

# View all logs
mlogs

# View specific service logs
mlogs nginx-gateway

# Restart if needed
mrestart

# Re-run tests
mtest
```

---

## 🔧 Troubleshooting

### PowerShell: Commands not found after installation

**Solution:**
```powershell
# Reload your profile
. $PROFILE

# Or close and reopen PowerShell
```

### Bash: .bashrc not loading automatically

**Solution for Git Bash:**
```bash
# Edit ~/.bash_profile or ~/.bashrc
nano ~/.bash_profile

# Add this line
source ~/.bashrc
```

### Command not found in any shell

**Solution:**
```
# Make sure you're in the mockup-infra directory
# PowerShell: . .\init-powershell.ps1
# Bash: source ./.bashrc
# CMD: Already available via manage.bat
```

### Line ending issues (Git Bash on Windows)

**Solution:**
```bash
# Convert line endings
dos2unix .bashrc init-powershell.ps1
# Or
sed -i 's/\r$//' .bashrc
```

---

## 📝 Setup Files Reference

| File | Purpose | Shell |
|------|---------|-------|
| `.bashrc` | Shell functions and aliases | Bash/Git Bash/WSL |
| `init-powershell.ps1` | PowerShell profile script | PowerShell |
| `init-cmd.bat` | CMD batch functions | Windows CMD |
| `manage.bat` | Command wrapper | Windows CMD |
| `setup-shell.bat` | Interactive setup wizard | Windows CMD |
| `setup-shell.ps1` | Interactive PowerShell setup | PowerShell |
| `manage.py` | Core management CLI | All shells |
| `test_infra.py` | Test script | All shells |

---

## 🚀 Best Practices

1. **Use PowerShell** on Windows - most features, best experience
2. **Use Git Bash** if you prefer Linux-style commands
3. **Use CMD** if you need to stay native (less features)
4. **Always activate in the mockup-infra directory** - commands assume this
5. **Run `mtest` after deployment** - verify everything works
6. **Check logs if tests fail** - `mlogs` shows all service output

---

## 🎓 Learning Path

1. Start with `minit` - learn about initialization
2. Try `mdeploy` - understand service deployment
3. Use `mstatus` and `mlogs` - observe what's running
4. Run `mtest` - verify infrastructure works
5. Explore `mtls` and `misolate` - dive into security features
6. Read logs with `mlogs [service]` - debug individual services

---

## 📚 Additional Resources

- [README.md](./README.md) - Full project documentation
- [manage.py](./manage.py) - Core management code
- [test_infra.py](./test_infra.py) - Test implementation
- [init-powershell.ps1](./init-powershell.ps1) - PowerShell functions
- [.bashrc](./.bashrc) - Bash functions
- [manage.bat](./manage.bat) - CMD wrapper

---

**Last Updated:** February 2026
**Status:** ✅ Production Ready
**Platforms:** Windows (PowerShell/CMD), Linux, macOS, WSL

---
