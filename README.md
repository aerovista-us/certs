# NXCore Certificate Management System

🔐 **Complete certificate management and installation system for NXCore services**

## 🚀 Quick Start

### Certificate Installer (GitHub Pages)
Visit our automated certificate installer: **[https://aerovista-us.github.io/certs/](https://aerovista-us.github.io/certs/)**

- 📱 **Android**: One-click APK installer
- 🖥️ **Windows**: One-click EXE installer  
- 🌐 **Universal**: Manual installation files
- 🔍 **Auto-Detection**: Automatically detects your device type

## 📁 Repository Structure

```
├── certificate-installer.html          # Main certificate installer page
├── github-pages/                      # GitHub Pages deployment files
│   ├── index.html                     # GitHub Pages version
│   ├── README.md                      # GitHub Pages documentation
│   └── sw.js                          # Service worker for offline support
├── scripts/                           # Certificate management scripts
│   ├── create-certificate-bundle-kit.sh
│   ├── create-android-cert-installer.sh
│   ├── create-windows-cert-installer.sh
│   └── deploy-certificate-bundles.sh
├── documents/                         # NXCore documentation
│   ├── Certificate System/            # Certificate system documentation
│   └── reports/                       # System reports and analysis
└── NXCore-Control/                    # Full NXCore project files
    ├── scripts/                       # NXCore management scripts
    ├── docker/                        # Docker configurations
    └── documents/                     # NXCore documentation
```

## 🔐 Certificate Installation

### For Users
1. **Visit**: [https://aerovista-us.github.io/certs/](https://aerovista-us.github.io/certs/)
2. **Select Device**: Android, Windows, or Other
3. **Download**: APK (Android) or EXE (Windows) installer
4. **Install**: Follow the automated installation process
5. **Verify**: Visit NXCore services to confirm green lock icons

### For Administrators
1. **Deploy Certificates**: Use scripts in `scripts/` directory
2. **Update Installers**: Modify HTML files and redeploy
3. **Monitor Usage**: Track certificate installation success rates
4. **Maintain System**: Regular updates and security patches

## 📱 Device Support

### Android Devices
- ✅ **APK Installer**: Automatic certificate installation
- ✅ **Manual Installation**: Step-by-step guide
- ✅ **Download**: [Android APK Installer](https://aerovista-us.github.io/certs/android/cert-installer.apk)

### Windows Computers
- ✅ **EXE Installer**: Administrator-friendly installation
- ✅ **PowerShell**: Command-line installation
- ✅ **Manual Installation**: GUI and command-line methods
- ✅ **Download**: [Windows EXE Installer](https://aerovista-us.github.io/certs/windows/cert-installer.exe)

### Other Devices
- ✅ **Universal Files**: Certificate files for any device
- ✅ **Manual Installation**: Comprehensive guides
- ✅ **Cross-Platform**: Works with any operating system

## 🛠️ Development

### Local Testing
```bash
# Test certificate installer locally
cd github-pages
python -m http.server 8000
# Visit: http://localhost:8000
```

### Deployment
```bash
# Deploy to GitHub Pages
git add .
git commit -m "Update certificate installer"
git push origin main
```

### Certificate Management
```bash
# Generate new certificates
./scripts/create-certificate-bundle-kit.sh

# Deploy to NXCore server
./scripts/deploy-certificate-bundles.sh
```

## 📊 Features

### Certificate Installer
- 🔍 **Auto-Detection**: Automatically detects device type
- 📱 **Responsive Design**: Works on all screen sizes
- 🚀 **One-Click Installation**: Automated certificate setup
- 📖 **Comprehensive Guides**: Step-by-step instructions
- 🔒 **Secure Downloads**: HTTPS-only certificate distribution
- 🌐 **Offline Support**: Service worker for offline functionality

### NXCore System
- 🐳 **Docker Integration**: Containerized services
- 🔐 **SSL/TLS Management**: Automated certificate handling
- 📊 **Monitoring**: Service health and status monitoring
- 🛡️ **Security**: Comprehensive security headers and policies
- 🔄 **Automation**: Automated deployment and management scripts

## 🔧 Configuration

### Certificate URLs
Update these URLs in the HTML files to point to your NXCore server:

```html
<!-- Android APK -->
https://your-nxcore-server.com/certs/android/cert-installer.apk

<!-- Windows EXE -->
https://your-nxcore-server.com/certs/windows/cert-installer.exe

<!-- Certificate Files -->
https://your-nxcore-server.com/certs/universal/AeroVista-RootCA.cer
https://your-nxcore-server.com/certs/universal/User-Gold.p12
```

### GitHub Pages
The certificate installer is automatically deployed to GitHub Pages at:
**[https://aerovista-us.github.io/certs/](https://aerovista-us.github.io/certs/)**

## 📈 Monitoring

### Certificate Installation Success
- 📊 **Download Tracking**: Monitor certificate file downloads
- ✅ **Installation Verification**: Confirm successful installations
- 🔍 **Error Analysis**: Track and resolve installation issues
- 📱 **Device Analytics**: Understand user device patterns

### NXCore System Health
- 🟢 **Service Status**: Real-time service monitoring
- 📊 **Performance Metrics**: System performance tracking
- 🔒 **Security Monitoring**: Certificate and security status
- 📈 **Usage Analytics**: System usage patterns and trends

## 🆘 Support

### Documentation
- 📖 **Installation Guides**: [GitHub Pages Documentation](https://aerovista-us.github.io/certs/)
- 🔧 **Administrator Guide**: [NXCore Documentation](https://nxcore.tail79107c.ts.net/certs/)
- 🆘 **Help Center**: [NXCore Help](https://nxcore.tail79107c.ts.net/help/)

### Troubleshooting
- 🔍 **Common Issues**: Certificate installation problems and solutions
- 🛠️ **Technical Support**: Advanced troubleshooting guides
- 📞 **Contact**: NXCore support team

## 🔒 Security

### Certificate Security
- 🔐 **Secure Generation**: Cryptographically secure certificate generation
- 🛡️ **Password Protection**: Client certificates are password protected
- 🔒 **Secure Storage**: Certificates installed in appropriate system stores
- ✅ **Validation**: Certificate integrity verification

### Web Security
- 🌐 **HTTPS Only**: All connections use HTTPS
- 🛡️ **Security Headers**: Comprehensive security headers
- 🔒 **Content Security Policy**: XSS protection
- 🚫 **No External Dependencies**: All resources from trusted sources

## 📄 License

This project is part of the NXCore system and is intended for internal use only.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Contact

- **NXCore Team**: [NXCore Support](https://nxcore.tail79107c.ts.net/help/)
- **GitHub Issues**: [Report Issues](https://github.com/aerovista-us/certs/issues)
- **Documentation**: [NXCore Documentation](https://nxcore.tail79107c.ts.net/certs/)

---

**🔐 NXCore Certificate Management System - Secure, Automated, Reliable**
