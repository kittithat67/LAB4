@echo off
REM Mockup Infrastructure CMD Batch Script
REM Save as: manage.bat or infra.bat
REM This provides infrastructure management commands in Windows CMD

setlocal enabledelayedexpansion

REM ========================================================================
REM ENVIRONMENT SETUP
REM ========================================================================

set SCRIPT_DIR=%~dp0
set PROJECT_ROOT=%SCRIPT_DIR:~0,-1%
set PYTHONIOENCODING=utf-8

if not exist "%PROJECT_ROOT%\manage.py" (
    echo ERROR: manage.py not found in %PROJECT_ROOT%
    echo Please run this script from the mockup-infra directory
    exit /b 1
)

REM ========================================================================
REM DISPLAY BANNER
REM ========================================================================

cls
echo.
echo [Mockup Infrastructure Management - Windows CMD Mode]
echo.
echo Project Root: %PROJECT_ROOT%
echo.

REM ========================================================================
REM COMMAND PARSING
REM ========================================================================

if "%1"=="" goto show_help
if /i "%1"=="help" goto show_help
if /i "%1"=="-h" goto show_help
if /i "%1"=="--help" goto show_help

REM ========================================================================
REM INFRASTRUCTURE COMMANDS
REM ========================================================================

if /i "%1"=="init" (
    echo [INFO] Initializing infrastructure...
    python manage.py init
    goto end
)

if /i "%1"=="deploy" (
    echo [INFO] Deploying infrastructure...
    python manage.py deploy
    goto end
)

if /i "%1"=="stop" (
    echo [INFO] Stopping services...
    python manage.py stop
    goto end
)

if /i "%1"=="restart" (
    echo [INFO] Restarting services...
    python manage.py restart
    goto end
)

if /i "%1"=="status" (
    echo [INFO] Checking service status...
    python manage.py status
    goto end
)

if /i "%1"=="logs" (
    if "%2"=="" (
        echo [INFO] Showing all logs...
        python manage.py logs
    ) else (
        echo [INFO] Showing logs for %2...
        python manage.py logs %2
    )
    goto end
)

REM ========================================================================
REM SECURITY COMMANDS
REM ========================================================================

if /i "%1"=="certs" (
    echo [INFO] Generating certificates...
    python manage.py certs
    goto end
)

if /i "%1"=="tls" (
    echo [INFO] Inspecting TLS certificate...
    python manage.py tls
    goto end
)

if /i "%1"=="isolate" (
    echo [INFO] Verifying network isolation...
    python manage.py isolate
    goto end
)

REM ========================================================================
REM TESTING COMMANDS
REM ========================================================================

if /i "%1"=="test" (
    echo [INFO] Running tests...
    python manage.py test
    goto end
)

if /i "%1"=="test-standalone" (
    echo [INFO] Running standalone tests...
    python test_infra.py
    goto end
)

if /i "%1"=="test-all" (
    echo [INFO] Running all tests...
    echo.
    echo === Running manage.py test ===
    python manage.py test
    echo.
    echo === Running test_infra.py ===
    python test_infra.py
    goto end
)

REM ========================================================================
REM ADVANCED COMMANDS
REM ========================================================================

if /i "%1"=="setup" (
    echo [INFO] Running full setup...
    python manage.py init
    python manage.py deploy
    goto end
)

if /i "%1"=="check" (
    echo [INFO] Running health check...
    python manage.py status
    echo.
    python manage.py isolate
    goto end
)

if /i "%1"=="quick-deploy" (
    echo [INFO] Quick deploy (skip init)...
    python manage.py deploy
    goto end
)

REM ========================================================================
REM INVALID COMMAND
REM ========================================================================

:invalid_command
echo ERROR: Unknown command '%1'
echo.
goto show_help

REM ========================================================================
REM HELP MENU
REM ========================================================================

:show_help
echo.
echo [Available Commands and Options]
echo.
echo Infrastructure Management:
echo   manage init              Initialize infrastructure
echo   manage deploy            Deploy full stack
echo   manage stop              Stop all services
echo   manage restart           Restart all services
echo   manage status            Show service status
echo   manage logs [service]    View logs (optional: service name)
echo.
echo Security ^& Configuration:
echo   manage certs             Generate/regenerate TLS certificates
echo   manage tls               Inspect TLS certificate
echo   manage isolate           Verify network isolation
echo.
echo Testing:
echo   manage test              Run manage.py tests
echo   manage test-standalone   Run test_infra.py
echo   manage test-all          Run all tests
echo.
echo Advanced Commands:
echo   manage setup             Initialize and deploy in one command
echo   manage check             Full health check
echo   manage quick-deploy      Deploy without init
echo.
echo Examples:
echo   manage init
echo   manage deploy
echo   manage status
echo   manage logs nginx-gateway
echo   manage test
echo   manage setup
echo.
goto end

REM ========================================================================
REM END
REM ========================================================================

:end
echo.
endlocal
exit /b %ERRORLEVEL%
