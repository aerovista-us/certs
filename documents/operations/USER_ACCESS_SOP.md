# NXCore Infrastructure - User Access SOP

## 🎯 **User Access Overview**

**Purpose**: Standard Operating Procedures for user access management  
**Audience**: System administrators and user support staff  
**Scope**: User onboarding, access control, and support procedures  
**Last Updated**: October 18, 2025

---

## 👥 **User Types and Access Levels**

### **Stakeholder Users (High Trust)**
- **Access Level**: Full system access
- **Services**: All NXCore services
- **Authentication**: Authelia SSO/MFA
- **Devices**: 10 high-trust stakeholder PCs
- **Purpose**: Internal business operations

### **Administrative Users**
- **Access Level**: System administration
- **Services**: Portainer, Traefik Dashboard, Grafana Admin
- **Authentication**: Authelia SSO/MFA + additional privileges
- **Devices**: Administrative workstations
- **Purpose**: System management and maintenance

### **Support Users**
- **Access Level**: Limited system access
- **Services**: Monitoring dashboards, basic services
- **Authentication**: Authelia SSO/MFA
- **Devices**: Support workstations
- **Purpose**: System monitoring and support

---

## 🚀 **User Onboarding Procedures**

### **Step 1: Account Creation**

#### **For Stakeholder Users**
```bash
# Access Authelia configuration
ssh glyph@100.115.9.61 "sudo docker exec authelia cat /config/users_database.yml"

# Add new user to Authelia
# Edit /opt/nexus/authelia/users_database.yml
# Add user entry with appropriate groups and permissions
```

#### **For Administrative Users**
```bash
# Create admin user with elevated privileges
# Add to admin group in Authelia
# Configure additional access permissions
```

### **Step 2: PC Setup and Configuration**

#### **Stakeholder PC Setup**
```bash
# Follow PC_MANAGEMENT_CONSOLIDATED.md procedures
# Install Windows 11 Pro with security configuration
# Install Tailscale and join network
# Install NXCore certificate
# Configure AeroVista applications
```

#### **Certificate Installation**
```powershell
# Download certificate from NXCore
scp glyph@100.115.9.61:/opt/nexus/traefik/certs/self-signed.crt ./

# Install certificate
Import-Certificate -FilePath "self-signed.crt" -CertStoreLocation "Cert:\LocalMachine\Root"

# Verify installation
Get-ChildItem -Path "Cert:\LocalMachine\Root" | Where-Object { $_.Subject -like "*nxcore*" }
```

### **Step 3: Service Access Configuration**

#### **Primary Services Access**
```
✅ Landing Page: https://nxcore.tail79107c.ts.net/
✅ AI Assistant: https://nxcore.tail79107c.ts.net/ai/
✅ File Management: https://nxcore.tail79107c.ts.net/files/
✅ Monitoring: https://nxcore.tail79107c.ts.net/grafana/
✅ Status Page: https://nxcore.tail79107c.ts.net/status/
```

#### **Administrative Services Access**
```
✅ Portainer: https://nxcore.tail79107c.ts.net/portainer/
✅ Traefik Dashboard: https://nxcore.tail79107c.ts.net/traefik/
✅ n8n Workflows: https://nxcore.tail79107c.ts.net/n8n/
```

---

## 🔐 **Authentication Procedures**

### **Authelia SSO Configuration**

#### **User Database Management**
```bash
# Access Authelia user database
ssh glyph@100.115.9.61 "sudo docker exec authelia cat /config/users_database.yml"

# Add new user entry
# Format: username: password_hash, groups, permissions
```

#### **Group Management**
```yaml
# User groups configuration
groups:
  - name: stakeholders
    permissions:
      - "service:grafana"
      - "service:prometheus"
      - "service:files"
      - "service:ai"
  
  - name: administrators
    permissions:
      - "service:portainer"
      - "service:traefik"
      - "service:n8n"
      - "service:grafana"
      - "service:prometheus"
```

