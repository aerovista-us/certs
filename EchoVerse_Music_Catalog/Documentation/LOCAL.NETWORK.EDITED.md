# LOCAL NETWORK & MUSIC LIBRARY - TECH SPECS

## Paths and Shares
- Primary UNC: `\\envy2-0\EchoVerse_Music\Albums\`
- Alt UNC: `//envy2-0/EchoVerse_Music/Albums/`
- Mapped drive: `M:\\Albums\\`
- Backup: `D:\\Clients\\AeroVista\\Projects\\EchoVerse_Music\\Albums\\`

### Search Order (for inventory CSV)
1) `M:/Albums/`
2) `\\envy2-0\EchoVerse_Music\Albums\`
3) `//envy2-0/EchoVerse_Music/Albums/`
4) `D:/Clients/AeroVista/Projects/EchoVerse_Music/Albums/`
5) `music_catalog/`


## Services and Ports (Updated)
- EchoVerse Music Catalog (FastAPI): `http://localhost:8000`
- NeXuS Core:
  - Dashboard: `:5000`
  - Music Dashboard: `:5001`
  - File Dashboard: `:5002`
  - Agent Hub: `:5003`
  - Unified Server: `:5004`
- Network Service Station (Flask): `http://localhost:5050`

## EchoVerse Catalog (main.py) - Loading & Streaming
- Inventory CSV search order:
  1) `M:/Albums/`
  2) `\\envy2-0\EchoVerse_Music\Albums\`
  3) `//envy2-0/EchoVerse_Music/Albums/`
  4) `D:/Clients/AeroVista/Projects/EchoVerse_Music/Albums/`
  5) `music_catalog/`
- Allowed audio roots for `/api/audio/{file_path}`:
  - `M:/Albums/`, `D:/Clients/AeroVista/Projects/EchoVerse_Music/Albums/`, `music_catalog/`, UNC paths above
- Endpoints: `/`, `/gallery`, `/health`, `/api/catalog`, `/api/albums`, `/api/search?q=...`,
  `/api/album-art/{album_name}`, `/api/album-art-flipbook`, `/api/track/{track_id}`, `/api/album/{album_id}`

## Network Service Station (network_service_station.py)
- Config: `config/network_config.json`
- DB: `data/network_inventory.db`
- Scans subnets: `192.168.1.0/24`, `10.0.0.0/24` (configurable)
- Tracks: computers, access levels, maintenance, upgrades
- Endpoints: `/api/work-orders` (GET/POST), `/api/export-work-order/{id}`
- Web UI: `py/network_dashboard.py` → `http://localhost:5050`

## NeXuS Master Config (core/config/nexus_master_config.json)
- Centralized ports, paths, databases, features (incl. music_processing)
- DBs: `D:/NeXuS/data/nexus.db`, `D:/NeXuS/data/music.db`, `D:/NeXuS/offline_ai/offline_ai.db`

## Music Library Tooling
- Scanner: `scripts/scan_music.py` (mutagen-based metadata)
- Tests: `py/test_music_search.py`, `py/test_music_integration.py`
- Unified DB (example): `data/nexus_unified.db`
- Typical music API (via unified/dashboard): `/api/music/search`, `/api/music/tracks`, `/api/music/library`

## Findings from runs (Agent/MemoryMapping/NexusDropInstall/runs)
- Structure: timestamped run folders with CSV summaries and 1:1 parsed chunk artifacts
  - `categorized_final_mentions.csv` (very large)
  - `tool_project_summary.csv` (very large)
  - `chunk_keyword_heatmap.csv`, `chunk_source_map.csv`
  - `parsed_chunks/` containing chunked `.txt` and `.json`
- Intended use: consolidated technical and project specs extracted from source corpora; suitable for cross-referencing endpoints, ports, and share paths
- Due to size, direct inline excerpts omitted; targeted grep recommended when needed (e.g., localhost, ports, UNC paths, Albums)

## Security Notes
- **CORS (prod)**: Restrict to trusted origins/methods; keep permissive only for local dev.
- **Path normalization**: Normalize UNC vs mapped paths (`os.path.normpath`, lower-case compare) to avoid `\\` vs `//` edge cases.
- CORS permissive in EchoVerse for local dev
- Audio streaming restricted to approved roots
- Local-first operation; no external dependency

## Quick Checks
- `curl http://localhost:8000/health`
- `curl "http://localhost:8000/api/search?q=electronic"`
- Open `http://localhost:5000` for NeXuS Dashboard
- Open `http://localhost:5050` for Network Service Station

Last updated: 2025-09-17
