# Technical Architecture (Condensed & Updated)

## System Overview
Local‑first, single‑host app: **FastAPI** backend + lightweight HTML/JS frontend. Optional integration with **Network Service Station (NSS)** for work‑orders and network ops.

```
Browser ⇄ FastAPI (EchoVerse :8000) ⇄ File System (music, art)
                          └─(optional)→ NSS :5050 (work‑orders)
```

## Ports
- EchoVerse: `8000`
- NSS: `5050` (recommended for work‑orders)

## Startup Flow
```
Load .env → Resolve inventory CSV (search order) → Parse CSV → Compute IDs
→ Build in‑memory catalog → Serve dashboard/gallery/API
```

## Inventory Search Order
1) `M:/Albums/`
2) `\\envy2-0\EchoVerse_Music\Albums\`
3) `//envy2-0/EchoVerse_Music/Albums/`
4) `D:/Clients/AeroVista/Projects/EchoVerse_Music/Albums/`
5) `music_catalog/`

## Data Model (IDs simplified)
- `artist_{hash}`
- `album_{hash}_artist_{hash}`
- `track_{hash}_album_{hash}_artist_{hash}`

## API Surface
- HTML: `/`, `/gallery`
- JSON: `/health`, `/api/catalog`, `/api/albums`, `/api/search`, `/api/track/{id}`, `/api/album/{id}`, `/api/album-art/{album}`
- NSS (optional via proxy): `/nss/api/work-orders[/{id}]`

## Performance
- Lazy loading via Intersection Observer
- O(1) lookups by ID (dicts)
- Optional caching for album‑art path resolution
- Consider pagination for huge catalogs

## Security
- Localhost by default; tighten CORS for external binds
- Validate & normalize paths (deny traversal; allowlist roots)
- Serve only known MIME types

## Deployment
- Single machine, no external DB required
- `uvicorn main:app --host 0.0.0.0 --port 8000`
- Optional Nginx reverse proxy for pretty routes or NSS proxying