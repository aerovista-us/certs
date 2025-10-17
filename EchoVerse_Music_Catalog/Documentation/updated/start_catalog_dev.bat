@echo off
SETLOCAL
if not exist .venv (
  echo [setup] Creating venv...
  py -3 -m venv .venv
)
call .venv\Scripts\activate
echo [setup] Installing runtime deps...
pip install -r requirements.txt
if exist requirements-dev.txt (
  echo [setup] Installing dev deps...
  pip install -r requirements-dev.txt
)
echo [run] Starting EchoVerse (reload)...
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
ENDLOCAL