# EchoVerse Music Catalog — Local‑First Audio Library & Workbench

A fast, offline‑capable music catalog built on **FastAPI** with a simple HTML/JS frontend. It indexes your inventory CSV, resolves cover art, and gives you a sleek dashboard + gallery for deep browsing. Optional integration with **Network Service Station (NSS)** adds fleet/work‑order ops.

## ✨ Highlights
- **Local‑first**: no cloud required; reads directly from your drives
- **Instant browse**: dashboard + album‑art gallery with lazy loading
- **Rich metadata**: size, duration, track#, year, bitrate, sample rate
- **Deterministic IDs**: stable `track_*/album_*/artist_*` identifiers
- **Clean API**: JSON endpoints for catalog, albums, search, trace
- **NSS integration (optional)**: work‑orders & network ops via `:5050`

---

## 🚀 Quick Start

### Using the script (Windows)
```bat
start_catalog.bat
```
- Creates a venv, installs deps, launches server on **http://localhost:8000**.

### Manual
```powershell
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
python main.py  # or: uvicorn main:app --reload --port 8000
```

> Tip: For development, also install `requirements-dev.txt` and run with `uvicorn --reload`.

---

## ⚙️ Configuration

### Inventory & Path Resolution
On startup the server loads the most recent `_inventory_*.csv` using this **search order** (stops at first hit):
1. `M:/Albums/`
2. `\\envy2-0\EchoVerse_Music\Albums\`
3. `//envy2-0/EchoVerse_Music/Albums/`
4. `D:/Clients/AeroVista/Projects/EchoVerse_Music/Albums/`
5. `music_catalog/` (dev fallback)

Allowed audio/art roots are normalized and validated to prevent directory‑traversal. UNC and mapped‑drive forms are treated equivalently.

### Environment Variables (.env)
```
HOST=0.0.0.0
PORT=8000
INVENTORY_GLOB=_inventory_*.csv
MUSIC_ROOTS=M:/Albums/;\\envy2-0\EchoVerse_Music\Albums\;D:/Clients/AeroVista/Projects/EchoVerse_Music/Albums/
CORS_ALLOW_ORIGINS=http://localhost:8000
```

---

## 🔌 Ports & Integrations

- **EchoVerse Catalog** (this app): `http://localhost:8000`
- **Network Service Station (NSS)**: `http://localhost:5050` (optional)
  - If enabled, EchoVerse can **proxy** NSS under `/nss/*` routes (configurable).

> **Note on work‑orders:** EchoVerse originally shipped lightweight work‑order endpoints. These are now **owned by NSS**. You can keep EchoVerse‑side routes disabled (recommended) and proxy to NSS instead.

---

## 🧭 API Overview (v1)
Core (served by EchoVerse):
- `GET /` — dashboard (HTML)
- `GET /gallery` — album‑art gallery (HTML)
- `GET /health` — health JSON
- `GET /api/catalog` — all tracks
- `GET /api/albums` — grouped albums
- `GET /api/search?q=` — search
- `GET /api/track/{track_id}` — track + relationships
- `GET /api/album/{album_id}` — album + tracks
- `GET /api/album-art/{album_name}` — cover image

NSS (recommended via proxy):
- `GET /nss/api/work-orders`
- `POST /nss/api/work-orders`
- `PUT /nss/api/work-orders/{id}`
- `DELETE /nss/api/work-orders/{id}`

Error format (JSON):
```json
{ "error": "Message", "status_code": 400, "details": "Optional info" }
```

---

## 🖥️ Frontend
Plain HTML + CSS + JS with **Jinja2** templates. Uses the Intersection Observer API for lazy image loading and keeps the UI responsive on large libraries.

---

## 🔒 Security
- **Localhost** by default; if binding externally, set strict CORS.
- **Path validation** for file serving; deny traversal and unexpected types.
- **No telemetry** — all data stays local.

---

## 🧪 Testing
```bash
pip install -r requirements-dev.txt
pytest -q
```

---

## 🛠 Troubleshooting
- **No music showing**: ensure an `_inventory_*.csv` exists in one of the search paths and the file paths inside it are valid.
- **Covers missing**: verify art files exist alongside albums; check path normalization.
- **Port busy**: something else is listening on `:8000`; pick another PORT or stop the other service.

---

## 📄 License
Proprietary — internal use. Update this section if you change distribution.