#!/bin/bash
# NXCore Certificate Installer - GitHub Pages Deployment

echo "🚀 Deploying NXCore Certificate Installer to GitHub Pages..."

# Configuration
GITHUB_USERNAME="your-username"  # Change this to your GitHub username
REPO_NAME="nxcore-certificate-installer"
GITHUB_PAGES_URL="https://$GITHUB_USERNAME.github.io/$REPO_NAME"

# Create GitHub repository structure
echo "📁 Creating GitHub repository structure..."
mkdir -p "github-pages"
cd "github-pages"

# Copy the main HTML file
cp "../certificate-installer.html" "index.html"

# Create a simple README for the repository
cat > "README.md" << 'EOF'
# NXCore Certificate Installer

🔐 **Automated certificate installation for secure access to NXCore services**

This GitHub Pages site provides an easy-to-use interface for installing NXCore certificates on various devices.

## Features

- 📱 **Android Support**: APK installer and manual installation guide
- 🖥️ **Windows Support**: EXE installer and manual installation guide  
- 🌐 **Universal Support**: Certificate files for any device
- 🔍 **Auto-Detection**: Automatically detects your device type
- 📖 **Comprehensive Guides**: Step-by-step installation instructions

## Quick Start

1. Visit the [Certificate Installer](https://your-username.github.io/nxcore-certificate-installer/)
2. Select your device type (auto-detected)
3. Download the appropriate installer
4. Follow the installation instructions
5. Enjoy secure access to NXCore services!

## Installation Methods

### Android Devices
- **APK Installer**: One-click installation with automatic certificate setup
- **Manual Installation**: Step-by-step guide for manual certificate installation

### Windows Computers  
- **EXE Installer**: Administrator-friendly installer with GUI
- **Manual Installation**: PowerShell and GUI installation methods

### Other Devices
- **Universal Files**: Download certificate files for manual installation
- **Cross-Platform**: Works with any device that supports certificate installation

## Certificate Files

- **Root CA Certificate**: `AeroVista-RootCA.cer`
- **Client Certificate**: `User-Gold.p12` (password: `CHANGE_ME`)

## Support

- **Documentation**: [NXCore Documentation](https://nxcore.tail79107c.ts.net/certs/)
- **Help**: [NXCore Help](https://nxcore.tail79107c.ts.net/help/)
- **Status**: [NXCore Status](https://nxcore.tail79107c.ts.net/status/)

## Security

- All certificates are for NXCore internal use only
- Do not share certificate files with others
- Keep your devices secure and up to date
- Report any security concerns immediately

## License

This project is part of the NXCore system and is intended for internal use only.
EOF

# Create a simple service worker for offline functionality
cat > "sw.js" << 'EOF'
// Service Worker for NXCore Certificate Installer
const CACHE_NAME = 'nxcore-cert-installer-v1';
const urlsToCache = [
  '/',
  '/index.html',
  '/README.md'
];

self.addEventListener('install', function(event) {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(function(cache) {
        return cache.addAll(urlsToCache);
      })
  );
});

self.addEventListener('fetch', function(event) {
  event.waitUntil(
    caches.match(event.request)
      .then(function(response) {
        if (response) {
          return response;
        }
        return fetch(event.request);
      }
    )
  );
});
EOF

# Create GitHub Actions workflow for automatic deployment
mkdir -p ".github/workflows"
cat > ".github/workflows/deploy.yml" << 'EOF'
name: Deploy to GitHub Pages

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy to GitHub Pages
      uses: peaceiris/actions-gh-pages@v3
      if: github.ref == 'refs/heads/main'
      with:
        github_token: ${{ secrets.GITHUB_TOKEN }}
        publish_dir: ./
EOF

# Create a simple package.json for the repository
cat > "package.json" << 'EOF'
{
  "name": "nxcore-certificate-installer",
  "version": "1.0.0",
  "description": "Automated certificate installation for NXCore services",
  "main": "index.html",
  "scripts": {
    "start": "python -m http.server 8000",
    "deploy": "gh-pages -d ."
  },
  "repository": {
    "type": "git",
    "url": "git+https://github.com/your-username/nxcore-certificate-installer.git"
  },
  "keywords": [
    "nxcore",
    "certificates",
    "ssl",
    "security",
    "installer"
  ],
  "author": "NXCore Team",
  "license": "MIT",
  "bugs": {
    "url": "https://github.com/your-username/nxcore-certificate-installer/issues"
  },
  "homepage": "https://your-username.github.io/nxcore-certificate-installer/"
}
EOF

# Create a simple .gitignore
cat > ".gitignore" << 'EOF'
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Runtime data
pids
*.pid
*.seed
*.pid.lock

# Coverage directory used by tools like istanbul
coverage/

# nyc test coverage
.nyc_output

# Grunt intermediate storage
.grunt

# Bower dependency directory
bower_components

# node-waf configuration
.lock-wscript

# Compiled binary addons
build/Release

# Dependency directories
jspm_packages/

# Optional npm cache directory
.npm

# Optional REPL history
.node_repl_history

# Output of 'npm pack'
*.tgz

# Yarn Integrity file
.yarn-integrity

# dotenv environment variables file
.env

# IDE files
.vscode/
.idea/
*.swp
*.swo

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db
EOF

# Create deployment instructions
cat > "DEPLOYMENT.md" << 'EOF'
# NXCore Certificate Installer - Deployment Guide

## GitHub Pages Deployment

### Prerequisites
- GitHub account
- Git installed on your system
- Basic knowledge of Git and GitHub

### Step 1: Create GitHub Repository

1. Go to [GitHub](https://github.com) and sign in
2. Click "New repository"
3. Repository name: `nxcore-certificate-installer`
4. Description: `Automated certificate installation for NXCore services`
5. Make it **Public** (required for GitHub Pages)
6. Don't initialize with README (we'll add our own)
7. Click "Create repository"

### Step 2: Upload Files

1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/nxcore-certificate-installer.git
   cd nxcore-certificate-installer
   ```

2. Copy all files from this directory to your repository

3. Commit and push:
   ```bash
   git add .
   git commit -m "Initial commit: NXCore Certificate Installer"
   git push origin main
   ```

### Step 3: Enable GitHub Pages

1. Go to your repository on GitHub
2. Click "Settings" tab
3. Scroll down to "Pages" section
4. Source: "Deploy from a branch"
5. Branch: "main"
6. Folder: "/ (root)"
7. Click "Save"

### Step 4: Access Your Site

Your certificate installer will be available at:
`https://your-username.github.io/nxcore-certificate-installer/`

### Step 5: Update Certificate URLs

1. Edit `index.html`
2. Replace `https://nxcore.tail79107c.ts.net/certs/` with your actual NXCore server URLs
3. Update the GitHub repository URL in the HTML file
4. Commit and push changes

## Customization

### Changing the Repository Name
1. Update `REPO_NAME` in the deployment script
2. Update all references in the HTML file
3. Update the GitHub Pages URL

### Adding More Devices
1. Add new device cards in the HTML
2. Add corresponding installation sections
3. Update the JavaScript device detection logic

### Styling Changes
1. Modify the CSS in the `<style>` section of `index.html`
2. Test on different devices and browsers
3. Ensure responsive design works properly

## Maintenance

### Updating Certificate Files
1. Update the certificate URLs in the HTML file
2. Test all download links
3. Update installation guides if needed

### Adding New Features
1. Modify the HTML structure
2. Update JavaScript functionality
3. Test thoroughly before deploying
4. Update documentation

## Troubleshooting

### GitHub Pages Not Working
1. Check that the repository is public
2. Verify GitHub Pages is enabled
3. Check the Actions tab for deployment errors
4. Ensure all files are in the root directory

### Certificate Downloads Not Working
1. Verify the NXCore server is accessible
2. Check that certificate files exist
3. Test download links manually
4. Update URLs if server has changed

### Auto-Detection Not Working
1. Check browser console for JavaScript errors
2. Verify device detection logic
3. Test on different devices
4. Update user agent detection if needed
EOF

# Create a simple HTTP server for local testing
cat > "test-server.py" << 'EOF'
#!/usr/bin/env python3
"""
Simple HTTP server for testing the NXCore Certificate Installer locally
"""

import http.server
import socketserver
import webbrowser
import os
import sys

PORT = 8000

class MyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def end_headers(self):
        # Add CORS headers for local testing
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        super().end_headers()

def start_server():
    """Start the local HTTP server"""
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    
    with socketserver.TCPServer(("", PORT), MyHTTPRequestHandler) as httpd:
        print(f"🚀 NXCore Certificate Installer Test Server")
        print(f"📱 Local URL: http://localhost:{PORT}")
        print(f"🌐 Open in browser: http://localhost:{PORT}")
        print(f"⏹️  Press Ctrl+C to stop")
        
        # Open browser automatically
        try:
            webbrowser.open(f'http://localhost:{PORT}')
        except:
            pass
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\n👋 Server stopped")
            sys.exit(0)

if __name__ == "__main__":
    start_server()
EOF

chmod +x "test-server.py"

# Create a deployment script
cat > "deploy.sh" << 'EOF'
#!/bin/bash
# NXCore Certificate Installer - Quick Deployment Script

echo "🚀 Deploying NXCore Certificate Installer..."

# Configuration
GITHUB_USERNAME="your-username"  # Change this to your GitHub username
REPO_NAME="nxcore-certificate-installer"

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git first."
    exit 1
fi

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo "📁 Initializing Git repository..."
    git init
    git remote add origin "https://github.com/$GITHUB_USERNAME/$REPO_NAME.git"
fi

# Add all files
echo "📤 Adding files to Git..."
git add .

# Commit changes
echo "💾 Committing changes..."
git commit -m "Update NXCore Certificate Installer"

# Push to GitHub
echo "🚀 Pushing to GitHub..."
git push origin main

echo "✅ Deployment complete!"
echo "🌐 Your certificate installer is available at:"
echo "   https://$GITHUB_USERNAME.github.io/$REPO_NAME/"
echo ""
echo "📝 Next steps:"
echo "   1. Enable GitHub Pages in repository settings"
echo "   2. Update certificate URLs in index.html"
echo "   3. Test the installer on different devices"
EOF

chmod +x "deploy.sh"

# Create a simple test script
cat > "test.sh" << 'EOF'
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
EOF

chmod +x "test.sh"

cd ..

echo "✅ GitHub Pages deployment structure created!"
echo ""
echo "📁 Files created in 'github-pages' directory:"
echo "   - index.html (main certificate installer page)"
echo "   - README.md (repository documentation)"
echo "   - sw.js (service worker for offline functionality)"
echo "   - .github/workflows/deploy.yml (GitHub Actions workflow)"
echo "   - package.json (npm package configuration)"
echo "   - .gitignore (Git ignore file)"
echo "   - DEPLOYMENT.md (deployment instructions)"
echo "   - test-server.py (local testing server)"
echo "   - deploy.sh (deployment script)"
echo "   - test.sh (testing script)"
echo ""
echo "🚀 Next steps:"
echo "   1. Update 'your-username' in all files with your GitHub username"
echo "   2. Create a new GitHub repository: $REPO_NAME"
echo "   3. Copy files from 'github-pages' directory to your repository"
echo "   4. Enable GitHub Pages in repository settings"
echo "   5. Update certificate URLs in index.html"
echo ""
echo "🧪 Test locally:"
echo "   cd github-pages && ./test.sh"
echo ""
echo "📤 Deploy to GitHub:"
echo "   cd github-pages && ./deploy.sh"
echo ""
echo "🌐 Your certificate installer will be available at:"
echo "   https://$GITHUB_USERNAME.github.io/$REPO_NAME/"
