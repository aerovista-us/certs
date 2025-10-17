@echo off
if "%~1"=="" (
  echo Usage: scp-to-nxcore.bat ^<local_path^> [remote_path]
  exit /b 1
)
set HOST=192.168.7.209
set USER=glyph
set RPATH=/srv/core/
if not "%~2"=="" set RPATH=%~2
scp -r "%~1" %USER%@%HOST%:%RPATH%
