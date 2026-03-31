# PowerShell Profile for Mockup Infrastructure
# Location: $PROFILE (usually C:\Users\<username>\Documents\PowerShell\profile.ps1)
# Or auto-load: Copy this to the mockup-infra directory as init-powershell.ps1

# ============================================================================
# ENVIRONMENT DETECTION & SETUP
# ============================================================================

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$InfraRoot = $ProjectRoot
$InfraCheck = Test-Path "$ProjectRoot\manage.py"

if ($InfraCheck) {
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║   Mockup Infrastructure - PowerShell Profile Loaded       ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Project Root: $ProjectRoot" -ForegroundColor Green
    Write-Host ""
}

# ============================================================================
# ENVIRONMENT VARIABLES
# ============================================================================

$env:PYTHONIOENCODING = "utf-8"
$env:PYTHONDONTWRITEBYTECODE = 1
$env:INFRA_ROOT = $ProjectRoot
$env:INFRA_CERTS = "$ProjectRoot\certs"
$env:INFRA_GATEWAY = "$ProjectRoot\gateway"
$env:INFRA_SERVICES = "$ProjectRoot\services"

# ============================================================================
# FUNCTIONS FOR MOCKUP-INFRA MANAGEMENT
# ============================================================================

# Navigation
function infracd {
    Set-Location $ProjectRoot
    Write-Host "📁 Changed to: $ProjectRoot" -ForegroundColor Cyan
}

# Initialize infrastructure
function minit {
    Set-Location $ProjectRoot
    python manage.py init
}

# Deploy infrastructure
function mdeploy {
    Set-Location $ProjectRoot
    python manage.py deploy
}

# Stop services
function mstop {
    Set-Location $ProjectRoot
    python manage.py stop
}

# Restart services
function mrestart {
    Set-Location $ProjectRoot
    python manage.py restart
}

# Check status
function mstatus {
    Set-Location $ProjectRoot
    python manage.py status
}

# View logs
function mlogs {
    Set-Location $ProjectRoot
    if ($args.Count -gt 0) {
        python manage.py logs $args[0]
    } else {
        python manage.py logs
    }
}

# Run tests
function mtest {
    Set-Location $ProjectRoot
    python manage.py test
}

# Generate certificates
function mcerts {
    Set-Location $ProjectRoot
    python manage.py certs
}

# Inspect TLS certificate
function mtls {
    Set-Location $ProjectRoot
    python manage.py tls
}

# Check network isolation
function misolate {
    Set-Location $ProjectRoot
    python manage.py isolate
}

# ============================================================================
# ADVANCED FUNCTIONS
# ============================================================================

# Setup infrastructure (init + deploy)
function infrasetup {
    Write-Host "🚀 Setting up Mockup Infrastructure..." -ForegroundColor Yellow
    Set-Location $ProjectRoot
    python manage.py init
    python manage.py deploy
    Write-Host "✅ Setup complete!" -ForegroundColor Green
}

# Comprehensive test suite
function infratest {
    Write-Host "🧪 Running comprehensive infrastructure tests..." -ForegroundColor Yellow
    Set-Location $ProjectRoot
    Write-Host ""
    Write-Host "=== Running manage.py test ===" -ForegroundColor Cyan
    python manage.py test
    Write-Host ""
    Write-Host "=== Running test_infra.py ===" -ForegroundColor Cyan
    python test_infra.py
    Write-Host ""
    Write-Host "✅ All tests complete!" -ForegroundColor Green
}

# Health check
function infracheck {
    Write-Host "📊 Checking Infrastructure Health..." -ForegroundColor Yellow
    Set-Location $ProjectRoot
    python manage.py status
    Write-Host ""
    python manage.py isolate
}

# Run standalone test
function teststandalone {
    Set-Location $ProjectRoot
    python test_infra.py
}

# Run all endpoint tests
function testall {
    Set-Location $ProjectRoot
    Write-Host "Running all endpoint tests..." -ForegroundColor Cyan
    mtest
    Write-Host ""
    teststandalone
}

# Quick deploy (skip init)
function infraquickdeploy {
    Write-Host "⚡ Quick deploy (existing certs)..." -ForegroundColor Yellow
    Set-Location $ProjectRoot
    python manage.py deploy
    Write-Host "✅ Deploy complete!" -ForegroundColor Green
}

# View service logs
function infralogsservice {
    param(
        [string]$Service = ""
    )
    
    if ([string]::IsNullOrEmpty($Service)) {
        Write-Host "Usage: infralogsservice <service-name>" -ForegroundColor Yellow
        Write-Host "Services: nginx-gateway, public_app, intranet_api" -ForegroundColor Cyan
        return
    }
    
    Set-Location $ProjectRoot
    python manage.py logs $Service
}

# ============================================================================
# ALIASES
# ============================================================================

# Create shorter function aliases
New-Alias -Name infra-setup -Value infrasetup -Force
New-Alias -Name infra-test -Value infratest -Force
New-Alias -Name infra-check -Value infracheck -Force
New-Alias -Name infra-logs-all -Value mlogs -Force
New-Alias -Name infra-logs-service -Value infralogsservice -Force
New-Alias -Name infra-status -Value mstatus -Force
New-Alias -Name infra-restart-all -Value mrestart -Force

