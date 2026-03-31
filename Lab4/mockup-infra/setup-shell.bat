@echo off
REM Shell Integration Setup Script for Mockup Infrastructure
REM Helps configure .bashrc and PowerShell profile for quick command access

setlocal enabledelayedexpansion

set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR:~0,-1%

cls
echo.
echo ========================================================================
echo  Mockup Infrastructure - Shell Integration Setup
echo ========================================================================
echo.
echo This script helps you set up shell integration for quick access to
echo infrastructure commands.
echo.
echo Detected location: %PROJECT_ROOT%
echo.

:menu
echo.
echo What shell are you using?
echo.
echo  1 = PowerShell (Recommended on Windows)
echo  2 = Git Bash / WSL / MSYS2 (Linux-like)
echo  3 = CMD (Windows Command Prompt)
echo  4 = View all setup instructions
echo  5 = Exit
echo.

set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" goto setup_powershell
if "%choice%"=="2" goto setup_bash
if "%choice%"=="3" goto setup_cmd
if "%choice%"=="4" goto view_all
if "%choice%"=="5" goto end
goto menu

REM ========================================================================
REM POWERSHELL SETUP
REM ========================================================================

:setup_powershell
cls
echo.
echo ========================================================================
echo  PowerShell Profile Setup
echo ========================================================================
echo.
echo The init-powershell.ps1 script provides these features:
echo  * 25+ functions for infrastructure management
echo  * Colored output for better readability
echo  * Custom prompt with git branch detection
echo  * Quick aliases: minit, mdeploy, mtest, mstatus, etc.
echo.
echo Setup Options:
echo.
echo  A = Install to PowerShell Profile (Permanent)
echo  B = Show how to manually install
echo  C = Test the script (one-time use)
echo  D = Back to menu
echo.

set /p ps_choice="Enter your choice (A-D): "

if /i "%ps_choice%"=="A" goto ps_install
if /i "%ps_choice%"=="B" goto ps_manual
if /i "%ps_choice%"=="C" goto ps_test
if /i "%ps_choice%"=="D" goto menu
goto setup_powershell

:ps_install
echo.
echo This requires opening PowerShell as Administrator.
echo A new PowerShell window will open.
echo.
pause
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-NoExit','-Command','cd \"%PROJECT_ROOT%\"; . .\init-powershell.ps1; Install-InfraProfile'"
goto setup_powershell

:ps_manual
echo.
echo Manual PowerShell Setup Instructions:
echo.
echo 1. Open PowerShell in the current directory:
echo    Press Win+X, select "Windows PowerShell (Admin)"
echo.
echo 2. Run this command to find your profile location:
echo    Write-Host $PROFILE
echo.
echo 3. Copy init-powershell.ps1 to your profile directory:
echo    copy init-powershell.ps1 "$PROFILE"
echo    (Replace $PROFILE with actual path from step 2)
echo.
echo 4. Update PowerShell Execution Policy (if needed):
echo    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
echo.
echo 5. Reload your PowerShell profile:
echo    . $PROFILE
echo.
echo 6. You're ready! Use commands like: minit, mdeploy, mtest
echo.
pause
goto setup_powershell

:ps_test
echo.
echo Loading PowerShell profile for this session...
echo.
powershell -NoExit -Command "cd '%PROJECT_ROOT%'; . .\init-powershell.ps1; Write-Host 'Profile loaded! Use: minit, mdeploy, mtest, etc.' -ForegroundColor Green; Write-Host 'Type: help-infra' -ForegroundColor Cyan"
goto setup_powershell

REM ========================================================================
REM BASH SETUP
REM ========================================================================

:setup_bash
cls
echo.
echo ========================================================================
echo  Bash / Git Bash / WSL Setup
echo ========================================================================
echo.
echo The .bashrc script provides:
echo  * 15+ functions for infrastructure management
echo  * Quick aliases: minit, mdeploy, mtest, mstatus, etc.
echo  * OS detection (Windows, Linux, macOS)
echo  * Environment variable setup
echo.
echo Setup Options:
echo.
echo  A = Show installation instructions
echo  B = Copy .bashrc to your home directory
echo  C = Back to menu
echo.

set /p bash_choice="Enter your choice (A-C): "

if /i "%bash_choice%"=="A" goto bash_manual
if /i "%bash_choice%"=="B" goto bash_copy
if /i "%bash_choice%"=="C" goto menu
goto setup_bash

:bash_manual
echo.
echo Manual Bash Setup Instructions:
echo.
echo For Git Bash (Windows):
echo  1. Copy .bashrc file to your home directory:
echo     cp .bashrc ~/%%.bashrc
echo.
echo  2. Add to your Git Bash startup (usually: %%USERPROFILE%%\.bash_profile):
echo     if [ -f ~/.bashrc ]; then source ~/.bashrc; fi
echo.
echo For WSL (Windows Subsystem for Linux):
echo  1. In WSL, run: cp .bashrc ~/ 
echo  2. Then: source ~/.bashrc
echo.
echo For MSYS2:
echo  1. Copy to: C:\msys64\home\%%USERNAME%%\.bashrc
echo  2. Create/edit .bash_profile to source .bashrc
echo.
echo Available commands:
echo   minit          - Initialize infrastructure
echo   mdeploy        - Deploy all services
echo   mtest          - Run tests
echo   mstatus        - Show service status
echo   mlogs          - View container logs
echo.
echo Then reload: source ~/.bashrc
echo.
pause
goto setup_bash

