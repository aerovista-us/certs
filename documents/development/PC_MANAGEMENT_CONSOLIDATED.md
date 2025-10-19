# NXCore Infrastructure - PC Management (Consolidated)

## 🎯 **PC Management Overview**

**Target**: 10 high-trust stakeholder PCs  
**Platform**: Dell OptiPlex 3050 SFF (Windows 11 Pro)  
**Purpose**: High-trust internal use only  
**Management**: Automated imaging, security, and system management

---

## 🖥️ **Hardware Specifications**

### **Dell OptiPlex 3050 SFF**
- **Marketing Model**: OptiPlex 3050 SFF (Small Form Factor)
- **Regulatory Model**: D11S
- **Regulatory Type**: D11S002
- **Input Rating**: 100–240 V~, 3.0 A, 50/60 Hz
- **Country of Manufacture**: China
- **PSU Wattage**: ~180W
- **Dell P/N**: XJOPV A00

### **Recommended Configuration**
- **CPU**: Intel Core i5-7500 or better
- **RAM**: 16GB DDR4 (minimum 8GB)
- **Storage**: 512GB NVMe SSD (primary), 1TB HDD (optional)
- **Graphics**: Intel HD Graphics 630 (Quick Sync enabled)
- **Network**: Gigabit Ethernet + Wi-Fi 802.11ac

---

## 🚀 **PC Imaging Process**

### **Phase 1: Hardware Preparation**

#### **BIOS/Firmware Updates**
```bash
# Use Dell Command | Update
# Update BIOS to latest version
# Enable virtualization (VT-x/AMD-V)
# Disable Fast Boot
# Enable TPM 2.0
# Set High Performance power profile
```

#### **Hardware Verification**
```bash
# Check system specifications
wmic computersystem get model,manufacturer
wmic memorychip get capacity,speed
wmic diskdrive get size,model
wmic cpu get name,numberofcores
```

### **Phase 2: Windows 11 Pro Installation**

#### **Installation Process**
1. **Boot from Windows 11 Pro ISO**
2. **Skip Microsoft Account** using `Shift+F10` → `OOBE\BYPASSNRO`
3. **Create local admin**: `av-admin` with strong password
4. **Set PC name**: `AV-COLLAB-<name>`
5. **Complete Windows Update** until clear

#### **Post-Installation Configuration**
```powershell
# Set timezone
Set-TimeZone -Id "Pacific Standard Time"

# Configure power settings
powercfg -setactive SCHEME_MIN
powercfg -h off

# Show file extensions
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' HideFileExt 0

# Disable hibernation
powercfg -h off
```

---

## 🔐 **Security Configuration**

### **BitLocker Encryption**
```powershell
# Enable BitLocker on system drive
Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes256 -UsedSpaceOnly

# Save recovery key to secure location
$RecoveryKey = (Get-BitLockerVolume -MountPoint "C:").KeyProtector | Where-Object {$_.KeyProtectorType -eq "RecoveryPassword"}
$RecoveryKey.RecoveryPassword
```

### **Windows Defender Configuration**
```powershell
# Enable Windows Defender
Set-MpPreference -DisableRealtimeMonitoring $false
Set-MpPreference -DisableBehaviorMonitoring $false
Set-MpPreference -DisableOnAccessProtection $false

# Add exclusions for large media caches
Add-MpPreference -ExclusionPath "D:\MediaCache\"
Add-MpPreference -ExclusionPath "C:\AeroVista\logs\"
```

### **Firewall Configuration**
```powershell
# Enable Windows Firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled True

# Allow required applications
New-NetFirewallRule -DisplayName "Tailscale" -Direction Inbound -Protocol TCP -LocalPort 41641 -Action Allow
New-NetFirewallRule -DisplayName "RustDesk" -Direction Inbound -Protocol TCP -LocalPort 21115,21116,21118 -Action Allow
```

---

## 🌐 **Network Configuration**

### **Tailscale Setup**
```powershell
# Install Tailscale
winget install Tailscale.Tailscale

# Join tailnet
tailscale up --ssh --hostname av-collab-<name>

# Verify connection
tailscale status
```

