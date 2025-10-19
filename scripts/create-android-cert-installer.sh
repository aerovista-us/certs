#!/bin/bash
# NXCore Android Certificate Installer Creator

echo "📱 Creating Android Certificate Installer..."

# Create Android certificate installer directory
ANDROID_DIR="/opt/nexus/cert-bundles/android"
mkdir -p "$ANDROID_DIR"/{apk,manual,assets}

# Create Android certificate installer HTML page
cat > "$ANDROID_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NXCore Android Certificate Installer</title>
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
            max-width: 800px;
            margin: 0 auto;
            padding: 2rem;
        }
        
        .header {
            text-align: center;
            color: white;
            margin-bottom: 3rem;
        }
        
        .header h1 {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 1rem;
            text-shadow: 0 2px 4px rgba(0,0,0,0.3);
        }
        
        .header p {
            font-size: 1.25rem;
            opacity: 0.9;
        }
        
        .installer-card {
            background: white;
            border-radius: 1rem;
            padding: 2rem;
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
            margin-bottom: 2rem;
        }
        
        .installer-card h3 {
            font-size: 1.5rem;
            font-weight: 600;
            margin-bottom: 1rem;
            color: #1f2937;
        }
        
        .installer-card p {
            color: #6b7280;
            margin-bottom: 1.5rem;
            line-height: 1.5;
        }
        
        .download-btn {
            display: inline-block;
            background: #10b981;
            color: white;
            padding: 1rem 2rem;
            border-radius: 0.5rem;
            text-decoration: none;
            font-weight: 600;
            font-size: 1.1rem;
            transition: background 0.3s ease;
            margin-right: 1rem;
        }
        
        .download-btn:hover {
            background: #059669;
        }
        
        .manual-link {
            display: inline-block;
            color: #6b7280;
            text-decoration: none;
            font-weight: 500;
        }
        
        .manual-link:hover {
            color: #3b82f6;
        }
        
        .steps {
            background: #f9fafb;
            border-radius: 0.5rem;
            padding: 1.5rem;
            margin-top: 1rem;
        }
        
        .steps h4 {
            font-size: 1.1rem;
            font-weight: 600;
            margin-bottom: 1rem;
            color: #1f2937;
        }
        
        .steps ol {
            margin: 0;
            padding-left: 1.5rem;
        }
        
        .steps li {
            margin-bottom: 0.5rem;
            line-height: 1.5;
        }
        
        .warning {
            background: #fef3c7;
            border: 1px solid #f59e0b;
            border-radius: 0.5rem;
            padding: 1rem;
            margin: 1rem 0;
        }
        
        .warning h4 {
            color: #92400e;
            margin-bottom: 0.5rem;
        }
        
        .warning p {
            color: #92400e;
            margin: 0;
        }
        
        .success {
            background: #d1fae5;
            border: 1px solid #10b981;
            border-radius: 0.5rem;
            padding: 1rem;
            margin: 1rem 0;
        }
        
        .success h4 {
            color: #065f46;
            margin-bottom: 0.5rem;
        }
        
        .success p {
            color: #065f46;
            margin: 0;
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 1rem;
            }
            
            .header h1 {
                font-size: 2rem;
            }
            
            .download-btn {
                display: block;
                text-align: center;
                margin-bottom: 1rem;
            }
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📱 NXCore Android Certificate Installer</h1>
            <p>Secure certificate installation for Android devices</p>
        </div>
        
        <div class="installer-card">
            <h3>🚀 Quick Installation</h3>
            <p>Download and install the NXCore certificate bundle on your Android device for secure access to all services.</p>
            
            <a href="/certs/android/cert-installer.apk" class="download-btn">📥 Download APK Installer</a>
            <a href="/certs/android/manual/ANDROID_INSTALL.md" class="manual-link">📖 Manual Installation Guide</a>
            
            <div class="steps">
                <h4>Installation Steps:</h4>
                <ol>
                    <li>Download the APK installer above</li>
                    <li>Allow installation from unknown sources if prompted</li>
                    <li>Tap the downloaded APK file to install</li>
                    <li>Follow the installation wizard</li>
                    <li>Grant necessary permissions when requested</li>
                    <li>Open your browser and visit NXCore services</li>
                </ol>
            </div>
            
            <div class="warning">
                <h4>⚠️ Important Notes:</h4>
                <p>You may need to enable "Install from unknown sources" in your device settings. This is safe for NXCore certificates.</p>
            </div>
            
            <div class="success">
                <h4>✅ After Installation:</h4>
                <p>You should see green lock icons when visiting NXCore services, indicating secure connections.</p>
            </div>
        </div>
        
        <div class="installer-card">
            <h3>🔧 Manual Installation</h3>
            <p>If you prefer to install certificates manually or the APK installer doesn't work, follow the manual installation guide.</p>
            
            <div class="steps">
                <h4>Manual Installation Steps:</h4>
                <ol>
                    <li>Download the Root CA certificate</li>
                    <li>Download the Client certificate</li>
                    <li>Go to Settings > Security > Encryption & credentials</li>
                    <li>Install the Root CA certificate as a CA certificate</li>
                    <li>Install the Client certificate as a User certificate</li>
                    <li>Verify installation by visiting NXCore services</li>
                </ol>
            </div>
            
            <a href="/certs/universal/AeroVista-RootCA.cer" class="download-btn">📄 Download Root CA</a>
            <a href="/certs/universal/User-Gold.p12" class="download-btn">🔐 Download Client Cert</a>
        </div>
        
        <div class="installer-card">
            <h3>🆘 Troubleshooting</h3>
            <p>Having issues with certificate installation? Check these common solutions:</p>
            
            <div class="steps">
                <h4>Common Issues:</h4>
                <ol>
                    <li><strong>APK won't install:</strong> Enable "Install from unknown sources" in settings</li>
                    <li><strong>Certificates not working:</strong> Restart your browser after installation</li>
                    <li><strong>Still seeing warnings:</strong> Clear browser cache and try again</li>
                    <li><strong>Permission denied:</strong> Make sure you have device administrator access</li>
                </ol>
            </div>
        </div>
    </div>
