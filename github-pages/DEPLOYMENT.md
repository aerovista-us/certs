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
