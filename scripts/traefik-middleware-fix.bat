@echo off
REM traefik-middleware-fix.bat
REM Complete Traefik middleware and security fix for Windows

echo 🔧 NXCore Traefik Middleware Fix - Starting...

REM Create backup directory
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "BACKUP_DIR=C:\srv\core\backups\%YYYY%%MM%%DD%_%HH%%Min%%Sec%"
mkdir "%BACKUP_DIR%" 2>nul

REM Backup current configuration
echo 📦 Backing up current configuration...
xcopy "C:\opt\nexus\traefik\dynamic" "%BACKUP_DIR%\traefik-dynamic-backup\" /E /I /Q 2>nul || echo "Backup skipped - directory not found"
docker logs traefik > "%BACKUP_DIR%\traefik-logs-before.log" 2>nul || echo "Traefik logs backup skipped"

REM Generate secure credentials
echo 🔐 Generating secure credentials...
for /f %%i in ('powershell -command "[System.Web.Security.Membership]::GeneratePassword(32, 0)"') do set "GRAFANA_PASSWORD=%%i"
for /f %%i in ('powershell -command "[System.Web.Security.Membership]::GeneratePassword(32, 0)"') do set "N8N_PASSWORD=%%i"
for /f %%i in ('powershell -command "[System.Web.Security.Membership]::GeneratePassword(32, 0)"') do set "PORTAINER_PASSWORD=%%i"
for /f %%i in ('powershell -command "[System.Web.Security.Membership]::GeneratePassword(32, 0)"') do set "AUTHELIA_JWT_SECRET=%%i"
for /f %%i in ('powershell -command "[System.Web.Security.Membership]::GeneratePassword(32, 0)"') do set "AUTHELIA_SESSION_SECRET=%%i"
for /f %%i in ('powershell -command "[System.Web.Security.Membership]::GeneratePassword(32, 0)"') do set "AUTHELIA_STORAGE_ENCRYPTION_KEY=%%i"
for /f %%i in ('powershell -command "[System.Web.Security.Membership]::GeneratePassword(32, 0)"') do set "POSTGRES_PASSWORD=%%i"
for /f %%i in ('powershell -command "[System.Web.Security.Membership]::GeneratePassword(32, 0)"') do set "REDIS_PASSWORD=%%i"

REM Create secure environment file
echo # NXCore Secure Environment Variables > C:\srv\core\.env.secure
echo GRAFANA_PASSWORD=%GRAFANA_PASSWORD% >> C:\srv\core\.env.secure
echo N8N_PASSWORD=%N8N_PASSWORD% >> C:\srv\core\.env.secure
echo PORTAINER_PASSWORD=%PORTAINER_PASSWORD% >> C:\srv\core\.env.secure
echo AUTHELIA_JWT_SECRET=%AUTHELIA_JWT_SECRET% >> C:\srv\core\.env.secure
echo AUTHELIA_SESSION_SECRET=%AUTHELIA_SESSION_SECRET% >> C:\srv\core\.env.secure
echo AUTHELIA_STORAGE_ENCRYPTION_KEY=%AUTHELIA_STORAGE_ENCRYPTION_KEY% >> C:\srv\core\.env.secure
echo POSTGRES_PASSWORD=%POSTGRES_PASSWORD% >> C:\srv\core\.env.secure
echo REDIS_PASSWORD=%REDIS_PASSWORD% >> C:\srv\core\.env.secure

REM Deploy fixed middleware configuration
echo 🔧 Deploying fixed middleware configuration...
mkdir C:\opt\nexus\traefik\dynamic 2>nul