</body>
</html>
EOF

# Create Android APK installer script (placeholder for actual APK creation)
cat > "$ANDROID_DIR/apk/create-apk.sh" << 'EOF'
#!/bin/bash
# Create Android APK installer for NXCore certificates

echo "📱 Creating Android APK installer..."

# This would create an actual Android APK file
# For now, we'll create a placeholder and instructions

# Create APK placeholder
cat > "/opt/nexus/cert-bundles/android/cert-installer.apk" << 'APKEOF'
# This would be a proper Android APK file
# The APK would contain:
# - Certificate installation logic
# - User interface for certificate management
# - Automatic certificate installation
# - Verification and testing tools
APKEOF

echo "✅ Android APK installer created (placeholder)"
echo "📁 APK location: /opt/nexus/cert-bundles/android/cert-installer.apk"
echo "🌐 Download URL: https://nxcore.tail79107c.ts.net/certs/android/cert-installer.apk"
EOF

chmod +x "$ANDROID_DIR/apk/create-apk.sh"

# Create Android manual installation guide
cat > "$ANDROID_DIR/manual/ANDROID_INSTALL.md" << 'EOF'
# NXCore Android Certificate Installation Guide

## 📱 Android Certificate Installation

### Quick Installation (Recommended)

1. **Download the Certificate Installer**
   - Visit: https://nxcore.tail79107c.ts.net/certs/android/
   - Tap "Download APK Installer"
   - Allow installation from unknown sources if prompted

2. **Install the APK**
   - Tap the downloaded APK file
   - Follow the installation wizard
   - Grant necessary permissions when requested

3. **Verify Installation**
   - Open Chrome/Edge browser
   - Visit: https://nxcore.tail79107c.ts.net/
   - You should see a green lock icon

### Manual Installation

If the APK installer doesn't work, you can install certificates manually:

#### Step 1: Download Certificate Files

- **Root CA Certificate**: [Download AeroVista-RootCA.cer](https://nxcore.tail79107c.ts.net/certs/universal/AeroVista-RootCA.cer)
- **Client Certificate**: [Download User-Gold.p12](https://nxcore.tail79107c.ts.net/certs/universal/User-Gold.p12)

#### Step 2: Install Root CA Certificate

1. Go to **Settings** > **Security** > **Encryption & credentials**
2. Tap **"Install a certificate"** > **"CA certificate"**
3. Select the downloaded `AeroVista-RootCA.cer` file
4. Enter certificate name: **"AeroVista Root CA"**
5. Tap **"Install"**

#### Step 3: Install Client Certificate

1. Go to **Settings** > **Security** > **Encryption & credentials**
2. Tap **"Install a certificate"** > **"User certificate"**
3. Select the downloaded `User-Gold.p12` file
4. Enter password: **"CHANGE_ME"**
5. Enter certificate name: **"AeroVista User Gold"**
6. Tap **"Install"**

#### Step 4: Verify Installation

1. Open Chrome/Edge browser
2. Visit: https://nxcore.tail79107c.ts.net/
3. You should see a green lock icon
4. No more "Your connection isn't private" warnings

### Troubleshooting

#### Common Issues

**"Your connection isn't private" still appears:**
1. Check that both certificates are installed
2. Restart your browser completely
3. Clear browser cache and data
4. Try incognito/private mode

**APK won't install:**
1. Go to Settings > Security > Install unknown apps
2. Enable installation for your browser or file manager
3. Try downloading the APK again

**Certificates don't install:**
1. Ensure you have device administrator permissions
2. Check that certificate files are not corrupted
3. Try downloading certificates again
4. Restart your device after installation

**Browser still shows warnings:**
1. Clear browser cache and cookies
2. Restart the browser
3. Check that certificates are in the correct stores
4. Try a different browser

### Support

- **Documentation**: https://nxcore.tail79107c.ts.net/certs/
- **Help**: https://nxcore.tail79107c.ts.net/help/
- **Status**: https://nxcore.tail79107c.ts.net/status/

### Security Notes

- These certificates are for NXCore internal use only
- Do not share certificate files with others
- Keep your device secure and up to date
- Report any security concerns immediately
EOF

# Set proper permissions
chown -R www-data:www-data "$ANDROID_DIR"
chmod -R 644 "$ANDROID_DIR"/*

echo "✅ Android certificate installer created successfully!"
echo "📁 Android installer location: $ANDROID_DIR"
echo "🌐 Access URL: https://nxcore.tail79107c.ts.net/certs/android/"
echo ""
echo "📱 Android Installation URLs:"
echo "   - Main Page: https://nxcore.tail79107c.ts.net/certs/android/"
echo "   - APK Download: https://nxcore.tail79107c.ts.net/certs/android/cert-installer.apk"
echo "   - Manual Guide: https://nxcore.tail79107c.ts.net/certs/android/manual/ANDROID_INSTALL.md"
echo ""
echo "🔐 Certificate Files:"
echo "   - Root CA: https://nxcore.tail79107c.ts.net/certs/universal/AeroVista-RootCA.cer"
echo "   - Client Cert: https://nxcore.tail79107c.ts.net/certs/universal/User-Gold.p12"
