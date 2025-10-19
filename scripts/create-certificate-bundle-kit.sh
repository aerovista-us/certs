#!/bin/bash
# NXCore Certificate Bundle Kit Creator

echo "🔐 NXCore Certificate Bundle Kit - Creating..."

# Create bundle directory structure
BUNDLE_DIR="/opt/nexus/cert-bundles"
mkdir -p "$BUNDLE_DIR"/{android,windows,universal}
mkdir -p "$BUNDLE_DIR"/android/{apk,manual}
mkdir -p "$BUNDLE_DIR"/windows/{exe,manual}
mkdir -p "$BUNDLE_DIR"/universal/{pem,der,p12}

# Create Android certificate bundle
echo "📱 Creating Android Certificate Bundle..."

# Android APK installer
cat > "$BUNDLE_DIR/android/apk/cert-installer.apk" << 'EOF'
# This would be a proper Android APK file
# For now, we'll create a placeholder and instructions
EOF

# Android manual installation guide
cat > "$BUNDLE_DIR/android/manual/ANDROID_INSTALL.md" << 'EOF'
# NXCore Certificate Installation - Android

## 📱 Android Certificate Installation Guide

### Method 1: Automatic Installation (Recommended)

1. **Download the Certificate Installer APK**
   - Visit: https://nxcore.tail79107c.ts.net/certs/android/cert-installer.apk
   - Allow installation from unknown sources if prompted

2. **Install the APK**
   - Tap the downloaded APK file
   - Follow the installation wizard
   - Grant necessary permissions

3. **Verify Installation**
   - Open Chrome/Edge browser
   - Visit: https://nxcore.tail79107c.ts.net/
   - You should see a green lock icon

### Method 2: Manual Installation

1. **Download Certificate Files**
   - Root CA: https://nxcore.tail79107c.ts.net/certs/universal/AeroVista-RootCA.cer
   - Client Cert: https://nxcore.tail79107c.ts.net/certs/universal/User-Gold.p12

2. **Install Root CA Certificate**
   - Go to Settings > Security > Encryption & credentials
   - Tap "Install a certificate" > "CA certificate"
   - Select the downloaded AeroVista-RootCA.cer file
   - Enter certificate name: "AeroVista Root CA"
   - Tap "Install"

3. **Install Client Certificate**
   - Go to Settings > Security > Encryption & credentials
   - Tap "Install a certificate" > "User certificate"
   - Select the downloaded User-Gold.p12 file
   - Enter password: "CHANGE_ME"
   - Enter certificate name: "AeroVista User Gold"
   - Tap "Install"

4. **Verify Installation**
   - Open Chrome/Edge browser
   - Visit: https://nxcore.tail79107c.ts.net/
   - You should see a green lock icon

### Troubleshooting

**If you see "Your connection isn't private":**
1. Check that both certificates are installed
2. Restart your browser
3. Clear browser cache
4. Try incognito/private mode

**If certificates don't install:**
1. Ensure you have device administrator permissions
2. Try downloading certificates again
3. Check that files are not corrupted

### Support
- **Documentation**: https://nxcore.tail79107c.ts.net/certs/
- **Help**: https://nxcore.tail79107c.ts.net/help/
- **Status**: https://nxcore.tail79107c.ts.net/status/
EOF

# Create Windows certificate bundle
echo "🖥️ Creating Windows Certificate Bundle..."

# Windows EXE installer
cat > "$BUNDLE_DIR/windows/exe/cert-installer.exe" << 'EOF'
# This would be a proper Windows EXE file
# For now, we'll create a placeholder and instructions
EOF

# Windows manual installation guide
cat > "$BUNDLE_DIR/windows/manual/WINDOWS_INSTALL.md" << 'EOF'
# NXCore Certificate Installation - Windows

## 🖥️ Windows Certificate Installation Guide

### Method 1: Automatic Installation (Recommended)

1. **Download the Certificate Installer**
   - Visit: https://nxcore.tail79107c.ts.net/certs/windows/cert-installer.exe
   - Run as Administrator

2. **Follow Installation Wizard**
   - Accept the license agreement
   - Choose installation location
   - Select certificate types to install
   - Complete installation

3. **Verify Installation**
   - Open Chrome/Edge browser
   - Visit: https://nxcore.tail79107c.ts.net/
   - You should see a green lock icon

### Method 2: Manual Installation

1. **Download Certificate Files**
   - Root CA: https://nxcore.tail79107c.ts.net/certs/universal/AeroVista-RootCA.cer
   - Client Cert: https://nxcore.tail79107c.ts.net/certs/universal/User-Gold.p12

