# Mockup Infrastructure - PowerShell Setup Helper
# Run: . .\setup-shell.ps1

$ProjectRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$LocalProfile = Join-Path $ProjectRoot "init-powershell.ps1"

function Show-MainMenu {
    Clear-Host
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  Mockup Infrastructure - Shell Integration Setup          ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Project Root: $ProjectRoot" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Select option:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  1 = PowerShell Profile Setup (Permanent Installation)"
    Write-Host "  2 = Quick Load (This Session Only)"
    Write-Host "  3 = View Setup Instructions"
    Write-Host "  4 = Test Script (Verify Installation)"
    Write-Host "  5 = Uninstall from Profile"
    Write-Host "  6 = Exit"
    Write-Host ""
    
    $choice = Read-Host "Enter choice (1-6)"
    return $choice
}

function Install-ToProfile {
    Write-Host ""
    Write-Host "Installing to PowerShell Profile..." -ForegroundColor Yellow
    
    # Check if profile exists
    if (-not (Test-Path $PROFILE) -and -not (Test-Path (Split-Path -Parent $PROFILE))) {
        New-Item -ItemType Directory -Path (Split-Path -Parent $PROFILE) -Force | Out-Null
    }
    
    # Create source line
    $sourceLine = @"
# Mockup Infrastructure Integration
if (Test-Path "$LocalProfile") {
    . "$LocalProfile"
}
"@
    
    # Check if already installed
    if (Test-Path $PROFILE) {
        $profileContent = Get-Content $PROFILE -Raw
        if ($profileContent -contains "Mockup Infrastructure Integration") {
            Write-Host "✓ Already installed in profile!" -ForegroundColor Green
            Write-Host ""
            Write-Host "To reload: . `$PROFILE" -ForegroundColor Cyan
            return
        }
    }
    
    # Append to profile
    try {
        Add-Content -Path $PROFILE -Value "`n$sourceLine" -Force
        Write-Host "✓ Installation successful!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Profile location: $PROFILE" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "To activate now, run:" -ForegroundColor Yellow
        Write-Host "  . `$PROFILE" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "OR close and reopen PowerShell" -ForegroundColor Yellow
    }
    catch {
        Write-Host "✗ Failed to install: $_" -ForegroundColor Red
        Write-Host ""
        Write-Host "Try running PowerShell as Administrator" -ForegroundColor Yellow
    }
}

function Load-ThisSession {
    Write-Host ""
    Write-Host "Loading infrastructure commands..." -ForegroundColor Yellow
    
    try {
        . $LocalProfile
        Write-Host "✓ Loaded successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Available commands:" -ForegroundColor Cyan
        Write-Host "  minit, mdeploy, mstop, mrestart, mstatus" -ForegroundColor White
        Write-Host "  mlogs, mtest, mcerts, mtls, misolate" -ForegroundColor White
        Write-Host ""
        Write-Host "Try: minit" -ForegroundColor Yellow
    }
    catch {
        Write-Host "✗ Failed to load: $_" -ForegroundColor Red
    }
}

function Show-Instructions {
    Clear-Host
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║           PowerShell Setup Instructions                   ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "OPTION A: Permanent Installation (Recommended)" -ForegroundColor Yellow
    Write-Host "───────────────────────────────────────────────" -ForegroundColor White
    Write-Host "1. Run this script:" -ForegroundColor Cyan
    Write-Host "   . .\setup-shell.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "2. Select option 1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "3. New commands available in all PowerShell windows:" -ForegroundColor Cyan
    Write-Host "   minit, mdeploy, mtest, mstatus, etc." -ForegroundColor White
    Write-Host ""
    Write-Host ""
    
    Write-Host "OPTION B: One-Time Use (This Session Only)" -ForegroundColor Yellow
    Write-Host "───────────────────────────────────────────────" -ForegroundColor White
    Write-Host "Run directly in PowerShell:" -ForegroundColor Cyan
    Write-Host "   . .\init-powershell.ps1" -ForegroundColor White
    Write-Host ""
    Write-Host "Commands only available in this window" -ForegroundColor Gray
    Write-Host ""
    Write-Host ""
    
    Write-Host "AVAILABLE COMMANDS" -ForegroundColor Yellow
    Write-Host "───────────────────────────────────────────────" -ForegroundColor White
    Write-Host ""
    Write-Host "Infrastructure:" -ForegroundColor Cyan
    Write-Host "  minit             Initialize (generate certs, create networks)" -ForegroundColor White
    Write-Host "  mdeploy           Deploy all services" -ForegroundColor White
    Write-Host "  mstop             Stop all services" -ForegroundColor White
    Write-Host "  mrestart          Restart all services" -ForegroundColor White
    Write-Host "  mstatus           Show running containers" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Monitoring & Logs:" -ForegroundColor Cyan
    Write-Host "  mlogs             View all container logs" -ForegroundColor White
    Write-Host "  mlogs <service>   View specific service logs" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Testing & Verification:" -ForegroundColor Cyan
    Write-Host "  mtest             Run all tests" -ForegroundColor White
    Write-Host "  mcerts            Regenerate TLS certificates" -ForegroundColor White
    Write-Host "  mtls              Inspect certificate info" -ForegroundColor White
    Write-Host "  misolate          Verify network isolation" -ForegroundColor White
    Write-Host ""
    
    Write-Host "Advanced:" -ForegroundColor Cyan
    Write-Host "  infrasetup        Full setup (init + deploy)" -ForegroundColor White
    Write-Host "  infratest         Run comprehensive tests" -ForegroundColor White
    Write-Host "  infracheck        Health check all services" -ForegroundColor White
    Write-Host ""
    
    Write-Host "QUICK START" -ForegroundColor Yellow
    Write-Host "───────────────────────────────────────────────" -ForegroundColor White
    Write-Host ""
    Write-Host ". .\setup-shell.ps1      # Install" -ForegroundColor Cyan
    Write-Host ". `$PROFILE               # Reload profile" -ForegroundColor Cyan
    Write-Host "minit                     # Initialize" -ForegroundColor Cyan
    Write-Host "mdeploy                   # Deploy" -ForegroundColor Cyan
    Write-Host "mtest                     # Run tests" -ForegroundColor Cyan
    Write-Host ""
    
    Read-Host "Press Enter to continue"
}

