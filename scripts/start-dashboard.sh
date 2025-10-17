#!/bin/bash
# Start NXCore Dashboard on attached screen

# Set display
export DISPLAY=:0

# Start virtual display if needed
if ! pgrep -x "Xvfb" > /dev/null; then
    echo "Starting virtual display..."
    Xvfb :0 -screen 0 1920x1080x24 &
    sleep 2
fi

# Start Chrome in kiosk mode
echo "Starting dashboard..."
chromium-browser --kiosk --no-sandbox --disable-dev-shm-usage --disable-gpu --remote-debugging-port=9222 --user-data-dir=/tmp/chrome-dashboard http://localhost:8081/ &

echo "Dashboard started on http://localhost:8081/"
echo "Press Ctrl+C to stop"
