# Development Guide (Improved)

This refines setup, standards, QA, and release flows for EchoVerse.

## 🧰 Prereqs
- Python **3.10+** (3.8 works, 3.10+ recommended)
- Git
- Windows 10/11
- Modern browser

## 🏗️ Setup
```powershell
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
pip install -r requirements-dev.txt
```
Optional: `pre-commit install` (if you add pre-commit later).

## ▶️ Run
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```
Open http://localhost:8000

## 🧭 Project Layout
```
main.py
templates/ (dashboard.html, gallery.html, base.html, components/)
static/ (css/, js/, images/)
config/ (settings.py, logging.py, database.py)
tests/
```

## 📝 Code Standards
- **Black** + **isort** formatting, **flake8** lint, optional **ruff**
- Type hints everywhere; mypy (strict optional)
- Docstrings with Args/Returns/Raises
- No blocking I/O in request paths—use async/file threads where appropriate

### Commit Style
Use Conventional Commits:
- `feat:`, `fix:`, `docs:`, `refactor:`, `chore:`, `perf:`, `test:`

## 🧪 Tests
- **Unit**: pure functions
- **API**: FastAPI TestClient/httpx
- **E2E (light)**: smoke the main routes

```bash
pytest -q --cov=main --cov-report=term-missing
```

## 🔍 Debugging
- Set `LOG_LEVEL=DEBUG` in `.env` for verbose logs
- Use browser devtools Network tab for 4xx/5xx response bodies

## ⚡ Performance
- Cache album‑art path lookups
- Use paginated/streamed responses for huge catalogs
- Lazy‑load images via Intersection Observer

## 🔒 Security
- CORS: dev wide-open; prod whitelist origins/methods/headers
- Path allowlist + normalization; deny traversal
- MIME detection on file responses

## 📦 Release
1. Bump version
2. `pip freeze > requirements-lock.txt` (optional lock for release)
3. Tag + changelog
4. Smoke test on target machine

## 🤝 Contributing
- Small PRs; include tests
- Update docs when adding endpoints
- Keep API responses stable; if breaking, mark as `v2`