function Test-Installation {
    Clear-Host
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║              Testing Installation                         ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    # Check if init-powershell.ps1 exists
    if (-not (Test-Path $LocalProfile)) {
        Write-Host "✗ init-powershell.ps1 not found!" -ForegroundColor Red
        Write-Host "  Expected: $LocalProfile" -ForegroundColor Yellow
        Read-Host "Press Enter to continue"
        return
    }
    
    Write-Host "✓ init-powershell.ps1 found" -ForegroundColor Green
    Write-Host ""
    
    # Check profile installation
    if (Test-Path $PROFILE) {
        $content = Get-Content $PROFILE -Raw
        if ($content -match "Mockup Infrastructure") {
            Write-Host "✓ Installed in PowerShell Profile" -ForegroundColor Green
            Write-Host "  Profile: $PROFILE" -ForegroundColor Cyan
        }
        else {
            Write-Host "⚠ Not yet installed in PowerShell Profile" -ForegroundColor Yellow
            Write-Host "  Run option 1 to install" -ForegroundColor Cyan
        }
    }
    else {
        Write-Host "⚠ PowerShell Profile not yet created" -ForegroundColor Yellow
        Write-Host "  It will be created on first install" -ForegroundColor Cyan
    }
    
    Write-Host ""
    Write-Host "Testing command availability:" -ForegroundColor Yellow
    Write-Host ""
    
    # Load and test
    . $LocalProfile 2>&1 | Out-Null
    
    $commands = @('minit', 'mdeploy', 'mtest', 'mstatus', 'mlogs')
    $allGood = $true
    
    foreach ($cmd in $commands) {
        if (Get-Command $cmd -ErrorAction SilentlyContinue) {
            Write-Host "✓ $cmd available" -ForegroundColor Green
        }
        else {
            Write-Host "✗ $cmd not found" -ForegroundColor Red
            $allGood = $false
        }
    }
    
    Write-Host ""
    
    if ($allGood) {
        Write-Host "✓ All commands available!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Ready to use: minit, mdeploy, mstop, mtest, etc." -ForegroundColor Cyan
    }
    
    Read-Host "Press Enter to continue"
}

function Remove-FromProfile {
    Write-Host ""
    
    if (-not (Test-Path $PROFILE)) {
        Write-Host "No profile found to uninstall from." -ForegroundColor Yellow
        Read-Host "Press Enter to continue"
        return
    }
    
    Write-Host "Warning: This will remove the infrastructure integration from your profile." -ForegroundColor Yellow
    Write-Host "Profile: $PROFILE" -ForegroundColor Cyan
    Write-Host ""
    
    $confirm = Read-Host "Continue with uninstall? (yes/no)"
    
    if ($confirm -eq "yes") {
        $content = Get-Content $PROFILE -Raw
        $newContent = $content -replace @"
`n# Mockup Infrastructure Integration
if \(Test-Path "$LocalProfile"\) \{
    \. "$LocalProfile"
\}
"@, ""
        
        Set-Content -Path $PROFILE -Value $newContent -Force
        Write-Host "✓ Uninstalled from profile" -ForegroundColor Green
    }
    
    Read-Host "Press Enter to continue"
}

# Main Loop
do {
    $choice = Show-MainMenu
    
    switch ($choice) {
        "1" { Install-ToProfile }
        "2" { Load-ThisSession }
        "3" { Show-Instructions }
        "4" { Test-Installation }
        "5" { Remove-FromProfile }
        "6" { break }
        default {
            Write-Host "Invalid choice. Please try again." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
} while ($choice -ne "6")

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host ""
