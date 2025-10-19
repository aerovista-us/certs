@echo off
REM NXCore Audit Fixes - Windows to Linux Server
REM Simple batch file to run the audit and fixes

echo.
echo ========================================
echo    NXCore Infrastructure Audit & Fixes
echo ========================================
echo.

echo Choose an option:
echo 1. Test services only
echo 2. Deploy fixes to server
echo 3. Run local tests
echo 4. Show server status
echo 5. Exit
echo.

set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" (
    echo.
    echo Running tests on server...
    powershell -ExecutionPolicy Bypass -File "scripts\windows-to-server-deployment.ps1" -TestOnly
) else if "%choice%"=="2" (
    echo.
    echo Deploying fixes to server...
    powershell -ExecutionPolicy Bypass -File "scripts\windows-to-server-deployment.ps1" -DeployFixes
) else if "%choice%"=="3" (
    echo.
    echo Running local tests...
    powershell -ExecutionPolicy Bypass -File "scripts\windows-to-server-deployment.ps1" -RunTests
) else if "%choice%"=="4" (
    echo.
    echo Showing server status...
    powershell -ExecutionPolicy Bypass -File "scripts\windows-to-server-deployment.ps1"
) else if "%choice%"=="5" (
    echo.
    echo Exiting...
    exit /b 0
) else (
    echo.
    echo Invalid choice. Please run the script again.
    pause
    exit /b 1
)

echo.
echo Press any key to continue...
pause >nul
