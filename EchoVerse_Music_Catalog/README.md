# EchoVerse Music Catalog

A comprehensive, AI-powered music catalog system built with FastAPI and modern web technologies, designed for professional music engineers and enthusiasts.

## 🚀 Quick Start

**The main entry point is `start_catalog.bat`**

Simply double-click or run:
```bash
start_catalog.bat
```

This will:
- Create a Python virtual environment
- Install all dependencies
- Start the FastAPI server
- Open the catalog at `http://localhost:8000`

## 🎯 What This System Does

- **Smart Music Organization**: AI-powered categorization and metadata management
- **Professional Work Orders**: Create playlists, albums, and remix projects
- **Advanced Browsing**: Multiple view modes with lazy loading and relationship tracing
- **Unique ID System**: Hierarchical tracing across tracks, albums, and artists
- **Local-First Architecture**: Works entirely offline with your local music files

## 📁 Core Files

- `start_catalog.bat` - **Main startup script**
- `main.py` - FastAPI backend server
- `requirements.txt` - Python dependencies
- `templates/` - HTML templates (dashboard.html, gallery.html)
- `Documentation/` - Comprehensive system documentation
- `work_orders.json` - Work order storage
- `Synthetic Souls/` - Sample music collection and analysis tools

## 🌐 Web Interfaces

- **Main Dashboard**: `http://localhost:8000` - Full catalog interface
- **Album Gallery**: `http://localhost:8000/gallery` - Album art browsing
- **Standalone HTML**: Customer-facing and embedded versions available

## 📊 Data Sources

The system automatically detects and loads the most recent `_inventory_*.csv` file from:
- `M:\Albums\` (primary mapped drive)
- `D:\Clients\AeroVista\Projects\EchoVerse_Music\Albums\`
- `C:\Users\[username]\Desktop\`

## 🔧 Manual Setup (Alternative)

If you prefer manual setup:
```bash
# Create virtual environment
python -m venv .venv

# Activate (Windows)
.venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Start server
python main.py
```

## 📖 Documentation

- `Documentation/README.md` - Complete project overview
- `Documentation/ARCHITECTURE.md` - Technical architecture
- `Documentation/API_REFERENCE.md` - Complete API documentation
- `NeXuS_Music_Catalog_Manual.html` - Interactive manual

## 🎵 Features

- **Intelligent Music Catalog**: Automatic CSV loading with metadata fallbacks
- **Unique ID System**: Hash-based hierarchical relationship tracking
- **Advanced Browsing**: Multiple view modes with smart grouping
- **Work Order System**: Professional project management
- **Performance Optimized**: Lazy loading and efficient filtering
- **Responsive Design**: Works on all device sizes

## 🔌 API Endpoints

- `GET /` - Main dashboard
- `GET /gallery` - Album art gallery
- `GET /api/catalog` - Full music catalog
- `GET /api/albums` - Albums grouped by artist
- `GET /api/search` - Search across all metadata
- `GET /api/work-orders` - Work order management
- `GET /health` - Server health check

## 🚨 Troubleshooting

### Server Won't Start
- Check Python installation and version
- Verify virtual environment activation
- Check port 8000 availability

### No Music Displayed
- Verify CSV file exists and is readable
- Check file paths in CSV match actual locations
- Ensure music files are accessible

### Images Not Loading
- Check album art file paths
- Verify image file formats (JPEG, PNG, etc.)
- Check file permissions

## 📞 Support

1. Check the `Documentation/` folder for detailed guides
2. Review console output for error messages
3. Use browser dev tools for debugging
4. Check the interactive manual: `NeXuS_Music_Catalog_Manual.html`

---

**EchoVerse Music Catalog** - Transforming music management with AI-powered intelligence and professional workflow tools.

*Built with ❤️ for music professionals and enthusiasts.*
