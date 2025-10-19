@echo off
echo NXCore Multi-PC Certificate Deployment
echo =====================================
echo.
echo This will install OpenSSL and set up certificate generation.
echo.
echo Prerequisites:
echo - Administrator privileges required
echo - Network access to NXCore server
echo - SSH access to 100.115.9.61
echo.
pause
echo.
echo Installing OpenSSL...
powershell -ExecutionPolicy Bypass -File "install-openssl-and-setup.ps1"
echo.
echo OpenSSL installation complete!
echo.
echo Next: Run certificate generation
echo powershell -ExecutionPolicy Bypass -File "scripts\generate-and-deploy-bundles-fixed.ps1"
echo.
pause
