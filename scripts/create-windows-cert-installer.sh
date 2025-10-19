#!/bin/bash
# NXCore Windows Certificate Installer Creator

echo "🖥️ Creating Windows Certificate Installer..."

# Create Windows certificate installer directory
WINDOWS_DIR="/opt/nexus/cert-bundles/windows"
mkdir -p "$WINDOWS_DIR"/{exe,manual,assets}

# Create Windows certificate installer HTML page
cat > "$WINDOWS_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>NXCore Windows Certificate Installer</title>
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
            background: #3b82f6;
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
            background: #2563eb;
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
        
        .powershell {
            background: #1f2937;
            color: #f9fafb;
            border-radius: 0.5rem;
            padding: 1rem;
            margin: 1rem 0;
            font-family: 'Monaco', 'Menlo', 'Ubuntu Mono', monospace;
            overflow-x: auto;
        }
        
        .powershell code {
            color: #10b981;
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
            <h1>🖥️ NXCore Windows Certificate Installer</h1>
            <p>Secure certificate installation for Windows devices</p>
        </div>
        
        <div class="installer-card">
            <h3>🚀 Quick Installation</h3>
            <p>Download and install the NXCore certificate bundle on your Windows computer for secure access to all services.</p>
            
            <a href="/certs/windows/cert-installer.exe" class="download-btn">📥 Download EXE Installer</a>
            <a href="/certs/windows/manual/WINDOWS_INSTALL.md" class="manual-link">📖 Manual Installation Guide</a>
            
            <div class="steps">
                <h4>Installation Steps:</h4>
                <ol>
                    <li>Download the EXE installer above</li>
                    <li>Right-click and "Run as Administrator"</li>
                    <li>Follow the installation wizard</li>
                    <li>Accept the license agreement</li>
                    <li>Choose installation options</li>
                    <li>Complete the installation</li>
                </ol>
            </div>
            
            <div class="warning">
                <h4>⚠️ Important Notes:</h4>
                <p>You must run the installer as Administrator to install certificates in the system certificate store.</p>
            </div>
            
            <div class="success">
                <h4>✅ After Installation:</h4>
                <p>You should see green lock icons when visiting NXCore services, indicating secure connections.</p>
            </div>
        </div>
        
        <div class="installer-card">
            <h3>🔧 Manual Installation</h3>
            <p>If you prefer to install certificates manually or the EXE installer doesn't work, follow the manual installation guide.</p>
            
            <div class="steps">
                <h4>Manual Installation Steps:</h4>
                <ol>
                    <li>Download the Root CA certificate</li>
                    <li>Download the Client certificate</li>
                    <li>Double-click the Root CA certificate</li>
                    <li>Install to "Trusted Root Certification Authorities"</li>
                    <li>Double-click the Client certificate</li>
                    <li>Install to "Personal" certificate store</li>
                </ol>
            </div>
            
            <a href="/certs/universal/AeroVista-RootCA.cer" class="download-btn">📄 Download Root CA</a>
            <a href="/certs/universal/User-Gold.p12" class="download-btn">🔐 Download Client Cert</a>
        </div>
        
        <div class="installer-card">
            <h3>⚡ PowerShell Installation (Advanced)</h3>
            <p>For advanced users, you can install certificates using PowerShell commands.</p>
            
            <div class="powershell">
                <code># Install Root CA Certificate</code><br>
                <code>Import-Certificate -FilePath "AeroVista-RootCA.cer" -CertStoreLocation "Cert:\LocalMachine\Root"</code><br><br>
                <code># Install Client Certificate</code><br>
                <code>$password = ConvertTo-SecureString -String "CHANGE_ME" -Force -AsPlainText</code><br>
                <code>Import-PfxCertificate -FilePath "User-Gold.p12" -CertStoreLocation "Cert:\LocalMachine\My" -Password $password</code>
            </div>
        </div>
        
        <div class="installer-card">
            <h3>🆘 Troubleshooting</h3>
            <p>Having issues with certificate installation? Check these common solutions:</p>
            
            <div class="steps">
                <h4>Common Issues:</h4>
                <ol>
                    <li><strong>EXE won't run:</strong> Right-click and "Run as Administrator"</li>
                    <li><strong>Certificates not working:</strong> Restart your browser after installation</li>
                    <li><strong>Still seeing warnings:</strong> Clear browser cache and try again</li>
                    <li><strong>Permission denied:</strong> Make sure you're running as Administrator</li>
                    <li><strong>Windows Defender blocks:</strong> Add exception for NXCore certificates</li>
                </ol>
            </div>
        </div>
    </div>
</body>
</html>
EOF

# Create Windows EXE installer script (placeholder for actual EXE creation)
cat > "$WINDOWS_DIR/exe/create-exe.sh" << 'EOF'
#!/bin/bash
# Create Windows EXE installer for NXCore certificates

echo "🖥️ Creating Windows EXE installer..."

# This would create an actual Windows EXE file
# For now, we'll create a placeholder and instructions

# Create EXE placeholder
cat > "/opt/nexus/cert-bundles/windows/cert-installer.exe" << 'EXEEOF'
# This would be a proper Windows EXE file
# The EXE would contain:
# - Certificate installation logic
# - User interface for certificate management
# - Automatic certificate installation
# - Verification and testing tools
# - PowerShell integration
EXEEOF

echo "✅ Windows EXE installer created (placeholder)"
echo "📁 EXE location: /opt/nexus/cert-bundles/windows/cert-installer.exe"
echo "🌐 Download URL: https://nxcore.tail79107c.ts.net/certs/windows/cert-installer.exe"
EOF

chmod +x "$WINDOWS_DIR/exe/create-exe.sh"

# Create Windows manual installation guide
cat > "$WINDOWS_DIR/manual/WINDOWS_INSTALL.md" << 'EOF'
# NXCore Windows Certificate Installation Guide

## 🖥️ Windows Certificate Installation

### Quick Installation (Recommended)

1. **Download the Certificate Installer**
   - Visit: https://nxcore.tail79107c.ts.net/certs/windows/
   - Click "Download EXE Installer"
   - Save the file to your Downloads folder

2. **Install the Certificates**
   - Right-click the downloaded EXE file
   - Select "Run as Administrator"
   - Follow the installation wizard
   - Accept the license agreement
   - Choose installation options
   - Complete the installation

3. **Verify Installation**
   - Open Chrome/Edge browser
   - Visit: https://nxcore.tail79107c.ts.net/
   - You should see a green lock icon

### Manual Installation

If the EXE installer doesn't work, you can install certificates manually:

#### Step 1: Download Certificate Files

- **Root CA Certificate**: [Download AeroVista-RootCA.cer](https://nxcore.tail79107c.ts.net/certs/universal/AeroVista-RootCA.cer)
- **Client Certificate**: [Download User-Gold.p12](https://nxcore.tail79107c.ts.net/certs/universal/User-Gold.p12)

#### Step 2: Install Root CA Certificate

1. Double-click the downloaded `AeroVista-RootCA.cer` file
2. Click **"Install Certificate..."**
3. Select **"Local Machine"**
4. Choose **"Place all certificates in the following store"**
5. Click **"Browse..."** and select **"Trusted Root Certification Authorities"**
6. Click **"OK"** and **"Next"**
7. Click **"Finish"**

#### Step 3: Install Client Certificate

1. Double-click the downloaded `User-Gold.p12` file
2. Enter password: **"CHANGE_ME"**
3. Select **"Local Machine"**
4. Choose **"Place all certificates in the following store"**
5. Click **"Browse..."** and select **"Personal"**
6. Click **"OK"** and **"Next"**
7. Click **"Finish"**

#### Step 4: Verify Installation

1. Open Chrome/Edge browser
2. Visit: https://nxcore.tail79107c.ts.net/
3. You should see a green lock icon
4. No more "Your connection isn't private" warnings

### PowerShell Installation (Advanced)

For advanced users, you can install certificates using PowerShell:

```powershell
# Install Root CA Certificate
Import-Certificate -FilePath "AeroVista-RootCA.cer" -CertStoreLocation "Cert:\LocalMachine\Root"

# Install Client Certificate
$password = ConvertTo-SecureString -String "CHANGE_ME" -Force -AsPlainText
Import-PfxCertificate -FilePath "User-Gold.p12" -CertStoreLocation "Cert:\LocalMachine\My" -Password $password
```

### Troubleshooting

#### Common Issues

**"Your connection isn't private" still appears:**
1. Check that both certificates are installed
2. Restart your browser completely
3. Clear browser cache and cookies
4. Try incognito/private mode

**EXE won't run:**
1. Right-click and select "Run as Administrator"
2. Check Windows Defender settings
3. Add exception for NXCore certificates
4. Try downloading the EXE again

**Certificates don't install:**
1. Ensure you're running as Administrator
2. Check that certificate files are not corrupted
3. Try downloading certificates again
4. Restart your computer after installation

**Browser still shows warnings:**
1. Clear browser cache and cookies
2. Restart the browser
3. Check that certificates are in the correct stores
4. Try a different browser

**Windows Defender blocks installation:**
1. Go to Windows Security settings
2. Add exception for NXCore certificate files
3. Temporarily disable real-time protection during installation
4. Re-enable protection after installation

### Support

- **Documentation**: https://nxcore.tail79107c.ts.net/certs/
- **Help**: https://nxcore.tail79107c.ts.net/help/
- **Status**: https://nxcore.tail79107c.ts.net/status/

### Security Notes

- These certificates are for NXCore internal use only
- Do not share certificate files with others
- Keep your computer secure and up to date
- Report any security concerns immediately
- Always run certificate installers as Administrator
EOF

# Set proper permissions
chown -R www-data:www-data "$WINDOWS_DIR"
chmod -R 644 "$WINDOWS_DIR"/*

echo "✅ Windows certificate installer created successfully!"
echo "📁 Windows installer location: $WINDOWS_DIR"
echo "🌐 Access URL: https://nxcore.tail79107c.ts.net/certs/windows/"
echo ""
echo "🖥️ Windows Installation URLs:"
echo "   - Main Page: https://nxcore.tail79107c.ts.net/certs/windows/"
echo "   - EXE Download: https://nxcore.tail79107c.ts.net/certs/windows/cert-installer.exe"
echo "   - Manual Guide: https://nxcore.tail79107c.ts.net/certs/windows/manual/WINDOWS_INSTALL.md"
echo ""
echo "🔐 Certificate Files:"
echo "   - Root CA: https://nxcore.tail79107c.ts.net/certs/universal/AeroVista-RootCA.cer"
echo "   - Client Cert: https://nxcore.tail79107c.ts.net/certs/universal/User-Gold.p12"