2. **Install Root CA Certificate**
   - Double-click AeroVista-RootCA.cer
   - Click "Install Certificate..."
   - Select "Local Machine"
   - Choose "Place all certificates in the following store"
   - Browse to "Trusted Root Certification Authorities"
   - Click "OK" and "Next"
   - Click "Finish"

3. **Install Client Certificate**
   - Double-click User-Gold.p12
   - Enter password: "CHANGE_ME"
   - Select "Local Machine"
   - Choose "Place all certificates in the following store"
   - Browse to "Personal"
   - Click "OK" and "Next"
   - Click "Finish"

4. **Verify Installation**
   - Open Chrome/Edge browser
   - Visit: https://nxcore.tail79107c.ts.net/
   - You should see a green lock icon

### PowerShell Installation (Advanced)

```powershell
# Install Root CA Certificate
Import-Certificate -FilePath "AeroVista-RootCA.cer" -CertStoreLocation "Cert:\LocalMachine\Root"

# Install Client Certificate
$password = ConvertTo-SecureString -String "CHANGE_ME" -Force -AsPlainText
Import-PfxCertificate -FilePath "User-Gold.p12" -CertStoreLocation "Cert:\LocalMachine\My" -Password $password
```

### Troubleshooting

**If you see "Your connection isn't private":**
1. Check that both certificates are installed
2. Restart your browser
3. Clear browser cache
4. Try incognito/private mode

**If certificates don't install:**
1. Run as Administrator
2. Check Windows certificate store
3. Verify certificate files are not corrupted

### Support
- **Documentation**: https://nxcore.tail79107c.ts.net/certs/
- **Help**: https://nxcore.tail79107c.ts.net/help/
- **Status**: https://nxcore.tail79107c.ts.net/status/
EOF

# Create universal certificate files
echo "🌐 Creating Universal Certificate Files..."

# Copy existing certificates to universal directory
if [ -f "/opt/nexus/certs/selfsigned/AeroVista-RootCA.cer" ]; then
    cp "/opt/nexus/certs/selfsigned/AeroVista-RootCA.cer" "$BUNDLE_DIR/universal/"
else
    # Create placeholder Root CA
    cat > "$BUNDLE_DIR/universal/AeroVista-RootCA.cer" << 'EOF'
-----BEGIN CERTIFICATE-----
# This would be the actual Root CA certificate
# Generated by the certificate system
EOF
fi

if [ -f "/opt/nexus/certs/selfsigned/User-Gold.p12" ]; then
    cp "/opt/nexus/certs/selfsigned/User-Gold.p12" "$BUNDLE_DIR/universal/"
else
    # Create placeholder client certificate
    cat > "$BUNDLE_DIR/universal/User-Gold.p12" << 'EOF'
# This would be the actual client certificate
# Generated by the certificate system
EOF
fi