# ============================================================================
# HELP INFORMATION
# ============================================================================

# Display help menu
function infrahelp {
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║        Mockup Infrastructure - PowerShell Commands        ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Navigation:" -ForegroundColor Yellow
    Write-Host "  infracd                 - Go to project root" -ForegroundColor White
    Write-Host ""
    Write-Host "Infrastructure Management:" -ForegroundColor Yellow
    Write-Host "  minit                   - Initialize infrastructure (certs + networks)" -ForegroundColor White
    Write-Host "  mdeploy                 - Deploy full stack" -ForegroundColor White
    Write-Host "  mstop                   - Stop all services" -ForegroundColor White
    Write-Host "  mrestart                - Restart all services" -ForegroundColor White
    Write-Host "  mstatus                 - Show service status" -ForegroundColor White
    Write-Host "  mlogs [service]         - View logs (or specific service)" -ForegroundColor White
    Write-Host ""
    Write-Host "Security & Configuration:" -ForegroundColor Yellow
    Write-Host "  mcerts                  - Generate/regenerate TLS certificates" -ForegroundColor White
    Write-Host "  mtls                    - Inspect TLS certificate" -ForegroundColor White
    Write-Host "  misolate                - Verify network isolation" -ForegroundColor White
    Write-Host ""
    Write-Host "Testing:" -ForegroundColor Yellow
    Write-Host "  mtest                   - Run manage.py tests" -ForegroundColor White
    Write-Host "  teststandalone          - Run test_infra.py" -ForegroundColor White
    Write-Host "  testall                 - Run both test suites" -ForegroundColor White
    Write-Host ""
    Write-Host "Advanced Functions:" -ForegroundColor Yellow
    Write-Host "  infrasetup              - Init + Deploy in one command" -ForegroundColor White
    Write-Host "  infratest               - Comprehensive test suite" -ForegroundColor White
    Write-Host "  infracheck              - Full health check" -ForegroundColor White
    Write-Host "  infraquickdeploy        - Deploy without init" -ForegroundColor White
    Write-Host ""
    Write-Host "Environment Variables:" -ForegroundColor Yellow
    Write-Host "  `$env:INFRA_ROOT        - Project root" -ForegroundColor White
    Write-Host "  `$env:INFRA_CERTS       - Certificates directory" -ForegroundColor White
    Write-Host "  `$env:INFRA_GATEWAY     - Gateway configuration directory" -ForegroundColor White
    Write-Host "  `$env:INFRA_SERVICES    - Services directory" -ForegroundColor White
    Write-Host ""
}

# Display welcome message with help tip
if ($InfraCheck) {
    Write-Host "Quick Commands:" -ForegroundColor Yellow
    Write-Host "  infra-setup             - Initialize and deploy infrastructure" -ForegroundColor Cyan
    Write-Host "  infra-test              - Run all tests" -ForegroundColor Cyan
    Write-Host "  infra-check             - Health check" -ForegroundColor Cyan
    Write-Host "  infrahelp               - Display this help menu" -ForegroundColor Cyan
    Write-Host ""
}

# ============================================================================
# POWERSHELL PROFILE INSTALLATION HELPER
# ============================================================================

# Display installation instructions
function Install-InfraProfile {
    $ProfilePath = $PROFILE
    $ProfileDir = Split-Path -Parent $ProfilePath
    
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║          PowerShell Profile Installation Helper           ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Profile Location: $ProfilePath" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "To install the Infrastructure profile permanently:" -ForegroundColor Yellow
    Write-Host "1. Create directory if needed:" -ForegroundColor White
    Write-Host "   mkdir -Path '$ProfileDir' -Force" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "2. Copy the init-powershell.ps1 to your profile:" -ForegroundColor White
    Write-Host "   Copy-Item '$(Split-Path $ProjectRoot)\init-powershell.ps1' -Destination '$ProfilePath'" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Or alternatively, add this line to your profile:" -ForegroundColor White
    Write-Host "   . '$(Split-Path $ProjectRoot)\init-powershell.ps1'" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "3. Reload PowerShell or run: . `$PROFILE" -ForegroundColor White
    Write-Host ""
}

# ============================================================================
# PROMPT CUSTOMIZATION (Optional)
# ============================================================================

# Customize PowerShell prompt to show we're in infra environment
if ($InfraCheck) {
    function prompt {
        $location = Get-Location
        $lastExitCode = $LASTEXITCODE
        
        # Show directory
        Write-Host "🏗️  " -NoNewline -ForegroundColor Magenta
        Write-Host "$location " -NoNewline -ForegroundColor Cyan
        
        # Show git branch if available
        try {
            $branch = git rev-parse --abbrev-ref HEAD 2>$null
            if ($branch) {
                Write-Host "[$branch] " -NoNewline -ForegroundColor Yellow
            }
        } catch {}
        
        # Show status indicator
        if ($lastExitCode -eq 0) {
            Write-Host "✓ " -NoNewline -ForegroundColor Green
        } else {
            Write-Host "✗ " -NoNewline -ForegroundColor Red
        }
        
        return "> "
    }
}

# ============================================================================
# END OF POWERSHELL PROFILE
# ============================================================================
