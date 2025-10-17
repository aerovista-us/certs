@echo off
echo Starting EchoVerse Music Catalog System...
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

REM Display Synthetic Souls Collection Info
echo.
echo ========================================
echo    SYNTHETIC SOULS COLLECTION LOADED
echo ========================================
echo.
echo Collection Statistics:
echo - 60 tracks analyzed with complete lyrics
echo - 183.33 minutes of cyberpunk electronic music
echo - 197.98 MB of high-quality audio content
echo - Sentiment analysis: 97%% negative (authentic cyberpunk)
echo - Top themes: Light, Technology, Identity, Emotion, Time
echo.
echo Analysis Tools Available:
echo - Enhanced lyrics analyzer with sentiment breakdown
echo - Complete track metadata and file information
echo - Character profiles and cross-reference documentation
echo.

REM Start the server
echo Starting FastAPI server...
echo The catalog will be available at: http://localhost:8000
echo.
echo ========================================
echo    INTEGRATED AUDIO PLAYER ENABLED
echo ========================================
echo.
echo Features Available:
echo - 🎵 Built-in audio player with full controls
echo - ▶️ Play/pause, seek, and volume control
echo - 📱 Responsive player that slides up from bottom
echo - 🔄 Auto-play next track in album
echo - 🎨 Modern glassmorphism design
echo - 📊 Real-time progress tracking
echo - 🌐 Network share support (\\envy2-0\EchoVerse_Music\Albums\)
echo - 🔒 Tailscale secure streaming with configurable domain
echo - ⚙️ Settings page for Tailscale configuration
echo.
echo Music Storage Locations:
echo - Primary: \\envy2-0\EchoVerse_Music\Albums\
echo - Tailscale: Configurable via Settings page
echo - Local: M:\Albums\
echo - Backup: D:\Clients\AeroVista\Projects\EchoVerse_Music\Albums\
echo.
echo Streaming Options:
echo - Tailscale streaming can be enabled/disabled in Settings
echo - Automatic fallback to direct streaming if Tailscale is unavailable
echo - Path conversion tool for testing Tailscale URLs
echo.
echo Click any "▶️ Play" button to start listening!
echo Check browser console (F12) for detailed audio streaming logs.
echo.
echo Press Ctrl+C to stop the server
echo.

python main.py

pause