### **MFA Setup Procedures**

#### **TOTP Configuration**
```bash
# User must configure TOTP app (Google Authenticator, Authy)
# Scan QR code from Authelia interface
# Enter verification code to complete setup
```

#### **Recovery Codes**
```bash
# Generate recovery codes for user
# Store securely for emergency access
# Provide to user via secure channel
```

---

## 🖥️ **PC Management Procedures**

### **Stakeholder PC Deployment**

#### **Hardware Requirements**
- **Model**: Dell OptiPlex 3050 SFF
- **OS**: Windows 11 Pro
- **RAM**: 16GB minimum
- **Storage**: 512GB NVMe SSD
- **Network**: Gigabit Ethernet + Wi-Fi

#### **Software Installation**
```powershell
# Core applications
winget install Microsoft.VisualStudioCode
winget install Git.Git
winget install 7zip.7zip
winget install VideoLAN.VLC
winget install Node.js.NodeJS

# AeroVista applications
# Copy from deployment package
Copy-Item "aerocoreos-staff-call-branded.zip" "C:\AeroVista\apps\"
Copy-Item "av-rustdesk-desktop-pack.zip" "C:\AeroVista\apps\"
```

#### **Security Configuration**
```powershell
# Enable BitLocker
Enable-BitLocker -MountPoint "C:" -EncryptionMethod XtsAes256

# Configure Windows Defender
Set-MpPreference -DisableRealtimeMonitoring $false
Add-MpPreference -ExclusionPath "C:\AeroVista\"

# Configure Firewall
New-NetFirewallRule -DisplayName "Tailscale" -Direction Inbound -Protocol TCP -LocalPort 41641 -Action Allow
```

### **Network Configuration**

#### **Tailscale Setup**
```powershell
# Install Tailscale
winget install Tailscale.Tailscale

# Join network
tailscale up --ssh --hostname av-collab-<name>

# Verify connection
tailscale status
```

#### **Certificate Installation**
```powershell
# Download and install NXCore certificate
# Follow certificate installation procedures
# Verify HTTPS access to all services
```

---

## 📱 **PWA Installation Procedures**

### **AeroVista PWAs**

#### **Required PWAs**
1. **AeroCoreOS Dashboard**: `https://nxcore.tail79107c.ts.net/`
2. **AI Assistant**: `https://nxcore.tail79107c.ts.net/ai/`
3. **File Manager**: `https://nxcore.tail79107c.ts.net/files/`
4. **Monitoring Dashboard**: `https://nxcore.tail79107c.ts.net/grafana/`
5. **Status Page**: `https://nxcore.tail79107c.ts.net/status/`

#### **Installation Process**
```javascript
// For each PWA:
// 1. Navigate to URL in browser
// 2. Click "Install" button
// 3. Pin to Start Menu and Taskbar
// 4. Configure permissions (microphone, notifications)
```

### **Administrative PWAs**

#### **Management PWAs**
1. **Portainer**: `https://nxcore.tail79107c.ts.net/portainer/`
2. **Traefik Dashboard**: `https://nxcore.tail79107c.ts.net/traefik/`
3. **n8n Workflows**: `https://nxcore.tail79107c.ts.net/n8n/`

---

## 🎯 **User Training Procedures**

### **Basic User Training (30 minutes)**

#### **System Overview**
- NXCore infrastructure purpose and benefits
- Available services and their functions
- Security policies and best practices
- Support procedures and contacts

#### **Service Training**
- **Landing Page**: Navigation and status monitoring
- **AI Assistant**: Chat interface and capabilities
- **File Manager**: File upload/download and organization
- **Monitoring**: System status and performance metrics

### **Administrative Training (2 hours)**

#### **System Administration**
- Portainer container management
- Traefik routing configuration
- n8n workflow automation
- Grafana dashboard customization

#### **Troubleshooting Training**
- Common issues and solutions
- Log analysis and diagnostics
- Service restart procedures
- Emergency response protocols

