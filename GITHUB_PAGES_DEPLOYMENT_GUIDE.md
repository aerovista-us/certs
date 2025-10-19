# NXCore Certificate Installer - GitHub Pages Deployment Guide

## 🚀 **Complete GitHub Pages Setup for NXCore Certificate Installer**

### **Overview**
This guide will help you deploy the NXCore Certificate Installer to GitHub Pages, making it accessible via a simple HTTP URL that can be shared with users for easy certificate installation.

---

## **📋 Prerequisites**

- ✅ GitHub account
- ✅ Git installed on your system
- ✅ Basic knowledge of Git and GitHub
- ✅ NXCore server running and accessible

---

## **🔧 Step 1: Create GitHub Repository**

### **1.1 Create New Repository**
1. Go to [GitHub](https://github.com) and sign in
2. Click the **"+"** button → **"New repository"**
3. Repository name: `nxcore-certificate-installer`
4. Description: `Automated certificate installation for NXCore services`
5. Make it **Public** (required for GitHub Pages)
6. **Don't** initialize with README (we have our own)
7. Click **"Create repository"**

### **1.2 Note Your Repository URL**
Your repository will be at: `https://github.com/YOUR_USERNAME/nxcore-certificate-installer`

---

## **📁 Step 2: Prepare Files for Deployment**

### **2.1 Files Ready for Deployment**
The following files are already created in the `github-pages` directory:

- ✅ `index.html` - Main certificate installer page
- ✅ `README.md` - Repository documentation
- ✅ `sw.js` - Service worker for offline functionality
- ✅ `package.json` - npm package configuration
- ✅ `.gitignore` - Git ignore file
- ✅ `DEPLOYMENT.md` - Detailed deployment instructions
- ✅ `test-server.py` - Local testing server
- ✅ `test.sh` - Testing script
- ✅ `deploy.sh` - Deployment script

### **2.2 Update Configuration**
Before deploying, update these files:

1. **Edit `index.html`**:
   - Replace `your-username` with your actual GitHub username
   - Update certificate URLs to point to your NXCore server
   - Update GitHub repository URL

2. **Edit `package.json`**:
   - Update repository URL with your GitHub username
   - Update homepage URL

3. **Edit `deploy.sh`**:
   - Update `GITHUB_USERNAME` variable with your username

---

## **🚀 Step 3: Deploy to GitHub**

### **3.1 Clone Your Repository**
```bash
git clone https://github.com/YOUR_USERNAME/nxcore-certificate-installer.git
cd nxcore-certificate-installer
```

### **3.2 Copy Files**
```bash
# Copy all files from the github-pages directory
cp -r ../github-pages/* .
```

### **3.3 Initial Commit**
```bash
git add .
git commit -m "Initial commit: NXCore Certificate Installer"
git push origin main
```

---

## **🌐 Step 4: Enable GitHub Pages**

### **4.1 Enable Pages**
1. Go to your repository on GitHub
2. Click **"Settings"** tab
3. Scroll down to **"Pages"** section
4. Source: **"Deploy from a branch"**
5. Branch: **"main"**
6. Folder: **"/ (root)"**
7. Click **"Save"**

### **4.2 Wait for Deployment**
- GitHub Pages typically takes 1-2 minutes to deploy
- You'll see a green checkmark when deployment is complete

---

## **✅ Step 5: Access Your Certificate Installer**

### **5.1 Your Certificate Installer URL**
Your certificate installer will be available at:
```
https://YOUR_USERNAME.github.io/nxcore-certificate-installer/
```

### **5.2 Test the Installer**
1. Open the URL in your browser
2. Test device auto-detection
3. Test download links
4. Verify all functionality works

---

## **🧪 Step 6: Local Testing (Optional)**

### **6.1 Test Locally Before Deployment**
```bash
cd github-pages
./test.sh
```

This will start a local HTTP server at `http://localhost:8000`

### **6.2 Test Features**
- ✅ Device auto-detection
- ✅ Download button functionality
- ✅ Responsive design
- ✅ Cross-browser compatibility

---

## **🔧 Step 7: Customization and Updates**

### **7.1 Update Certificate URLs**
Edit `index.html` and update these URLs:
```html
<!-- Replace these with your actual NXCore server URLs -->
https://nxcore.tail79107c.ts.net/certs/android/cert-installer.apk
https://nxcore.tail79107c.ts.net/certs/windows/cert-installer.exe
https://nxcore.tail79107c.ts.net/certs/universal/AeroVista-RootCA.cer
https://nxcore.tail79107c.ts.net/certs/universal/User-Gold.p12
```

### **7.2 Add More Devices**
To add support for more devices:
1. Add new device cards in the HTML
2. Add corresponding installation sections
3. Update JavaScript device detection logic

### **7.3 Update Styling**
Modify the CSS in the `<style>` section of `index.html` to match your branding.

---

## **📱 Step 8: Mobile Testing**

### **8.1 Test on Android**
1. Open the certificate installer URL on Android
2. Verify auto-detection works
3. Test APK download
4. Test manual installation guide

### **8.2 Test on Windows**
1. Open the certificate installer URL on Windows
2. Verify auto-detection works
3. Test EXE download
4. Test manual installation guide

---

## **🔄 Step 9: Ongoing Maintenance**

### **9.1 Update Certificate Files**
When certificates change:
1. Update the certificate URLs in `index.html`
2. Test all download links
3. Update installation guides if needed
4. Commit and push changes

### **9.2 Add New Features**
1. Modify the HTML structure
2. Update JavaScript functionality
3. Test thoroughly before deploying
4. Update documentation

---

## **🆘 Troubleshooting**

### **GitHub Pages Not Working**
- ✅ Check that the repository is **public**
- ✅ Verify GitHub Pages is enabled in Settings
- ✅ Check the Actions tab for deployment errors
- ✅ Ensure all files are in the root directory

### **Certificate Downloads Not Working**
- ✅ Verify the NXCore server is accessible
- ✅ Check that certificate files exist on the server
- ✅ Test download links manually
- ✅ Update URLs if server has changed

### **Auto-Detection Not Working**
- ✅ Check browser console for JavaScript errors
- ✅ Verify device detection logic
- ✅ Test on different devices
- ✅ Update user agent detection if needed

---

## **📊 Final Result**

After completing all steps, you'll have:

- ✅ **Public GitHub Repository**: `https://github.com/YOUR_USERNAME/nxcore-certificate-installer`
- ✅ **Live Certificate Installer**: `https://YOUR_USERNAME.github.io/nxcore-certificate-installer/`
- ✅ **Automated Device Detection**: Works on Android, Windows, and other devices
- ✅ **One-Click Downloads**: APK for Android, EXE for Windows
- ✅ **Manual Installation Guides**: Step-by-step instructions for all devices
- ✅ **Offline Functionality**: Service worker for offline access
- ✅ **Responsive Design**: Works on all screen sizes

---

## **🎉 Success!**

Your NXCore Certificate Installer is now live and ready to use! Share the URL with users who need to install certificates for secure access to NXCore services.

**Certificate Installer URL**: `https://YOUR_USERNAME.github.io/nxcore-certificate-installer/`

---

## **📞 Support**

- **Documentation**: [NXCore Documentation](https://nxcore.tail79107c.ts.net/certs/)
- **Help**: [NXCore Help](https://nxcore.tail79107c.ts.net/help/)
- **Status**: [NXCore Status](https://nxcore.tail79107c.ts.net/status/)
