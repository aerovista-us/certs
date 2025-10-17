# API Reference (v1, Updated)

**Base URL:** `http://localhost:8000`

> Work‑orders are now **owned by Network Service Station (NSS)** on `http://localhost:5050`. EchoVerse can proxy those under `/nss/*` if configured. The EchoVerse‑native work‑order routes are deprecated.

---

## Core (HTML)
- **GET /** — dashboard (HTML)
- **GET /gallery** — album‑art gallery (HTML)

## Health
- **GET /health** → `{"status":"healthy","timestamp":"ISO-8601","version":"1.x.x"}`

## Catalog Data
- **GET /api/catalog** → `Track[]`
- **GET /api/albums** → `Album[]` (flattened list with nested minimal tracks)
- **GET /api/search?q=...** → `Track[]`

## ID System
- **GET /api/track/{track_id}` → `TrackDetail`
- **GET /api/album/{album_id}` → `AlbumDetail`

## Files
- **GET /api/album-art/{album_name}** → image/*

---

## Schemas

### Track
```json
{
  "id": "track_...",
  "album_id": "album_...",
  "artist_id": "artist_...",
  "album": "Album Name",
  "artist": "Artist Name",
  "track": "Track Title",
  "duration_seconds": 225,
  "file_size_bytes": 12345678,
  "file_path": "M:\\Albums\\Artist\\Album\\track.mp3",
  "cover_file": "M:\\Albums\\Artist\\Album\\cover.jpg",
  "lyrics_file": "",
  "track_number": 1,
  "year": 2025,
  "genre": "Electronic",
  "bitrate_kbps": 320,
  "sample_rate_hz": 44100,
  "filename": "track.mp3"
}
```

### Album (summary)
```json
{
  "id": "album_...",
  "name": "Album Name",
  "artist": "Artist Name",
  "artist_id": "artist_...",
  "cover": "M:\\Albums\\Artist\\Album\\cover.jpg",
  "track_count": 12,
  "total_duration_seconds": 2730,
  "total_size_bytes": 123456789,
  "year": 2025,
  "genre": "Electronic",
  "tracks": [
    { "id": "track_...", "track": "Title", "duration_seconds": 225, "file_size_bytes": 12345678, "track_number": 1 }
  ]
}
```

### Error
```json
{ "error": "Message", "status_code": 400, "details": "Optional info" }
```

---

## Examples
```bash
curl http://localhost:8000/health
curl "http://localhost:8000/api/search?q=electronic"
curl http://localhost:8000/api/albums
curl http://localhost:8000/api/track/track_xxx
```

## NSS (Work‑Orders via Proxy)
If proxying NSS:
```
GET    /nss/api/work-orders
POST   /nss/api/work-orders
PUT    /nss/api/work-orders/{id}
DELETE /nss/api/work-orders/{id}
```
Responses follow NSS’ schema.