---

## 🔧 **Access Control Procedures**

### **Permission Management**

#### **Service Access Control**
```yaml
# Authelia configuration for service access
access_control:
  default_policy: deny
  rules:
    - domain: "nxcore.tail79107c.ts.net"
      policy: one_factor
      subject: "group:stakeholders"
    - domain: "portainer.nxcore.tail79107c.ts.net"
      policy: two_factor
      subject: "group:administrators"
```

#### **User Group Management**
```bash
# Add user to group
# Edit Authelia configuration
# Restart Authelia container
ssh glyph@100.115.9.61 "sudo docker restart authelia"
```

### **Access Revocation Procedures**

#### **Temporary Access Suspension**
```bash
# Disable user account in Authelia
# Edit users_database.yml
# Set user as disabled
# Restart Authelia container
```

#### **Permanent Access Removal**
```bash
# Remove user from Authelia database
# Remove from all groups
# Revoke all certificates
# Update access control rules
```

---

## 📞 **User Support Procedures**

### **Level 1 Support: Self-Service**

#### **Common Issues**
- **Certificate Warnings**: Install NXCore certificate
- **Service Access**: Check Tailscale connection
- **Performance Issues**: Clear browser cache
- **Authentication**: Reset password or MFA

#### **Self-Service Resources**
- User guides and documentation
- Troubleshooting checklists
- Video tutorials and training materials
- FAQ and knowledge base

### **Level 2 Support: Technical Support**

#### **Technical Issues**
- Service configuration problems
- Network connectivity issues
- Authentication failures
- Performance optimization

#### **Support Procedures**
- Collect diagnostic information
- Review system logs
- Test connectivity and access
- Escalate to Level 3 if needed

### **Level 3 Support: Administrative Support**

#### **Administrative Issues**
- System configuration changes
- User account management
- Security incidents
- System failures

#### **Emergency Procedures**
- 24/7 emergency hotline
- Critical system failures
- Security breaches
- Data loss prevention

---

## 📊 **User Monitoring and Analytics**

### **Access Monitoring**

#### **User Activity Tracking**
```bash
# Check user login activity
ssh glyph@100.115.9.61 "sudo docker logs authelia | grep 'User.*logged in'"

# Monitor service access
ssh glyph@100.115.9.61 "sudo docker logs traefik | grep 'GET.*HTTP'"
```

#### **Performance Monitoring**
```bash
# Monitor user session performance
# Track service response times
# Monitor resource usage per user
```

### **Usage Analytics**

#### **Service Usage Metrics**
- Most accessed services
- Peak usage times
- User engagement metrics
- Performance bottlenecks

#### **User Behavior Analysis**
- Login patterns and frequency
- Service usage preferences
- Support ticket patterns
- Training effectiveness

---

## 🎯 **Success Criteria**

### **User Onboarding Success**
✅ **Account Created**: User account in Authelia  
✅ **PC Configured**: Stakeholder PC properly set up  
✅ **Services Accessible**: All required services accessible  
✅ **Training Complete**: User trained on system usage  
✅ **Support Available**: Support procedures in place  

### **Ongoing Operations Success**
✅ **Access Control**: Proper permissions and restrictions  
✅ **User Support**: Responsive support procedures  
✅ **Monitoring**: User activity and performance tracking  
✅ **Security**: Secure access and authentication  

---

## 📚 **Related Documentation**

- **[DAILY_OPERATIONS_SOP.md](DAILY_OPERATIONS_SOP.md)** - Daily operational procedures
- **[PC_MANAGEMENT_CONSOLIDATED.md](../consolidated/PC_MANAGEMENT_CONSOLIDATED.md)** - PC setup procedures
- **[SYSTEM_STATUS_CONSOLIDATED.md](../consolidated/SYSTEM_STATUS_CONSOLIDATED.md)** - System status information

---

**This SOP provides comprehensive procedures for managing user access, onboarding, and support within the NXCore infrastructure ecosystem.**