### **NXCore Certificate Installation**
```powershell
# Download certificate from NXCore server
scp glyph@100.115.9.61:/opt/nexus/traefik/certs/self-signed.crt ./

# Install certificate
Import-Certificate -FilePath "self-signed.crt" -CertStoreLocation "Cert:\LocalMachine\Root"

# Verify installation
Get-ChildItem -Path "Cert:\LocalMachine\Root" | Where-Object { $_.Subject -like "*nxcore*" }
```

---

## 🛠️ **Software Installation**

### **Core Applications**
```powershell
# Install essential software via winget
winget install Microsoft.VisualStudioCode
winget install Git.Git
winget install 7zip.7zip
winget install VideoLAN.VLC
winget install Node.js.NodeJS
winget install Docker.DockerDesktop
```

### **AeroVista Applications**
```powershell
# Create AeroVista directory structure
New-Item -ItemType Directory -Path "C:\AeroVista\apps" -Force
New-Item -ItemType Directory -Path "C:\AeroVista\logs" -Force
New-Item -ItemType Directory -Path "C:\AeroVista\shortcuts" -Force

# Install AeroVista applications
# Copy from deployment package
Copy-Item "aerocoreos-staff-call-branded.zip" "C:\AeroVista\apps\"
Copy-Item "av-rustdesk-desktop-pack.zip" "C:\AeroVista\apps\"
```

### **Development Tools**
```powershell
# Install Node.js LTS
winget install Node.js.NodeJS

# Install Git with credential manager
winget install Git.Git
winget install Microsoft.GitCredentialManager

# Install VS Code with extensions
winget install Microsoft.VisualStudioCode
code --install-extension ms-vscode.vscode-json
code --install-extension bradlc.vscode-tailwindcss
code --install-extension esbenp.prettier-vscode
```

---

## 🎨 **User Interface Configuration**

### **Desktop Customization**
```powershell
# Show file extensions
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' HideFileExt 0

# Show hidden files
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' Hidden 1

# Configure taskbar
Set-ItemProperty 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' TaskbarGlomLevel 0
```

### **Browser Configuration**
```powershell
# Configure Edge for AeroVista
# Install PWAs for AeroVista services
# Set microphone permissions for tailnet URLs
# Configure auto-update
```

---

## 📱 **PWA Installation**

### **AeroVista PWAs**
1. **AeroCoreOS Dashboard**: `https://nxcore.tail79107c.ts.net/`
2. **Daily Brief Builder**: `https://nxcore.tail79107c.ts.net/brief/`
3. **AdminCenter**: `https://nxcore.tail79107c.ts.net/admin/`
4. **File Gateway**: `https://nxcore.tail79107c.ts.net/files/`
5. **AI Assistant**: `https://nxcore.tail79107c.ts.net/ai/`

### **PWA Installation Process**
```javascript
// Install PWAs via browser
// Navigate to each URL
// Click "Install" button
// Pin to Start Menu and Taskbar
```

---

## 🔧 **System Optimization**

### **Performance Tuning**
```powershell
# Set high performance power plan
powercfg -setactive SCHEME_MIN

# Disable unnecessary services
Get-Service | Where-Object {$_.StartType -eq "Automatic" -and $_.Status -eq "Stopped"} | Stop-Service
Get-Service | Where-Object {$_.StartType -eq "Automatic" -and $_.Status -eq "Stopped"} | Set-Service -StartupType Disabled

# Optimize for Quick Sync
# Enable hardware acceleration in applications
```

### **Storage Optimization**
```powershell
# Enable TRIM for SSD
fsutil behavior set DisableDeleteNotify 0

# Configure storage spaces
# Set up automatic cleanup
# Configure backup to network storage
```

---

## 🚀 **AeroCaller Setup**

### **Staff Call Configuration**
```powershell
# Extract AeroCaller bundle
Expand-Archive "C:\AeroVista\apps\aerocoreos-staff-call-branded.zip" -DestinationPath "C:\AeroVista\apps\staff-call\"

# Install dependencies
cd "C:\AeroVista\apps\staff-call\"
npm install

# Configure auto-start
Copy-Item "Start-AeroCoreOS-StaffCall.bat" "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\"
```

### **WebRTC Configuration**
```javascript
// Configure PeerJS for WebRTC
// Set up TURN server (if needed)
// Configure audio/video permissions
// Test connectivity
```

