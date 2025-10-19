#!/bin/bash
# Test the NXCore Certificate Installer locally

echo "🧪 Testing NXCore Certificate Installer..."

# Check if Python is available
if command -v python3 &> /dev/null; then
    echo "🐍 Starting Python HTTP server..."
    python3 test-server.py
elif command -v python &> /dev/null; then
    echo "🐍 Starting Python HTTP server..."
    python test-server.py
else
    echo "❌ Python is not installed. Please install Python first."
    echo "💡 Alternative: Use any HTTP server to serve the files"
    exit 1
fi
