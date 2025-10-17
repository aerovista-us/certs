@echo off
setlocal ENABLEDELAYEDEXPANSION

rem ================================================================
rem AeroCoreOS — Staff Call: Startup Script (Windows)
rem Drop this .bat into:  %APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup
rem It will start the Node server and (if available) map HTTPS via Tailscale.
rem ================================================================

rem ---- Config (edit as needed) -----------------------------------
set "PORT=8443"
set "USE_HTTPS=0"          rem 0 = use plain HTTP (pair with `tailscale serve https`), 1 = built-in TLS
set "KEY_PATH="            rem if USE_HTTPS=1, set to your tailscale cert key path
set "CERT_PATH="           rem if USE_HTTPS=1, set to your tailscale cert crt path
rem ---------------------------------------------------------------

rem Go to script directory (this should contain server.staff.js)
set "APP_DIR=%~dp0"
pushd "%APP_DIR%"

rem Create logs folder
set "LOG_DIR=%LOCALAPPDATA%\AeroVista\StaffCall\logs"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul 2>nul

for /f %%i in ('powershell -NoProfile -Command "(Get-Date).ToString(\"yyyy-MM-dd_HH-mm-ss\")"') do set "STAMP=%%i"
set "LOG_FILE=%LOG_DIR%\server_%STAMP%.log"

echo [%date% %time%] Starting AeroCoreOS Staff Call... >> "%LOG_FILE%"

rem Check Node
where node >nul 2>nul
if errorlevel 1 (
  echo Node.js not found in PATH. Install Node.js (LTS) and try again. >> "%LOG_FILE%"
  goto :EOF
)

rem Install dependencies if missing
if not exist "node_modules" (
  echo Installing dependencies... >> "%LOG_FILE%"
  call npm ci --omit=dev >> "%LOG_FILE%" 2>>&1 || call npm install >> "%LOG_FILE%" 2>>&1
)

rem If port already listening, do not start duplicate
netstat -ano | findstr /R /C:":%PORT% .*LISTENING" >nul
if %errorlevel%==0 (
  echo Port %PORT% already in use; skipping server start. >> "%LOG_FILE%"
) else (
  echo Launching server on port %PORT%... >> "%LOG_FILE%"
  rem Start minimized; pass env vars to child, log stdout/stderr
  start "AeroCoreOS Staff Call" /min cmd /c "set USE_HTTPS=%USE_HTTPS%&& set PORT=%PORT%&& set KEY_PATH=%KEY_PATH%&& set CERT_PATH=%CERT_PATH%&& node server.staff.js >> ^"%LOG_FILE%^" 2>>&1"
)

rem If Tailscale CLI exists, ensure we have an HTTPS mapping to the local port
where tailscale >nul 2>nul
if %errorlevel%==0 (
  rem Check if serve already configured
  for /f "tokens=*" %%S in ('tailscale serve status ^| findstr /C:"https://"') do set "SERVE_EXISTS=1"
  if not defined SERVE_EXISTS (
    echo Configuring tailscale serve https -> http://127.0.0.1:%PORT% >> "%LOG_FILE%"
    tailscale serve https / http://127.0.0.1:%PORT% >> "%LOG_FILE%" 2>>&1
  ) else (
    echo tailscale serve already configured. >> "%LOG_FILE%"
  )
) else (
  echo Tailscale CLI not found; skipping tailscale serve mapping. >> "%LOG_FILE%"
)

popd
exit /b 0