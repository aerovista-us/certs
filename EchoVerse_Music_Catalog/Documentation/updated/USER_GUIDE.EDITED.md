# User Guide (Streamlined)

## Start
1) Double‑click `start_catalog.bat` or run `python main.py`
2) Visit **http://localhost:8000**
3) Wait for inventory to load (it auto‑detects the latest `_inventory_*.csv`)

## Navigate
- **Dashboard**: Browse artists/albums/tracks; search & filter
- **Gallery**: Visual album‑art browser (fast lazy‑load)
- **Trace**: On any track, see album/artist relationships

## Create Projects (Work‑Orders)
If NSS is enabled, use **Work‑Orders** under the **NSS** menu (proxied as `/nss/*`). Otherwise this feature is hidden.

## Tips
- Use the search bar to match title/album/artist/genre/year
- Switch views (grid/list/gallery) depending on task
- Keep inventory CSVs small and up‑to‑date for best performance

## Shortcuts
- **Ctrl+F**: Focus search
- **Esc**: Clear search / close dialogs
- **Tab/Enter**: Navigate/activate UI controls

## Troubleshooting
- **Empty dashboard**: Ensure an `_inventory_*.csv` exists in one of the search paths and file paths inside it are reachable
- **No covers**: Confirm cover images sit next to album folders
- **Port in use**: Change `PORT` in `.env` or free the port

## Privacy & Security
Runs locally; no data leaves your machine. When exposing beyond localhost, set strict CORS and keep path validation on.