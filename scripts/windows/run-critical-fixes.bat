@echo off
REM NXCore Critical Fixes - Windows to Linux Server
REM Simple batch file to run critical fixes

echo.
echo ========================================
echo    NXCore Critical Fixes Implementation
echo ========================================
echo.

echo Choose an option:
echo 1. Deploy critical fixes to server
echo 2. Test services after fixes
echo 3. Deploy stakeholder PC imaging
echo 4. Show server status
echo 5. Exit
echo.

set /p choice="Enter your choice (1-5): "

if "%choice%"=="1" (
    echo.
    echo Deploying critical fixes to server...
    scp scripts\critical-fixes-implementation.sh glyph@100.115.9.61:/srv/core/scripts/
    ssh glyph@100.115.9.61 "chmod +x /srv/core/scripts/critical-fixes-implementation.sh && /srv/core/scripts/critical-fixes-implementation.sh"
) else if "%choice%"=="2" (
    echo.
    echo Testing services after fixes...
    ssh glyph@100.115.9.61 "echo '=== SERVICE TEST AFTER FIXES ===' && echo 'Grafana:' && curl -k -s -o /dev/null -w 'HTTP %{http_code} - %{time_total}s' https://nxcore.tail79107c.ts.net/grafana/ && echo '' && echo 'Prometheus:' && curl -k -s -o /dev/null -w 'HTTP %{http_code} - %{time_total}s' https://nxcore.tail79107c.ts.net/prometheus/ && echo '' && echo 'cAdvisor:' && curl -k -s -o /dev/null -w 'HTTP %{http_code} - %{time_total}s' https://nxcore.tail79107c.ts.net/metrics/ && echo '' && echo 'Uptime Kuma:' && curl -k -s -o /dev/null -w 'HTTP %{http_code} - %{time_total}s' https://nxcore.tail79107c.ts.net/status/"
) else if "%choice%"=="3" (
    echo.
    echo Deploying stakeholder PC imaging solution...
    scp scripts\stakeholder-pc-imaging.sh glyph@100.115.9.61:/srv/core/scripts/
    ssh glyph@100.115.9.61 "chmod +x /srv/core/scripts/stakeholder-pc-imaging.sh && /srv/core/scripts/stakeholder-pc-imaging.sh"
) else if "%choice%"=="4" (
    echo.
    echo Showing server status...
    ssh glyph@100.115.9.61 "echo '=== SERVER STATUS ===' && docker ps --format 'table {{.Names}}\t{{.Status}}' | head -10 && echo '' && echo '=== SERVICE TEST ===' && echo 'Grafana:' && curl -k -s -o /dev/null -w 'HTTP %{http_code}' https://nxcore.tail79107c.ts.net/grafana/ && echo '' && echo 'Prometheus:' && curl -k -s -o /dev/null -w 'HTTP %{http_code}' https://nxcore.tail79107c.ts.net/prometheus/ && echo '' && echo 'cAdvisor:' && curl -k -s -o /dev/null -w 'HTTP %{http_code}' https://nxcore.tail79107c.ts.net/metrics/ && echo '' && echo 'Uptime Kuma:' && curl -k -s -o /dev/null -w 'HTTP %{http_code}' https://nxcore.tail79107c.ts.net/status/"
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