:bash_copy
echo.
echo Note: This copies .bashrc to current directory.
echo For proper setup, read the manual instructions.
echo.
echo Copy .bashrc to home directory now? (y/n)
set /p bash_copy="Your choice: "

if /i "%bash_copy%"=="y" (
    echo Copying .bashrc...
    copy .bashrc "%USERPROFILE%"
    echo Done! Run: source ~/.bashrc
) else (
    echo Skipped.
)
goto setup_bash

REM ========================================================================
REM CMD SETUP
REM ========================================================================

:setup_cmd
cls
echo.
echo ========================================================================
echo  Windows CMD Setup
echo ========================================================================
echo.
echo The manage.bat provides:
echo  * All infrastructure management commands
echo  * Help menu with examples
echo  * Proper environment setup
echo.
echo Setup Options:
echo.
echo  A = Use manage.bat from current directory (Recommended)
echo  B = Add to Windows PATH (Advanced)
echo  C = Back to menu
echo.

set /p cmd_choice="Enter your choice (A-C): "

if /i "%cmd_choice%"=="A" goto cmd_current
if /i "%cmd_choice%"=="B" goto cmd_path
if /i "%cmd_choice%"=="C" goto menu
goto setup_cmd

:cmd_current
echo.
echo Quick Start with CMD:
echo.
echo From the mockup-infra directory, run any of these:
echo.
echo   manage init              - Initialize infrastructure
echo   manage deploy            - Deploy all services
echo   manage status            - Show service status
echo   manage test              - Run tests
echo   manage logs              - View logs
echo   manage help              - Show all commands
echo.
echo For quick access, add this directory to your PATH or create
echo a shortcut to manage.bat on your Desktop.
echo.
pause
goto setup_cmd

:cmd_path
echo.
echo Adding to Windows PATH:
echo.
echo 1. Right-click Start Menu and select "System"
echo 2. Click "Advanced system settings"
echo 3. Click "Environment Variables..." button
echo 4. Under "User variables", click "New..."
echo 5. Variable name: PATH
echo 6. Variable value: %PROJECT_ROOT%
echo 7. Click OK three times
echo 8. Close and reopen CMD
echo.
echo Then you can run: manage init (from any directory)
echo.
pause
goto setup_cmd

REM ========================================================================
REM VIEW ALL INSTRUCTIONS
REM ========================================================================

:view_all
cls
echo.
echo ========================================================================
echo  Complete Shell Integration Guide
echo ========================================================================
echo.
echo OPTION 1: PowerShell (RECOMMENDED)
echo ────────────────────────────────────────
echo Easiest to set up with colored output and full features.
echo
echo Step 1: Open PowerShell as Administrator
echo Step 2: Run this command in the mockup-infra directory:
echo         . .\init-powershell.ps1
echo Step 3: Run Install-InfraProfile function
echo Result: Commands like "minit", "mdeploy", "mtest" become available
echo.
echo.
echo OPTION 2: Git Bash / WSL (LINUX-LIKE)
echo ────────────────────────────────────────
echo Use if you prefer bash syntax and commands.
echo.
echo Step 1: Copy .bashrc to your home directory
echo Step 2: In Git Bash/WSL terminal, run:
echo         source ~/.bashrc
echo Result: Access minit, mdeploy, mtest and other functions
echo.
echo.
echo OPTION 3: Windows CMD (CLASSIC)
echo ────────────────────────────────────────
echo Works with standard Windows Command Prompt.
echo.
echo Step 1: Stay in mockup-infra directory
echo Step 2: Run:
echo         manage help
echo Step 3: Use commands like:
echo         manage init
echo         manage deploy
echo         manage test
echo.
echo.
echo KEY COMMANDS (All Shells):
echo ────────────────────────────────────────
echo  minit           Initialize infrastr. (TLS certs, networks)
echo  mdeploy         Deploy all services (nginx, apis)
echo  mstop           Stop all services
echo  mrestart        Restart services
echo  mstatus         Show running containers
echo  mlogs [svc]     View service logs
echo  mtest           Run all tests
echo  mcerts          Regenerate certificates
echo  mtls            Inspect TLS certificate
echo  misolate        Verify network isolation
echo.
echo.
echo QUICK START (All Shells):
echo ────────────────────────────────────────
echo.
echo PowerShell:
echo   . .\init-powershell.ps1
echo   minit
echo   mdeploy
echo   mtest
echo.
echo Git Bash:
echo   source ./.bashrc
echo   minit
echo   mdeploy
echo   mtest
echo.
echo Windows CMD:
echo   manage init
echo   manage deploy
echo   manage test
echo.
pause
goto menu

REM ========================================================================
REM END
REM ========================================================================

:end
echo.
echo Setup complete! For more information, see README.md
echo.
endlocal
exit /b 0