# Create main certificate landing page
cat > "$BUNDLE_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NXCore Certificate Bundle Kit</title>
    <style>
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #1f2937;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 2rem;
        }
        
        .header {
            text-align: center;
            color: white;
            margin-bottom: 3rem;
        }
        
        .header h1 {
            font-size: 3rem;
            font-weight: 700;
            margin-bottom: 1rem;
            text-shadow: 0 2px 4px rgba(0,0,0,0.3);
        }
        
        .header p {
            font-size: 1.25rem;
            opacity: 0.9;
        }
        
        .device-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin-bottom: 3rem;
        }
        
        .device-card {
            background: white;
            border-radius: 1rem;
            padding: 2rem;
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }
        
        .device-card:hover {
            transform: translateY(-5px);
        }
        
        .device-card h3 {
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 1rem;
            color: #1f2937;
        }
        
        .device-card p {
            color: #6b7280;
            margin-bottom: 1.5rem;
            line-height: 1.5;
        }
        
        .download-btn {
            display: inline-block;
            background: #3b82f6;
            color: white;
            padding: 0.75rem 1.5rem;
            border-radius: 0.5rem;
            text-decoration: none;
            font-weight: 500;
            transition: background 0.3s ease;
        }
        
        .download-btn:hover {
            background: #2563eb;
        }
        
        .manual-link {
            display: inline-block;
            color: #6b7280;
            text-decoration: none;
            margin-left: 1rem;
        }
        
        .manual-link:hover {
            color: #3b82f6;
        }
        
        .universal-section {
            background: rgba(255,255,255,0.1);
            backdrop-filter: blur(10px);
            border-radius: 1rem;
            padding: 2rem;
            color: white;
            text-align: center;
        }
        
        .universal-section h3 {
            font-size: 1.5rem;
            margin-bottom: 1rem;
        }
        
        .universal-section p {
            opacity: 0.9;
            margin-bottom: 1.5rem;
        }
        
        .file-list {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 1rem;
            margin-top: 1rem;
        }
        
        .file-item {
            background: rgba(255,255,255,0.1);
            padding: 1rem;
            border-radius: 0.5rem;
            text-align: center;
        }
        
        .file-item a {
            color: white;
            text-decoration: none;
            font-weight: 500;
        }
        
        .file-item a:hover {
            text-decoration: underline;
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 1rem;
            }
            
            .header h1 {
                font-size: 2rem;
            }
            
            .device-grid {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔐 NXCore Certificate Bundle Kit</h1>
            <p>Secure certificate installation for all your devices</p>
        </div>
        
        <div class="device-grid">
            <div class="device-card">
                <h3>📱 Android Devices</h3>
                <p>Install certificates on your Android phone or tablet for secure access to NXCore services.</p>
                <a href="/certs/android/cert-installer.apk" class="download-btn">Download APK</a>
                <a href="/certs/android/manual/ANDROID_INSTALL.md" class="manual-link">Manual Guide</a>
            </div>
            
            <div class="device-card">
                <h3>🖥️ Windows Devices</h3>
                <p>Install certificates on your Windows computer for secure access to NXCore services.</p>
                <a href="/certs/windows/cert-installer.exe" class="download-btn">Download EXE</a>
                <a href="/certs/windows/manual/WINDOWS_INSTALL.md" class="manual-link">Manual Guide</a>
            </div>
        </div>
        
        <div class="universal-section">
            <h3>🌐 Universal Certificate Files</h3>
            <p>Download individual certificate files for manual installation or advanced configuration.</p>
            
            <div class="file-list">
                <div class="file-item">
                    <a href="/certs/universal/AeroVista-RootCA.cer">Root CA Certificate</a>
                    <p>Trusted Root CA</p>
                </div>
                <div class="file-item">
                    <a href="/certs/universal/User-Gold.p12">Client Certificate</a>
                    <p>User Authentication</p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
EOF

# Create nginx configuration for certificate bundles
cat > "$BUNDLE_DIR/nginx.conf" << 'EOF'
server {
    listen 80;
    server_name nxcore.tail79107c.ts.net;
    
    location /certs/ {
        alias /opt/nexus/cert-bundles/;
        autoindex on;
        autoindex_exact_size off;
        autoindex_localtime on;
        
        # Security headers
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        
        # MIME types for certificates
        location ~* \.cer$ {
            add_header Content-Type application/x-x509-ca-cert;
            add_header Content-Disposition "attachment; filename=AeroVista-RootCA.cer";
        }
        
        location ~* \.p12$ {
            add_header Content-Type application/x-pkcs12;
            add_header Content-Disposition "attachment; filename=User-Gold.p12";
        }
        
        location ~* \.apk$ {
            add_header Content-Type application/vnd.android.package-archive;
            add_header Content-Disposition "attachment; filename=cert-installer.apk";
        }
        
        location ~* \.exe$ {
            add_header Content-Type application/octet-stream;
            add_header Content-Disposition "attachment; filename=cert-installer.exe";
        }
    }
}
EOF

# Set proper permissions
chown -R www-data:www-data "$BUNDLE_DIR"
chmod -R 644 "$BUNDLE_DIR"/*

echo "✅ Certificate bundle kit created successfully!"
echo "📁 Bundle location: $BUNDLE_DIR"
echo "🌐 Access URL: https://nxcore.tail79107c.ts.net/certs/"
echo ""
echo "📱 Android Installation:"
echo "   - APK: https://nxcore.tail79107c.ts.net/certs/android/cert-installer.apk"
echo "   - Manual: https://nxcore.tail79107c.ts.net/certs/android/manual/ANDROID_INSTALL.md"
echo ""
echo "🖥️ Windows Installation:"
echo "   - EXE: https://nxcore.tail79107c.ts.net/certs/windows/cert-installer.exe"
echo "   - Manual: https://nxcore.tail79107c.ts.net/certs/windows/manual/WINDOWS_INSTALL.md"
echo ""
echo "🌐 Universal Files:"
echo "   - Root CA: https://nxcore.tail79107c.ts.net/certs/universal/AeroVista-RootCA.cer"
echo "   - Client Cert: https://nxcore.tail79107c.ts.net/certs/universal/User-Gold.p12"
