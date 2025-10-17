@echo off
echo ========================================
echo    ECHOVERSE LUXURY MUSIC CATALOG
echo ========================================
echo.
echo Starting EchoVerse Music Catalog System with Luxury Features...
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH
    echo Please install Python 3.8+ and try again
    pause
    exit /b 1
)

REM Check if virtual environment exists
if not exist ".venv" (
    echo Creating virtual environment...
    python -m venv .venv
)

REM Activate virtual environment
echo Activating virtual environment...
call .venv\Scripts\activate

REM Install dependencies
echo Installing dependencies...
pip install -r requirements.txt

REM Display Luxury Features Info
echo.
echo ========================================
echo    LUXURY FEATURES ENABLED
echo ========================================
echo.
echo 🎵 Enhanced Audio Processing:
echo - Web Audio API with real-time spectrum analysis
echo - Professional EQ with bass/treble controls
echo - Spatial reverb effects for immersive listening
echo - Automatic audio quality optimization
echo.
echo 🎨 Advanced Theme System:
echo - Custom color pickers for complete personalization
echo - Multi-color gradient support with direction control
echo - 6 beautiful preset themes (Default, Ocean, Sunset, Forest, Purple, Minimal)
echo - Export/import themes for sharing
echo - Real-time theme preview
echo.
echo 🖱️ Context-Aware Right-Click Menus:
echo - Smart song management with contextual options
echo - Rate songs with interactive star dialogs
echo - Add personal notes and searchable tags
echo - Work order integration for song management
echo - Share songs via multiple methods
echo - Keyboard shortcuts for quick access
echo.
echo 🎵 Persistent Audio Playback:
echo - Background audio that continues across page navigation
echo - Floating controls always accessible
echo - Cross-page persistence with automatic resume
echo - Browser notifications for audio events
echo - Real-time spectrum analyzer visualization
echo.
echo 📊 Advanced Metadata Management:
echo - Comprehensive song ratings and personal notes
echo - Searchable tag system for organization
echo - Play count tracking and analytics
echo - Work order integration for song management
echo - Export/import metadata for backup
echo.
echo 🌐 Network Integration:
echo - Primary: \\envy2-0\EchoVerse_Music\Albums\
echo - Tailscale: Configurable secure streaming
echo - Local: M:\Albums\
echo - Backup: D:\Clients\AeroVista\Projects\EchoVerse_Music\Albums\
echo.
echo 🚀 Performance Optimizations:
echo - FastAPI with async processing
echo - Efficient audio streaming
echo - Optimized database queries
echo - Cached metadata for instant access
echo - Progressive enhancement for all browsers
echo.

REM Start the server
echo Starting FastAPI server...
echo The luxury catalog will be available at: http://localhost:8000
echo.
echo ========================================
echo    LUXURY CATALOG FEATURES
echo ========================================
echo.
echo 🎵 Audio Features:
echo - Right-click any song for advanced options
echo - Click ▶️ to play with enhanced audio processing
echo - Use 🎨 Theme button for complete customization
echo - Background audio continues when navigating
echo - Real-time spectrum analyzer shows audio frequencies
echo.
echo 🎨 Theme Customization:
echo - Click 🎨 Theme button in top-right corner
echo - Choose "Customize" for full theme editor
echo - Pick colors, gradients, and directions
echo - Export/import themes for sharing
echo - Try preset themes for instant changes
echo.
echo 🖱️ Context Menus:
echo - Right-click any song for contextual options
echo - Rate, note, tag, and manage songs
echo - Add to work orders and playlists
echo - Share songs and copy links
echo - Use keyboard shortcuts for quick access
echo.
echo 📊 Metadata Management:
echo - View and edit song ratings, notes, and tags
echo - Track play counts and listening history
echo - Organize songs with custom tags
echo - Filter by favorites, ratings, and tags
echo - Export metadata for backup
echo.
echo 🌐 Network Streaming:
echo - Automatic fallback between network sources
echo - Tailscale secure streaming when available
echo - Local file access for offline use
echo - Optimized streaming for different network conditions
echo.
echo Click any "▶️ Play" button to start listening!
echo Right-click songs for advanced management options!
echo Use 🎨 Theme button for complete customization!
echo Check browser console (F12) for detailed logs.
echo.
echo Press Ctrl+C to stop the server
echo.

python main.py

pause