---

## 🔍 **Quality Assurance**

### **System Verification**
```powershell
# Check system specifications
Get-ComputerInfo | Select-Object TotalPhysicalMemory,NumberOfProcessors,WindowsProductName

# Verify network connectivity
Test-NetConnection -ComputerName "nxcore.tail79107c.ts.net" -Port 443

# Check certificate installation
Get-ChildItem -Path "Cert:\LocalMachine\Root" | Where-Object { $_.Subject -like "*nxcore*" }

# Verify Tailscale connection
tailscale status
```

### **Application Testing**
```powershell
# Test AeroVista applications
# Verify PWA functionality
# Test WebRTC calling
# Verify file access
# Test AI assistant
```

---

## 📊 **Performance Monitoring**

### **System Metrics**
```powershell
# Monitor system performance
Get-Counter "\Processor(_Total)\% Processor Time"
Get-Counter "\Memory\Available MBytes"
Get-Counter "\PhysicalDisk(_Total)\% Disk Time"

# Check network performance
Test-NetConnection -ComputerName "nxcore.tail79107c.ts.net" -Port 443 -InformationLevel Detailed
```

### **Application Monitoring**
```powershell
# Monitor application performance
Get-Process | Where-Object {$_.ProcessName -like "*AeroVista*"}
Get-Process | Where-Object {$_.ProcessName -like "*Tailscale*"}
Get-Process | Where-Object {$_.ProcessName -like "*RustDesk*"}
```

---

## 🔄 **Maintenance Procedures**

### **Daily Maintenance**
```powershell
# Check system health
Get-EventLog -LogName System -After (Get-Date).AddDays(-1) | Where-Object {$_.EntryType -eq "Error"}

# Update applications
winget upgrade --all

# Check network connectivity
Test-NetConnection -ComputerName "nxcore.tail79107c.ts.net" -Port 443
```

### **Weekly Maintenance**
```powershell
# Clean temporary files
Get-ChildItem -Path $env:TEMP -Recurse | Remove-Item -Force -Recurse

# Update Windows
Get-WindowsUpdate -AcceptAll -Install

# Check disk health
Get-PhysicalDisk | Get-StorageReliabilityCounter
```

### **Monthly Maintenance**
```powershell
# Full system backup
# Update all applications
# Security scan
# Performance optimization
```

---

## 📚 **Documentation**

### **User Guides**
- **Quick Start Guide**: Basic operations
- **Troubleshooting Guide**: Common issues
- **Security Guide**: Best practices
- **Maintenance Guide**: System upkeep

### **Technical Documentation**
- **Hardware Specifications**: Dell OptiPlex 3050 SFF
- **Software Requirements**: Windows 11 Pro, applications
- **Network Configuration**: Tailscale, certificates
- **Security Configuration**: BitLocker, Defender, Firewall

---

## 🎯 **Success Criteria**

### **Deployment Success**
✅ **Hardware Verified**: All specifications met  
✅ **Windows 11 Pro Installed**: Latest version with updates  
✅ **Security Configured**: BitLocker, Defender, Firewall  
✅ **Network Connected**: Tailscale and NXCore access  
✅ **Applications Installed**: All AeroVista applications  
✅ **PWAs Configured**: All web applications accessible  
✅ **Performance Optimized**: System running at peak performance  

### **User Acceptance**
✅ **Training Complete**: Users trained on all systems  
✅ **Documentation Provided**: All guides and references  
✅ **Support Available**: Technical support accessible  
✅ **Performance Verified**: All systems working optimally  

---

## 📞 **Support & Maintenance**

### **Level 1 Support**
- **Self-Service**: Documentation and guides
- **Common Issues**: Standard troubleshooting
- **Basic Configuration**: User-level changes

### **Level 2 Support**
- **Technical Issues**: Advanced troubleshooting
- **System Configuration**: Administrative changes
- **Performance Issues**: Optimization and tuning

### **Level 3 Support**
- **Critical Issues**: System failures
- **Security Issues**: Breach response
- **Hardware Issues**: Physical repairs

---

**This PC management guide provides comprehensive procedures for deploying and maintaining high-trust stakeholder PCs within the NXCore infrastructure ecosystem.**
