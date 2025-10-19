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
