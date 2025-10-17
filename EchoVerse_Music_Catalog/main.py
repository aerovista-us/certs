"""
EchoVerse Music Catalog System
Professional music catalog for AeroVista Studios with work order management
"""

from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse, FileResponse, JSONResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
import pandas as pd
import json
import os
import re
from pathlib import Path
from typing import List, Dict, Any, Optional
import uvicorn
from datetime import datetime
import hashlib
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Load catalog data on startup"""
    load_music_catalog()
    yield
    # Cleanup code here if needed

app = FastAPI(
    title="EchoVerse Music Catalog",
    description="Professional music catalog system for AeroVista Studios",
    version="1.0.0",
    lifespan=lifespan
)

# Tailscale configuration from config file
def load_tailscale_config():
    """Load Tailscale configuration from config file"""
    config_path = os.path.join(os.path.dirname(__file__), "config", "tailscale_config.json")
    default_config = {
        "tailscale": {
            "domain": "https://aerocoreos.tail79107c.ts.net/echoverse/Albums/",
            "music_path": "",
            "enabled": True,
            "fallback_to_direct": True
        },
        "local_paths": {
            "network_share": "\\\\envy2-0\\EchoVerse_Music\\Albums\\",
            "local_drive": "M:\\Albums\\",
            "backup_drive": "D:\\Clients\\AeroVista\\Projects\\EchoVerse_Music\\Albums\\"
        }
    }
    
    try:
        # Create config directory if it doesn't exist
        os.makedirs(os.path.dirname(config_path), exist_ok=True)
        
        # If config file doesn't exist, create it with default values
        if not os.path.exists(config_path):
            with open(config_path, 'w') as f:
                json.dump(default_config, f, indent=2)
            return default_config
        
        # Load config from file
        with open(config_path, 'r') as f:
            config = json.load(f)
        return config
    except Exception as e:
        print(f"Error loading Tailscale config: {e}")
        return default_config

# Load Tailscale configuration
tailscale_config = load_tailscale_config()
TAILSCALE_DOMAIN = tailscale_config["tailscale"]["domain"]
TAILSCALE_MUSIC_PATH = tailscale_config["tailscale"]["music_path"]
USE_TAILSCALE = tailscale_config["tailscale"]["enabled"]

# Get allowed directories from config
ALLOWED_DIRS = [
    tailscale_config["local_paths"]["local_drive"],
    tailscale_config["local_paths"]["backup_drive"],
    "music_catalog/",
    tailscale_config["local_paths"]["network_share"],
    tailscale_config["local_paths"]["network_share"].replace('\\', '/')
]

def convert_to_tailscale_url(file_path):
    """
    Convert any file path format to a Tailscale URL
    
    Handles various input formats:
    - M:\\Albums\\artist\\track.mp3
    - \\EchoVerse_Music\\Albums\\artist\\track.mp3
    - //envy2-0/EchoVerse_Music/Albums/artist/track.mp3
    - D:/Clients/AeroVista/Projects/EchoVerse_Music/Albums/artist/track.mp3
    - \\envy2-0EchoVerse_MusicAlbumsSynthetic SoulsPulse Code.m4a (missing backslashes)
    
    Returns:
    - Tailscale URL using the configured domain
    """
    print(f"Converting path: {file_path}")
    
    # Handle URL-encoded paths first
    if file_path.startswith('envy2-0EchoVerse_MusicAlbums'):
        # This is a malformed path missing backslashes and URL encoded
        # Use proper URL decoding
        import urllib.parse
        decoded_path = urllib.parse.unquote(file_path)
        print(f"URL decoded path: {decoded_path}")
        
        # Fix the path structure
        if 'Albums' in decoded_path:
            # Split at Albums and reconstruct properly
            parts = decoded_path.split('Albums', 1)
            if len(parts) == 2:
                # Reconstruct with proper backslashes
                fixed_path = '\\\\envy2-0\\EchoVerse_Music\\Albums\\' + parts[1].replace(' ', '\\')
                print(f"Fixed malformed path: {fixed_path}")
                file_path = fixed_path
    
    # Fix paths with missing backslashes
    if file_path.startswith('\\envy2-0') and '\\Albums' not in file_path and 'Albums' in file_path:
        # This is likely a path with missing backslashes
        # Try to reconstruct the path by adding backslashes at key points
        parts = file_path.split('Albums')
        if len(parts) == 2:
            fixed_path = parts[0].replace('\\envy2-0', '\\\\envy2-0\\') + 'Albums\\' + parts[1].replace(' ', '\\')
            print(f"Fixed path with missing backslashes: {fixed_path}")
            file_path = fixed_path
    
    # Normalize path separators
    normalized_path = file_path.replace('\\', '/')
    
    # Find the position of "Albums/" in the path
    albums_pos = normalized_path.find('Albums/')
    
    if albums_pos != -1:
        # Extract everything after "Albums/"
        relative_path = normalized_path[albums_pos + len('Albums/'):]
        # Create Tailscale URL using the full domain URL from configuration
        tailscale_url = f"{TAILSCALE_DOMAIN}{relative_path}"
        print(f"Generated Tailscale URL: {tailscale_url}")
        return tailscale_url
    
    # If we couldn't find "Albums/", try with backslashes (just in case)
    albums_pos = file_path.find('Albums\\')
    if albums_pos != -1:
        # Extract everything after "Albums\"
        relative_path = file_path[albums_pos + len('Albums\\'):].replace('\\', '/')
        # Create Tailscale URL using the full domain URL from configuration
        tailscale_url = f"{TAILSCALE_DOMAIN}{relative_path}"
        print(f"Generated Tailscale URL: {tailscale_url}")
        return tailscale_url
    
    # If we still can't find it, try to extract anything after "Albums"
    albums_pos = file_path.find('Albums')
    if albums_pos != -1:
        # Extract everything after "Albums"
        relative_path = file_path[albums_pos + len('Albums'):].lstrip('\\/ ').replace('\\', '/')
        # Create Tailscale URL using the full domain URL from configuration
        tailscale_url = f"{TAILSCALE_DOMAIN}{relative_path}"
        print(f"Generated Tailscale URL (fallback method): {tailscale_url}")
        return tailscale_url
    
    print(f"Could not extract path from: {file_path}")
    # If we still can't find it, return None
    return None

# CORS middleware for local development and Tailscale access
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Local development only
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Templates for HTML dashboard
templates = Jinja2Templates(directory="templates")

# Note: Static file mounting removed to avoid drive letter path conflicts
# All file serving is now handled through custom endpoints

# Global catalog data
catalog_data = []
albums_data = {}

def generate_unique_id(base_type, identifier, parent_id=None):
    """
    Generate unique IDs for tracing relationships:
    - base_type: 'track', 'album', 'artist'
    - identifier: name/title of the item
    - parent_id: parent's ID for hierarchical relationships
    
    Format: {base_type}_{hash}_{parent_hash}
    Example: track_a1b2c3_album_x9y8z7_artist_m5n6o7
    """
    # Create a hash from the identifier
    identifier_hash = hashlib.md5(identifier.encode()).hexdigest()[:8]
    
    if parent_id:
        # Extract parent hash from parent_id
        parent_hash = parent_id.split('_')[-1] if '_' in parent_id else 'root'
        return f"{base_type}_{identifier_hash}_{parent_hash}"
    else:
        # For top-level items (artists), create a hash from the name
        return f"{base_type}_{identifier_hash}"

def format_duration(seconds):
    """Convert seconds to MM:SS format"""
    if not seconds or pd.isna(seconds):
        return "0:00"
    try:
        seconds = int(float(seconds))
        minutes = seconds // 60
        remaining_seconds = seconds % 60
        return f"{minutes}:{remaining_seconds:02d}"
    except (ValueError, TypeError):
        return "0:00"

def load_music_catalog():
    """Load and parse the music catalog CSV"""
    global catalog_data, albums_data
    
    try:
        # Try multiple possible CSV locations
        csv_paths = [
            "M:/Albums/",
            "D:/Clients/AeroVista/Projects/EchoVerse_Music/Albums/",
            "music_catalog/",
            "\\\\envy2-0\\EchoVerse_Music\\Albums\\",  # Network share path
            "//envy2-0/EchoVerse_Music/Albums/"       # Alternative network path format
        ]
        
        csv_loaded = False
        latest_csv = None
        latest_time = 0
        
        for base_path in csv_paths:
            if os.path.exists(base_path):
                # Look for any CSV file starting with _inventory_ or music_catalog_
                try:
                    for file in os.listdir(base_path):
                        if (file.startswith('_inventory_') or file.startswith('music_catalog_') or file.startswith('music_catalog__')) and file.endswith('.csv'):
                            csv_path = os.path.join(base_path, file)
                            # Get file modification time to find the most recent
                            try:
                                file_time = os.path.getmtime(csv_path)
                            except Exception:
                                # Fallback to use creation time if mtime fails
                                file_time = os.path.getctime(csv_path)
                            if file_time > latest_time:
                                latest_time = file_time
                                latest_csv = csv_path
                except Exception as e:
                    print(f"Error reading from {base_path}: {e}")
                    continue
        
        # Load the most recent inventory file found
        if latest_csv:
            try:
                df = pd.read_csv(latest_csv, quoting=1)  # QUOTE_ALL to handle spaces in URLs
                
                # Clean NaN values that cause JSON serialization errors
                df = df.fillna('')  # Replace NaN with empty string
                
                # Convert to records and map to expected format
                catalog_data = []
                print(f"=== CSV DEBUG: Column names ===")
                print(f"Columns: {list(df.columns)}")
                print(f"=== CSV DEBUG: First 3 records ===")
                for i, record in enumerate(df.to_dict('records')[:3]):
                    print(f"Record {i+1}:")
                    print(f"  tailscale_echoverse_url: '{record.get('tailscale_echoverse_url', 'MISSING')}'")
                    print(f"  api_audio_pathparam: '{record.get('api_audio_pathparam', 'MISSING')}'")
                    print(f"  full_path: '{record.get('full_path', 'MISSING')}'")
                    if i == 0:  # Show first record's raw data
                        print(f"  Raw record keys: {list(record.keys())}")
                print("=== END CSV DEBUG ===")
                
                for record in df.to_dict('records'):
                    # Only include audio files
                    if record.get('mime_type', '').startswith('audio/'):
                        # Better title fallback - use filename if title is missing
                        track_title = record.get('title', '')
                        if not track_title or track_title == 'nan' or track_title.strip() == '':
                            # Extract title from filename (remove extension and track number)
                            filename = record.get('file_name', '')
                            if filename:
                                # Remove file extension
                                filename = os.path.splitext(filename)[0]
                                # Remove track number prefix if present (e.g., "01 - " or "01.")
                                filename = re.sub(r'^\d+[\s\-\.]+', '', filename)
                                track_title = filename if filename else 'Unknown Track'
                            else:
                                track_title = 'Unknown Track'
                        
                        # Better album art detection
                        cover_file = ''
                        if record.get('album'):
                            # First check if this record itself is an image file
                            file_path = record.get('full_path', '')
                            if file_path and any(file_path.lower().endswith(ext) for ext in ['.jpg', '.jpeg', '.png', '.gif', '.webp']):
                                # This record is an image file
                                cover_file = file_path
                                print(f"Found image file in CSV: {file_path}")
                            else:
                                # Look for common cover art filenames
                                album_path = os.path.dirname(record.get('full_path', ''))
                                if album_path:
                                    # Common cover art filenames (case insensitive)
                                    base_names = [
                                        'cover', 'album', 'front', 'folder', 'artwork', 'albumart', 
                                        'art', 'albumcover', 'cd', 'booklet', 'sleeve', 'inlay',
                                        record.get('album', '').lower().replace(' ', '')  # Album name as filename
                                    ]
                                    
                                    extensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp']
                                    
                                    # Generate all possible combinations
                                    cover_candidates = []
                                    for base in base_names:
                                        for ext in extensions:
                                            cover_candidates.append(os.path.join(album_path, f"{base}{ext}"))
                                    
                                    # Add numbered variants
                                    for i in range(1, 4):
                                        for ext in extensions:
                                            cover_candidates.append(os.path.join(album_path, f"cover{i}{ext}"))
                                            cover_candidates.append(os.path.join(album_path, f"{i}{ext}"))
                                    
                                    # Check all candidates
                                    for cover in cover_candidates:
                                        if os.path.exists(cover):
                                            cover_file = cover
                                            print(f"Found cover art for {record.get('album')}: {cover}")
                                            break
                                    
                                    # If still no cover, look for any image file in the album directory
                                    if not cover_file and os.path.exists(album_path):
                                        try:
                                            # First look for files with "cover" or "art" in the name
                                            for file in os.listdir(album_path):
                                                lower_file = file.lower()
                                                if any(term in lower_file for term in ['cover', 'art', 'front', 'album']) and \
                                                   any(lower_file.endswith(ext) for ext in extensions):
                                                    cover_file = os.path.join(album_path, file)
                                                    print(f"Found image file with cover keyword: {cover_file}")
                                                    break
                                            
                                            # If still no cover, take any image file
                                            if not cover_file:
                                                for file in os.listdir(album_path):
                                                    file_path = os.path.join(album_path, file)
                                                    if any(file.lower().endswith(ext) for ext in extensions):
                                                        cover_file = file_path
                                                        print(f"Found image file in album directory: {cover_file}")
                                                        break
                                        except Exception as e:
                                            print(f"Error listing directory {album_path}: {e}")
                                    
                                    if not cover_file:
                                        print(f"No cover art found for {record.get('album')} in {album_path}")
                        
                        # Generate unique IDs for hierarchical tracing
                        artist_name = record.get('artist', 'AeroVista')
                        album_name = record.get('album', 'Unknown Album')
                        
                        # Generate IDs in hierarchical order: artist -> album -> track
                        artist_id = generate_unique_id('artist', artist_name)
                        album_id = generate_unique_id('album', album_name, artist_id)
                        track_id = generate_unique_id('track', track_title, album_id)
                        
                        # Get tailscale URL from CSV if available
                        tailscale_url = record.get('tailscale_echoverse_url', '')
                        if not tailscale_url:
                            # Try to generate one from the file path
                            tailscale_url = convert_to_tailscale_url(record.get('full_path', ''))
                        
                        cleaned_record = {
                            'id': track_id,  # Unique track ID
                            'album_id': album_id,  # Album ID for grouping
                            'artist_id': artist_id,  # Artist ID for grouping
                            'album': album_name,
                            'artist': artist_name,
                            'track': track_title,
                            'duration': format_duration(record.get('length_seconds', 0)),
                            'file_size': record.get('size_bytes', 0),
                            'file_path': record.get('full_path', ''),
                            'cover_file': cover_file,
                            'lyrics_file': '',  # Will need to be added later
                            'track_number': record.get('track_number', ''),
                            'year': record.get('year', ''),
                            'genre': record.get('genre', ''),
                            'bitrate': record.get('bitrate', ''),
                            'sample_rate': record.get('sample_rate', ''),
                            'filename': record.get('file_name', ''),
                            'tailscale_echoverse_url': tailscale_url,
                            'api_audio_pathparam': record.get('api_audio_pathparam', '')
                        }
                        catalog_data.append(cleaned_record)
                
                csv_loaded = True
                print(f"Loaded catalog from: {latest_csv}")
                print(f"Total audio tracks: {len(catalog_data)}")
                
            except Exception as e:
                print(f"Error loading catalog from {latest_csv}: {e}")
                csv_loaded = False
        
        if not csv_loaded:
            # Create sample data for development
            catalog_data = create_sample_catalog()
            print("Using sample catalog data")
        
        # Group by album for better organization
        albums_data = group_by_album(catalog_data)
        
    except Exception as e:
        print(f"Error loading catalog: {e}")
        catalog_data = create_sample_catalog()
        albums_data = group_by_album(catalog_data)

def create_sample_catalog():
    """Create sample catalog data for development"""
    # Generate sample IDs
    artist_id = generate_unique_id('artist', 'AeroVista')
    album_id = generate_unique_id('album', 'Synthetic Souls', artist_id)
    
    return [
        {
            "id": generate_unique_id('track', 'Silicon Love', album_id),
            "album_id": album_id,
            "artist_id": artist_id,
            "album": "Synthetic Souls",
            "artist": "AeroVista",
            "track": "Silicon Love",
            "duration": "3:45",
            "file_size": 5120000,
            "file_path": "M:/Albums/Synthetic Souls/01 Silicon Love.mp3",
            "cover_file": "M:/Albums/Synthetic Souls/cover.jpg",
            "lyrics_file": "M:/Albums/Synthetic Souls/01 Silicon Love.txt",
            "tailscale_echoverse_url": "https://aerocoreos.tail79107c.ts.net/echoverse/Albums/Synthetic Souls/01 Silicon Love.mp3",
            "api_audio_pathparam": "/api/audio/M%3A%2FAlbums%2FSynthetic%20Souls%2F01%20Silicon%20Love.mp3"
        },
        {
            "id": generate_unique_id('track', 'Digital Heartbreak', album_id),
            "album_id": album_id,
            "artist_id": artist_id,
            "album": "Synthetic Souls",
            "artist": "AeroVista", 
            "track": "Digital Heartbreak",
            "duration": "4:12",
            "file_size": 6780000,
            "file_path": "M:/Albums/Synthetic Souls/02 Digital Heartbreak.mp3",
            "cover_file": "M:/Albums/Synthetic Souls/cover.jpg",
            "lyrics_file": "M:/Albums/Synthetic Souls/02 Digital Heartbreak.txt",
            "tailscale_echoverse_url": "https://aerocoreos.tail79107c.ts.net/echoverse/Albums/Synthetic Souls/02 Digital Heartbreak.mp3",
            "api_audio_pathparam": "/api/audio/M%3A%2FAlbums%2FSynthetic%20Souls%2F02%20Digital%20Heartbreak.mp3"
        },
        {
            "album": "Neon Dreams",
            "artist": "AeroVista",
            "track": "Electric Night",
            "duration": "3:28",
            "file_size": 4450000,
            "file_path": "M:/Albums/Neon Dreams/01 Electric Night.mp3",
            "cover_file": "M:/Albums/Neon Dreams/cover.jpg",
            "lyrics_file": "M:/Albums/Neon Dreams/01 Electric Night.txt",
            "tailscale_echoverse_url": "https://aerocoreos.tail79107c.ts.net/echoverse/Albums/Neon Dreams/01 Electric Night.mp3",
            "api_audio_pathparam": "/api/audio/M%3A%2FAlbums%2FNeon%20Dreams%2F01%20Electric%20Night.mp3"
        }
    ]

def group_by_album(data):
    """Group tracks by album"""
    albums = {}
    for track in data:
        album_name = track.get('album', 'Unknown Album')
        if album_name not in albums:
            albums[album_name] = {
                'id': track.get('album_id', ''),  # Album ID for tracing
                'album': album_name,
                'artist': track.get('artist', 'AeroVista'),
                'artist_id': track.get('artist_id', ''),  # Artist ID for tracing
                'tracks': [],
                'cover': '',  # Will be set after all tracks are processed
                'total_duration': 0,
                'total_size': 0
            }
        
        albums[album_name]['tracks'].append(track)
        
        # Update cover if this track has one and we don't have one yet
        if track.get('cover_file') and not albums[album_name]['cover']:
            albums[album_name]['cover'] = track.get('cover_file')
            print(f"Album {album_name} now has cover: {track.get('cover_file')}")
        
        # Safely handle file size
        file_size = track.get('file_size', 0)
        if pd.isna(file_size) or file_size == 'nan':
            file_size = 0
        try:
            file_size = float(file_size) if file_size else 0
        except (ValueError, TypeError):
            file_size = 0
        albums[album_name]['total_size'] += file_size
        
        # Parse duration safely
        duration = track.get('duration', '0:00')
        if pd.isna(duration) or duration == 'nan':
            duration = '0:00'
        try:
            if isinstance(duration, str) and ':' in str(duration):
                minutes, seconds = map(int, str(duration).split(':'))
                albums[album_name]['total_duration'] += minutes * 60 + seconds
        except (ValueError, TypeError):
            pass
    
    # Final check for albums without covers
    for album_name, album_data in albums.items():
        if not album_data['cover']:
            print(f"Album {album_name} has NO cover file")
    
    return albums

@app.get("/gallery")
async def gallery_page(request: Request):
    """Album Art Gallery page"""
    return templates.TemplateResponse("gallery.html", {"request": request})

@app.get("/images")
async def images_page(request: Request):
    """All Images Gallery page"""
    return templates.TemplateResponse("images.html", {"request": request})

@app.get("/", response_class=HTMLResponse)
async def root(request: Request):
    """Main dashboard"""
    return templates.TemplateResponse("dashboard.html", {
        "request": request,
        "total_albums": len(albums_data),
        "total_tracks": len(catalog_data),
        "total_size_gb": sum(track.get('file_size', 0) for track in catalog_data) / (1024**3)
    })

@app.get("/api/catalog")
async def get_catalog():
    """Get full catalog data"""
    # Debug: Check first few albums for cover art
    print("=== CATALOG DEBUG ===")
    for i, (album_name, album_data) in enumerate(list(albums_data.items())[:3]):
        print(f"Album {i+1}: {album_name}")
        print(f"  Cover: {album_data.get('cover', 'NO COVER')}")
        print(f"  Tracks: {len(album_data.get('tracks', []))}")
    print("===================")
    
    return {
        "albums": albums_data,
        "tracks": catalog_data,
        "stats": {
            "total_albums": len(albums_data),
            "total_tracks": len(catalog_data),
            "total_size_bytes": sum(track.get('file_size', 0) for track in catalog_data)
        }
    }

@app.get("/api/albums")
async def get_albums():
    """Get albums list"""
    return list(albums_data.values())

@app.get("/api/albums/{album_name}")
async def get_album(album_name: str):
    """Get specific album details"""
    if album_name not in albums_data:
        raise HTTPException(status_code=404, detail="Album not found")
    return albums_data[album_name]

@app.get("/api/search")
async def search_catalog(q: str = ""):
    """Search catalog by album, artist, track, or lyrics"""
    if not q:
        return catalog_data
    
    q_lower = q.lower()
    results = []
    
    for track in catalog_data:
        # Search in various fields
        if (q_lower in track.get('album', '').lower() or
            q_lower in track.get('artist', '').lower() or
            q_lower in track.get('track', '').lower()):
            results.append(track)
    
    return results

@app.post("/api/work-orders")
async def create_work_order(work_order: Dict[str, Any]):
    """Create a new work order"""
    try:
        # Add timestamp and ID
        work_order['id'] = f"wo_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
        work_order['created_at'] = datetime.now().isoformat()
        
        # Save to work orders file
        work_orders_file = "work_orders.json"
        existing_orders = []
        
        if os.path.exists(work_orders_file):
            with open(work_orders_file, 'r') as f:
                existing_orders = json.load(f)
        
        existing_orders.append(work_order)
        
        with open(work_orders_file, 'w') as f:
            json.dump(existing_orders, f, indent=2)
        
        return {"success": True, "work_order": work_order}
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error creating work order: {str(e)}")

@app.get("/api/work-orders")
async def get_work_orders():
    """Get all work orders"""
    try:
        work_orders_file = "work_orders.json"
        if os.path.exists(work_orders_file):
            with open(work_orders_file, 'r') as f:
                return json.load(f)
        return []
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error reading work orders: {str(e)}")

@app.get("/api/export-work-order/{work_order_id}")
async def export_work_order(work_order_id: str):
    """Export work order as JSON file"""
    try:
        work_orders_file = "work_orders.json"
        if not os.path.exists(work_orders_file):
            raise HTTPException(status_code=404, detail="No work orders found")
        
        with open(work_orders_file, 'r') as f:
            work_orders = json.load(f)
        
        work_order = next((wo for wo in work_orders if wo.get('id') == work_order_id), None)
        if not work_order:
            raise HTTPException(status_code=404, detail="Work order not found")
        
        # Create export filename
        export_filename = f"work_order_{work_order_id}.json"
        
        # Return JSON response for download
        return JSONResponse(
            content=work_order,
            headers={"Content-Disposition": f"attachment; filename={export_filename}"}
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error exporting work order: {str(e)}")

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "catalog_loaded": len(catalog_data) > 0}

@app.get("/api/tailscale-audio/{relative_path:path}")
async def tailscale_audio(relative_path: str):
    """Direct Tailscale audio streaming endpoint"""
    try:
        # Create Tailscale URL using the full domain URL from configuration
        tailscale_url = f"{TAILSCALE_DOMAIN}{relative_path}"
        print(f"Direct Tailscale URL: {tailscale_url}")
        return RedirectResponse(url=tailscale_url)
    except Exception as e:
        print(f"Error creating Tailscale URL: {e}")
        raise HTTPException(status_code=500, detail="Error creating Tailscale URL")

@app.get("/api/convert-path")
async def convert_path(path: str):
    """Convert any file path to a Tailscale URL"""
    try:
        # Convert the path to a Tailscale URL
        tailscale_url = convert_to_tailscale_url(path)
        
        if tailscale_url:
            return {"original_path": path, "tailscale_url": tailscale_url}
        else:
            return {"error": "Could not convert path", "original_path": path}
    except Exception as e:
        print(f"Error converting path: {e}")
        raise HTTPException(status_code=500, detail=f"Error converting path: {str(e)}")

@app.get("/api/config/tailscale")
async def get_tailscale_config():
    """Get the current Tailscale configuration"""
    try:
        return tailscale_config
    except Exception as e:
        print(f"Error getting Tailscale config: {e}")
        raise HTTPException(status_code=500, detail=f"Error getting Tailscale config: {str(e)}")

@app.post("/api/config/tailscale")
async def update_tailscale_config(updated_config: dict):
    """Update the Tailscale configuration"""
    try:
        global tailscale_config, TAILSCALE_DOMAIN, TAILSCALE_MUSIC_PATH, USE_TAILSCALE, ALLOWED_DIRS
        
        # Validate the updated config
        if "tailscale" not in updated_config or "domain" not in updated_config["tailscale"]:
            raise HTTPException(status_code=400, detail="Invalid configuration format")
        
        # Update the configuration file
        config_path = os.path.join(os.path.dirname(__file__), "config", "tailscale_config.json")
        with open(config_path, 'w') as f:
            json.dump(updated_config, f, indent=2)
        
        # Update global variables
        tailscale_config = updated_config
        TAILSCALE_DOMAIN = tailscale_config["tailscale"]["domain"]
        TAILSCALE_MUSIC_PATH = tailscale_config["tailscale"]["music_path"]
        USE_TAILSCALE = tailscale_config["tailscale"]["enabled"]
        
        # Update allowed directories
        ALLOWED_DIRS = [
            tailscale_config["local_paths"]["local_drive"],
            tailscale_config["local_paths"]["backup_drive"],
            "music_catalog/",
            tailscale_config["local_paths"]["network_share"],
            tailscale_config["local_paths"]["network_share"].replace('\\', '/')
        ]
        
        return {"status": "success", "message": "Configuration updated successfully", "config": tailscale_config}
    except HTTPException as e:
        raise e
    except Exception as e:
        print(f"Error updating Tailscale config: {e}")
        raise HTTPException(status_code=500, detail=f"Error updating Tailscale config: {str(e)}")

@app.get("/api/debug/catalog-sample")
async def debug_catalog_sample():
    """Debug endpoint to check catalog data structure"""
    if not catalog_data:
        return {"error": "No catalog data loaded"}
    
    # Return first few tracks with their file paths
    sample_tracks = catalog_data[:5]
    return {
        "total_tracks": len(catalog_data),
        "sample_tracks": [
            {
                "track": track.get('track', ''),
                "album": track.get('album', ''),
                "artist": track.get('artist', ''),
                "file_path": track.get('file_path', ''),
                "has_file_path": bool(track.get('file_path', ''))
            }
            for track in sample_tracks
        ]
    }

@app.get("/api/album-art/{album_name:path}")
async def get_album_art(album_name: str, use_tailscale: bool = None):
    """Get album art for a specific album"""
    if album_name not in albums_data:
        raise HTTPException(status_code=404, detail="Album not found")
    
    album = albums_data[album_name]
    cover_file = album.get('cover', '')
    
    if not cover_file:
        raise HTTPException(status_code=404, detail="Album art not found")
    
    # Use global setting if not specified
    use_tailscale_for_request = USE_TAILSCALE if use_tailscale is None else use_tailscale
    
    # If using Tailscale and we have a valid cover file, try to convert the path
    if use_tailscale_for_request and cover_file:
        # Use our path converter to get the Tailscale URL
        tailscale_url = convert_to_tailscale_url(cover_file)
        
        # If we got a valid Tailscale URL, redirect to it
        if tailscale_url:
            print(f"Redirecting to Tailscale URL for album art: {tailscale_url}")
            return RedirectResponse(url=tailscale_url)
        else:
            print(f"Could not convert cover file to Tailscale URL, falling back to direct streaming: {cover_file}")
    
    # Handle different drive letters and paths safely
    try:
        # Check if the file exists
        if not os.path.exists(cover_file):
            # Try to find the file using the same logic as audio files
            file_to_serve = None
            
            # Try to find the file in allowed directories
            file_name = os.path.basename(cover_file)
            for allowed_dir in ALLOWED_DIRS:
                if allowed_dir.endswith('/') or allowed_dir.endswith('\\'):
                    test_path = os.path.join(allowed_dir, file_name)
                else:
                    test_path = os.path.join(allowed_dir + '\\', file_name)
                
                if os.path.exists(test_path):
                    print(f"Found cover file in allowed directory: {test_path}")
                    file_to_serve = test_path
                    break
            
            if not file_to_serve:
                # Try to find the file by searching for the last part of the path
                path_parts = cover_file.replace('\\', '/').split('/')
                if len(path_parts) >= 2:
                    # Try the last two parts of the path
                    search_path = os.path.join(path_parts[-2], path_parts[-1])
                    for allowed_dir in ALLOWED_DIRS:
                        if allowed_dir.endswith('/') or allowed_dir.endswith('\\'):
                            test_path = os.path.join(allowed_dir, search_path)
                        else:
                            test_path = os.path.join(allowed_dir + '\\', search_path)
                        
                        if os.path.exists(test_path):
                            print(f"Found cover file using path parts: {test_path}")
                            file_to_serve = test_path
                            break
            
            if not file_to_serve:
                raise HTTPException(status_code=404, detail="Album art file not found")
            
            cover_file = file_to_serve
        
        # Determine content type based on file extension
        content_type = "image/jpeg"  # default
        if cover_file.lower().endswith('.png'):
            content_type = "image/png"
        elif cover_file.lower().endswith('.gif'):
            content_type = "image/gif"
        elif cover_file.lower().endswith('.webp'):
            content_type = "image/webp"
        
        print(f"Serving album art via direct path: {cover_file}")
        return FileResponse(cover_file, media_type=content_type)
    except Exception as e:
        print(f"Error serving album art {cover_file}: {e}")
        raise HTTPException(status_code=500, detail="Error serving album art")

@app.get("/api/all-images")
async def get_all_images():
    """Get all image files from the catalog data"""
    image_files = []
    processed_paths = set()  # Track processed paths to avoid duplicates
    image_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.svg', '.bmp', '.tiff', '.ico']
    
    # Look for all image files in the catalog data
    for record in catalog_data:
        file_path = record.get('full_path', '')
        
        # Skip if we've already processed this path
        if file_path in processed_paths:
            continue
            
        # Check if this is an image file
        if file_path and any(file_path.lower().endswith(ext) for ext in image_extensions):
            # This record is an image file
            try:
                # Try to get file info
                file_size = record.get('size_bytes', 0)
                if not file_size and os.path.exists(file_path):
                    file_size = os.path.getsize(file_path)
                
                # Add to image files list
                image_files.append({
                    'file_path': file_path,
                    'album': record.get('album', 'Unknown Album'),
                    'artist': record.get('artist', 'Unknown Artist'),
                    'file_size': file_size,
                    'file_name': os.path.basename(file_path),
                    'extension': os.path.splitext(file_path)[1].lower(),
                    'parent_folder': record.get('parent_folder', os.path.basename(os.path.dirname(file_path)))
                })
                processed_paths.add(file_path)
            except Exception as e:
                print(f"Error processing image file {file_path}: {e}")
    
    # Also scan directories for image files that might not be in the catalog
    try:
        # First, let's scan album directories from albums_data
        for album_name, album in albums_data.items():
            # Get tracks to find album directories
            for track in album.get('tracks', []):
                file_path = track.get('file_path', '')
                if file_path:
                    album_dir = os.path.dirname(file_path)
                    if os.path.exists(album_dir) and os.path.isdir(album_dir):
                        for file in os.listdir(album_dir):
                            if any(file.lower().endswith(ext) for ext in image_extensions):
                                image_path = os.path.join(album_dir, file)
                                # Skip if we've already processed this path
                                if image_path in processed_paths:
                                    continue
                                try:
                                    # Add to image files list
                                    image_files.append({
                                        'file_path': image_path,
                                        'album': album_name,
                                        'artist': album.get('artist', 'Unknown Artist'),
                                        'file_size': os.path.getsize(image_path),
                                        'file_name': file,
                                        'extension': os.path.splitext(file)[1].lower(),
                                        'parent_folder': os.path.basename(album_dir)
                                    })
                                    processed_paths.add(image_path)
                                except Exception as e:
                                    print(f"Error adding album directory image {image_path}: {e}")
                    break  # We only need one track to find the album directory
        
        # Then scan all allowed directories recursively
        for allowed_dir in ALLOWED_DIRS:
            if allowed_dir and os.path.exists(allowed_dir) and os.path.isdir(allowed_dir):
                print(f"Scanning directory for images: {allowed_dir}")
                for root, dirs, files in os.walk(allowed_dir):
                    for file in files:
                        if any(file.lower().endswith(ext) for ext in image_extensions):
                            file_path = os.path.join(root, file)
                            # Skip if we've already processed this path
                            if file_path in processed_paths:
                                continue
                            try:
                                # Try to determine album from path
                                parent_dir = os.path.basename(root)
                                grandparent_dir = os.path.basename(os.path.dirname(root))
                                album_name = parent_dir
                                
                                # If parent directory is "Albums", use grandparent
                                if parent_dir.lower() == "albums" and grandparent_dir:
                                    album_name = grandparent_dir
                                
                                # Add to image files list
                                image_files.append({
                                    'file_path': file_path,
                                    'album': album_name,
                                    'artist': 'Unknown Artist',
                                    'file_size': os.path.getsize(file_path),
                                    'file_name': file,
                                    'extension': os.path.splitext(file)[1].lower(),
                                    'parent_folder': parent_dir
                                })
                                processed_paths.add(file_path)
                            except Exception as e:
                                print(f"Error adding additional image file {file_path}: {e}")
    except Exception as e:
        print(f"Error scanning directories for images: {e}")
    
    print(f"Found {len(image_files)} image files in total from {len(processed_paths)} unique paths")
    
    return {
        "total_images": len(image_files),
        "images": image_files
    }

@app.get("/api/album-art-flipbook")
async def get_album_art_flipbook():
    """Get all available album art for flipbook browsing"""
    album_arts = []
    image_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.svg', '.bmp', '.tiff', '.ico']
    processed_paths = set()  # Track processed paths to avoid duplicates
    
    # First pass: Get album art from albums_data
    for album_name, album in albums_data.items():
        # Get the primary cover art
        cover_file = album.get('cover', '')
        if cover_file and os.path.exists(cover_file) and cover_file not in processed_paths:
            album_arts.append({
                'album': album_name,
                'artist': album.get('artist', 'AeroVista'),
                'cover_path': cover_file,
                'track_count': len(album.get('tracks', [])),
                'total_duration': album.get('total_duration', 0),
                'is_primary_cover': True
            })
            processed_paths.add(cover_file)
        
        # Get all tracks to find album directories and look for more images
        for track in album.get('tracks', []):
            file_path = track.get('file_path', '')
            if file_path:
                album_dir = os.path.dirname(file_path)
                if os.path.exists(album_dir) and os.path.isdir(album_dir):
                    for file in os.listdir(album_dir):
                        if any(file.lower().endswith(ext) for ext in image_extensions):
                            image_path = os.path.join(album_dir, file)
                            # Skip if we've already processed this path
                            if image_path in processed_paths:
                                continue
                            try:
                                # Add to album arts list
                                album_arts.append({
                                    'album': album_name,
                                    'artist': album.get('artist', 'AeroVista'),
                                    'cover_path': image_path,
                                    'track_count': len(album.get('tracks', [])),
                                    'total_duration': album.get('total_duration', 0),
                                    'is_primary_cover': False
                                })
                                processed_paths.add(image_path)
                            except Exception as e:
                                print(f"Error adding album directory image to flipbook {image_path}: {e}")
                break  # We only need one track to find the album directory
    
    # Second pass: Look for any image files in the catalog data
    for record in catalog_data:
        file_path = record.get('full_path', '')
        album_name = record.get('album', '')
        
        # Skip if we've already processed this path
        if file_path in processed_paths:
            continue
            
        # Check if this is an image file
        if file_path and any(file_path.lower().endswith(ext) for ext in image_extensions):
            # This record is an image file
            print(f"Found additional image file for gallery: {file_path}")
            
            # Get album data or create placeholder
            album_data = albums_data.get(album_name, {
                'artist': record.get('artist', 'Unknown'),
                'tracks': [],
                'total_duration': 0
            })
            
            album_arts.append({
                'album': album_name,
                'artist': album_data.get('artist', record.get('artist', 'Unknown')),
                'cover_path': file_path,
                'track_count': len(album_data.get('tracks', [])),
                'total_duration': album_data.get('total_duration', 0),
                'is_primary_cover': False
            })
            processed_paths.add(file_path)
    
    print(f"Found {len(album_arts)} album arts for gallery from {len(processed_paths)} unique paths")
    
    return {
        "total_albums_with_art": len(set(art['album'] for art in album_arts)),
        "total_images": len(album_arts),
        "album_arts": album_arts
    }

@app.get("/api/image/{file_path:path}")
async def stream_image(file_path: str, use_tailscale: bool = None):
    """
    Stream image files using the same logic as audio files
    
    Parameters:
    - file_path: Path to the image file
    - use_tailscale: Override global Tailscale setting (optional)
    """
    try:
        # Use global setting if not specified
        use_tailscale_for_request = USE_TAILSCALE if use_tailscale is None else use_tailscale
        
        # Decode the file path - handle all URL encoding
        import urllib.parse
        decoded_path = urllib.parse.unquote(file_path)
        print(f"Original image path: {file_path}")
        print(f"Decoded image path: {decoded_path}")
        
        # Handle malformed paths that are missing backslashes
        if decoded_path.startswith('envy2-0EchoVerse_MusicAlbums'):
            # This is a malformed path missing backslashes
            # Split at Albums and reconstruct properly
            parts = decoded_path.split('Albums', 1)
            if len(parts) == 2:
                # Reconstruct with proper backslashes
                fixed_path = '\\\\envy2-0\\EchoVerse_Music\\Albums\\' + parts[1].replace(' ', '\\')
                print(f"Fixed malformed image path: {fixed_path}")
                decoded_path = fixed_path
        
        # Fix paths with missing backslashes
        if decoded_path.startswith('\\envy2-0') and '\\Albums' not in decoded_path and 'Albums' in decoded_path:
            # This is likely a path with missing backslashes
            # Try to reconstruct the path by adding backslashes at key points
            parts = decoded_path.split('Albums')
            if len(parts) == 2:
                fixed_path = parts[0].replace('\\envy2-0', '\\\\envy2-0\\') + 'Albums\\' + parts[1].replace(' ', '\\')
                print(f"Fixed image path with missing backslashes: {fixed_path}")
                decoded_path = fixed_path
        
        # If using Tailscale, redirect to the Tailscale URL
        if use_tailscale_for_request:
            # Use our path converter to get the Tailscale URL
            tailscale_url = convert_to_tailscale_url(decoded_path)
            
            # If we got a valid Tailscale URL, redirect to it
            if tailscale_url:
                print(f"Redirecting to Tailscale URL for image: {tailscale_url}")
                return RedirectResponse(url=tailscale_url)
            else:
                print(f"Could not convert to Tailscale URL for image, falling back to direct streaming: {decoded_path}")
        
        # Try to find the file using a more flexible approach
        file_to_stream = None
        
        # First try the direct path
        if os.path.exists(decoded_path):
            file_to_stream = decoded_path
        else:
            # Check if the path is within allowed directories
            is_allowed = any(decoded_path.startswith(allowed_dir) for allowed_dir in ALLOWED_DIRS)
            
            if not is_allowed:
                # Try to find the file in allowed directories
                file_name = os.path.basename(decoded_path)
                for allowed_dir in ALLOWED_DIRS:
                    if allowed_dir.endswith('/') or allowed_dir.endswith('\\'):
                        test_path = os.path.join(allowed_dir, file_name)
                    else:
                        test_path = os.path.join(allowed_dir + '\\', file_name)
                    
                    if os.path.exists(test_path):
                        print(f"Found image in allowed directory: {test_path}")
                        file_to_stream = test_path
                        break
                
                if not file_to_stream:
                    # Try to find the file by searching for the last part of the path
                    path_parts = decoded_path.replace('\\', '/').split('/')
                    if len(path_parts) >= 2:
                        # Try the last two parts of the path
                        search_path = os.path.join(path_parts[-2], path_parts[-1])
                        for allowed_dir in ALLOWED_DIRS:
                            if allowed_dir.endswith('/') or allowed_dir.endswith('\\'):
                                test_path = os.path.join(allowed_dir, search_path)
                            else:
                                test_path = os.path.join(allowed_dir + '\\', search_path)
                            
                            if os.path.exists(test_path):
                                print(f"Found image using path parts: {test_path}")
                                file_to_stream = test_path
                                break
            else:
                # Path is allowed, but file might not exist
                if not os.path.exists(decoded_path):
                    print(f"Image file not found: {decoded_path}")
                    raise HTTPException(status_code=404, detail="Image file not found")
                file_to_stream = decoded_path
        
        if not file_to_stream:
            print(f"Could not find image file: {decoded_path}")
            print(f"Allowed directories: {ALLOWED_DIRS}")
            raise HTTPException(status_code=404, detail="Image file not found")
        
        # Determine content type based on file extension
        content_type = "image/jpeg"  # default for .jpg
        if file_to_stream.lower().endswith('.png'):
            content_type = "image/png"
        elif file_to_stream.lower().endswith('.gif'):
            content_type = "image/gif"
        elif file_to_stream.lower().endswith('.webp'):
            content_type = "image/webp"
        elif file_to_stream.lower().endswith('.svg'):
            content_type = "image/svg+xml"
        elif file_to_stream.lower().endswith('.ico'):
            content_type = "image/x-icon"
        
        print(f"Streaming image file via direct path: {file_to_stream}")
        
        # Return the image file with proper headers
        return FileResponse(
            file_to_stream, 
            media_type=content_type,
            headers={
                "Cache-Control": "public, max-age=3600",
                "Access-Control-Allow-Origin": "*"  # Allow cross-origin for Tailscale access
            }
        )
        
    except Exception as e:
        print(f"Error streaming image file {file_path}: {e}")
        raise HTTPException(status_code=500, detail="Error streaming image file")

@app.get("/api/track/{track_id}")
async def get_track_by_id(track_id: str):
    """Get track details by unique ID"""
    for track in catalog_data:
        if track.get('id') == track_id:
            return {
                "track": track,
                "relationships": {
                    "album_id": track.get('album_id'),
                    "artist_id": track.get('artist_id'),
                    "trace_path": f"track_{track_id} -> album_{track.get('album_id')} -> artist_{track.get('artist_id')}"
                }
            }
    raise HTTPException(status_code=404, detail="Track not found")

@app.get("/api/album/{album_id}")
async def get_album_by_id(album_id: str):
    """Get album details by unique ID"""
    for album_name, album_data in albums_data.items():
        if album_data.get('id') == album_id:
            return album_data
    raise HTTPException(status_code=404, detail="Album not found")

@app.get("/api/audio/{file_path:path}")
async def stream_audio(file_path: str, use_tailscale: bool = None):
    """
    Stream audio files for the integrated player
    
    Parameters:
    - file_path: Path to the audio file
    - use_tailscale: Override global Tailscale setting (optional)
    """
    try:
        # Use global setting if not specified
        use_tailscale_for_request = USE_TAILSCALE if use_tailscale is None else use_tailscale
        
        # Decode the file path - handle all URL encoding
        import urllib.parse
        decoded_path = urllib.parse.unquote(file_path)
        print(f"Original path: {file_path}")
        print(f"Decoded path: {decoded_path}")
        
        # Handle malformed paths that are missing backslashes
        if decoded_path.startswith('envy2-0EchoVerse_MusicAlbums'):
            # This is a malformed path missing backslashes
            # Split at Albums and reconstruct properly
            parts = decoded_path.split('Albums', 1)
            if len(parts) == 2:
                # Reconstruct with proper backslashes
                fixed_path = '\\\\envy2-0\\EchoVerse_Music\\Albums\\' + parts[1].replace(' ', '\\')
                print(f"Fixed malformed path: {fixed_path}")
                decoded_path = fixed_path
        
        # Fix paths with missing backslashes
        if decoded_path.startswith('\\envy2-0') and '\\Albums' not in decoded_path and 'Albums' in decoded_path:
            # This is likely a path with missing backslashes
            # Try to reconstruct the path by adding backslashes at key points
            parts = decoded_path.split('Albums')
            if len(parts) == 2:
                fixed_path = parts[0].replace('\\envy2-0', '\\\\envy2-0\\') + 'Albums\\' + parts[1].replace(' ', '\\')
                print(f"Fixed path with missing backslashes: {fixed_path}")
                decoded_path = fixed_path
        
        # If using Tailscale, redirect to the Tailscale URL
        if use_tailscale_for_request:
            # Use our path converter to get the Tailscale URL
            tailscale_url = convert_to_tailscale_url(decoded_path)
            
            # If we got a valid Tailscale URL, redirect to it
            if tailscale_url:
                print(f"Redirecting to Tailscale URL: {tailscale_url}")
                return RedirectResponse(url=tailscale_url)
            else:
                print(f"Could not convert to Tailscale URL, falling back to direct streaming: {decoded_path}")
        
        # If not using Tailscale or couldn't extract path, stream directly
        
        # Try to find the file using a more flexible approach
        file_to_stream = None
        
        # First try the direct path
        if os.path.exists(decoded_path):
            file_to_stream = decoded_path
        else:
            # Check if the path is within allowed directories
            is_allowed = any(decoded_path.startswith(allowed_dir) for allowed_dir in ALLOWED_DIRS)
            
            if not is_allowed:
                # Try to find the file in allowed directories
                file_name = os.path.basename(decoded_path)
                for allowed_dir in ALLOWED_DIRS:
                    if allowed_dir.endswith('/') or allowed_dir.endswith('\\'):
                        test_path = os.path.join(allowed_dir, file_name)
                    else:
                        test_path = os.path.join(allowed_dir + '\\', file_name)
                    
                    if os.path.exists(test_path):
                        print(f"Found file in allowed directory: {test_path}")
                        file_to_stream = test_path
                        break
                
                if not file_to_stream:
                    # Try to find the file by searching for the last part of the path
                    path_parts = decoded_path.replace('\\', '/').split('/')
                    if len(path_parts) >= 2:
                        # Try the last two parts of the path
                        search_path = os.path.join(path_parts[-2], path_parts[-1])
                        for allowed_dir in ALLOWED_DIRS:
                            if allowed_dir.endswith('/') or allowed_dir.endswith('\\'):
                                test_path = os.path.join(allowed_dir, search_path)
                            else:
                                test_path = os.path.join(allowed_dir + '\\', search_path)
                            
                            if os.path.exists(test_path):
                                print(f"Found file using path parts: {test_path}")
                                file_to_stream = test_path
                                break
            else:
                # Path is allowed, but file might not exist
                if not os.path.exists(decoded_path):
                    print(f"File not found: {decoded_path}")
                    raise HTTPException(status_code=404, detail="Audio file not found")
                file_to_stream = decoded_path
        
        if not file_to_stream:
            print(f"Could not find file: {decoded_path}")
            print(f"Allowed directories: {ALLOWED_DIRS}")
            raise HTTPException(status_code=404, detail="Audio file not found")
        
        # Determine content type based on file extension
        content_type = "audio/mpeg"  # default for .mp3
        if file_to_stream.lower().endswith('.wav'):
            content_type = "audio/wav"
        elif file_to_stream.lower().endswith('.flac'):
            content_type = "audio/flac"
        elif file_to_stream.lower().endswith('.ogg'):
            content_type = "audio/ogg"
        elif file_to_stream.lower().endswith('.m4a'):
            content_type = "audio/mp4"
        
        print(f"Streaming audio file via direct path: {file_to_stream}")
        
        # Return the audio file with proper headers for streaming
        return FileResponse(
            file_to_stream, 
            media_type=content_type,
            headers={
                "Accept-Ranges": "bytes",
                "Cache-Control": "public, max-age=3600",
                "Access-Control-Allow-Origin": "*"  # Allow cross-origin for Tailscale access
            }
        )
        
    except Exception as e:
        print(f"Error streaming audio file {file_path}: {e}")
        raise HTTPException(status_code=500, detail="Error streaming audio file")

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8001)