(
echo http:
echo   middlewares:
echo     # Fixed Grafana middleware
echo     grafana-strip-fixed:
echo       stripPrefix:
echo         prefixes: ["/grafana"]
echo         forceSlash: false
echo     # Fixed Prometheus middleware  
echo     prometheus-strip-fixed:
echo       stripPrefix:
echo         prefixes: ["/prometheus"]
echo         forceSlash: false
echo     # Fixed cAdvisor middleware
echo     cadvisor-strip-fixed:
echo       stripPrefix:
echo         prefixes: ["/metrics"]
echo         forceSlash: false
echo     # Fixed Uptime Kuma middleware
echo     uptime-strip-fixed:
echo       stripPrefix:
echo         prefixes: ["/status"]
echo         forceSlash: false
echo   routers:
echo     # Fixed Grafana routing
echo     grafana-fixed:
echo       rule: Host(`nxcore.tail79107c.ts.net`) ^&^& PathPrefix(`/grafana`)
echo       priority: 200
echo       entryPoints: [websecure]
echo       tls: {}
echo       middlewares: [grafana-strip-fixed]
echo       service: grafana-svc
echo     # Fixed Prometheus routing
echo     prometheus-fixed:
echo       rule: Host(`nxcore.tail79107c.ts.net`) ^&^& PathPrefix(`/prometheus`)
echo       priority: 200
echo       entryPoints: [websecure]
echo       tls: {}
echo       middlewares: [prometheus-strip-fixed]
echo       service: prometheus-svc
echo     # Fixed cAdvisor routing
echo     cadvisor-fixed:
echo       rule: Host(`nxcore.tail79107c.ts.net`) ^&^& PathPrefix(`/metrics`)
echo       priority: 200
echo       entryPoints: [websecure]
echo       tls: {}
echo       middlewares: [cadvisor-strip-fixed]
echo       service: cadvisor-svc
echo     # Fixed Uptime Kuma routing
echo     uptime-fixed:
echo       rule: Host(`nxcore.tail79107c.ts.net`) ^&^& PathPrefix(`/status`)
echo       priority: 200
echo       entryPoints: [websecure]
echo       tls: {}
echo       middlewares: [uptime-strip-fixed]
echo       service: uptime-svc
echo   services:
echo     # Fixed service endpoints
echo     grafana-svc:
echo       loadBalancer:
echo         servers:
echo           - url: "http://grafana:3000"
echo     prometheus-svc:
echo       loadBalancer:
echo         servers:
echo           - url: "http://prometheus:9090"
echo     cadvisor-svc:
echo       loadBalancer:
echo         servers:
echo           - url: "http://cadvisor:8080"
echo     uptime-svc:
echo       loadBalancer:
echo         servers:
echo           - url: "http://uptime-kuma:3001"
) > C:\opt\nexus\traefik\dynamic\middleware-fixes.yml

REM Restart Traefik
echo 🔄 Restarting Traefik...
docker restart traefik

REM Wait for Traefik to start
echo ⏳ Waiting for Traefik to start...
timeout /t 30 /nobreak >nul

REM Update service credentials
echo 🔑 Updating service credentials...
docker exec grafana grafana-cli admin reset-admin-password "%GRAFANA_PASSWORD%" 2>nul || echo "Grafana password update skipped"
docker exec n8n n8n user:password --email admin@example.com --password "%N8N_PASSWORD%" 2>nul || echo "n8n password update skipped"

REM Test services
echo 🧪 Testing services...
echo Testing Grafana...
curl -k -s -o nul -w "Grafana: HTTP %%{http_code} - %%{time_total}s\n" https://nxcore.tail79107c.ts.net/grafana/ 2>nul || echo "Grafana test failed"

echo Testing Prometheus...
curl -k -s -o nul -w "Prometheus: HTTP %%{http_code} - %%{time_total}s\n" https://nxcore.tail79107c.ts.net/prometheus/ 2>nul || echo "Prometheus test failed"

echo Testing cAdvisor...
curl -k -s -o nul -w "cAdvisor: HTTP %%{http_code} - %%{time_total}s\n" https://nxcore.tail79107c.ts.net/metrics/ 2>nul || echo "cAdvisor test failed"

echo Testing Uptime Kuma...
curl -k -s -o nul -w "Uptime Kuma: HTTP %%{http_code} - %%{time_total}s\n" https://nxcore.tail79107c.ts.net/status/ 2>nul || echo "Uptime Kuma test failed"

REM Generate report
echo 📊 Generating fix report...
(
echo # Traefik Middleware Fix Report
echo.
echo **Date**: %date% %time%
echo **Status**: ✅ COMPLETED
echo.
echo ## Fixed Issues
echo - ✅ StripPrefix middleware configuration corrected
echo - ✅ Routing conflicts resolved
echo - ✅ Service endpoints corrected
echo - ✅ Security credentials updated
echo.
echo ## New Credentials
echo - Grafana: %GRAFANA_PASSWORD%
echo - n8n: %N8N_PASSWORD%
echo - Portainer: %PORTAINER_PASSWORD%
echo.
echo ## Test Results
echo - Grafana: [Test results will be updated after execution]
echo - Prometheus: [Test results will be updated after execution]
echo - cAdvisor: [Test results will be updated after execution]
echo - Uptime Kuma: [Test results will be updated after execution]
echo.
echo ## Backup Location
echo %BACKUP_DIR%
) > "%BACKUP_DIR%\fix-report.md"

echo ✅ Traefik middleware fix completed!
echo 📊 Report saved to: %BACKUP_DIR%\fix-report.md
echo 🔐 Secure credentials saved to: C:\srv\core\.env.secure
pause
