# 🔐 Browser Certificate Fix Guide

**Date**: October 19, 2025  
**Status**: 🚨 **BROWSER CERTIFICATE ISSUES - STEP-BY-STEP FIX**

---

## 🚨 **Current Problem**
- Browser still showing `net::ERR_CERT_AUTHORITY_INVALID`
- Certificate installation didn't work properly
- Services work via curl but not browser

---

## 🔧 **SOLUTION: Proper Certificate Installation**

### **Step 1: Download the Certificate**
- **File**: `nxcore.crt`
- **Location**: `./backups/20251019_051415/certificates/nxcore.crt`

### **Step 2: Windows Certificate Manager Method (RECOMMENDED)**

#### **2.1 Open Certificate Manager**:
1. **Press**: `Win + R`
2. **Type**: `certlm.msc`
3. **Press**: Enter
4. **Click**: "Yes" if prompted for admin rights

#### **2.2 Import Certificate**:
1. **Navigate**: Trusted Root Certification Authorities → Certificates
2. **Right-click**: "Certificates" folder
3. **Select**: "All Tasks" → "Import"
4. **Click**: "Next"

#### **2.3 Select Certificate File**:
1. **Click**: "Browse"
2. **Navigate**: to `./backups/20251019_051415/certificates/`
3. **Select**: `nxcore.crt`
4. **Click**: "Open"
5. **Click**: "Next"

#### **2.4 Choose Certificate Store**:
1. **Select**: "Place all certificates in the following store"
2. **Click**: "Browse"
3. **Select**: "Trusted Root Certification Authorities"
4. **Click**: "OK"
5. **Click**: "Next"
6. **Click**: "Finish"

#### **2.5 Complete Installation**:
1. **Click**: "Yes" when prompted about security warning
2. **Click**: "OK" when installation is complete

### **Step 3: Restart Browser**
1. **Close** all browser windows
2. **Restart** your browser
3. **Test** the services

---

## 🧪 **Testing Steps**

### **Test These URLs**:
- **Landing**: https://nxcore.tail79107c.ts.net/
- **OpenWebUI**: https://nxcore.tail79107c.ts.net/ai/
- **n8n**: https://nxcore.tail79107c.ts.net/n8n/
- **Grafana**: https://nxcore.tail79107c.ts.net/grafana/
- **Uptime Kuma**: https://nxcore.tail79107c.ts.net/status/

### **Expected Results**:
- ✅ **No certificate warnings**
- ✅ **Green lock icon** in address bar
- ✅ **Services load** without errors

---

## 🔍 **Alternative Methods**

### **Method 2: Browser-Specific Installation**

#### **Chrome/Edge**:
1. **Open**: `chrome://settings/certificates`
2. **Click**: "Authorities" tab
3. **Click**: "Import"
4. **Select**: `nxcore.crt`
5. **Check**: "Trust this certificate for identifying websites"
6. **Restart**: Browser

#### **Firefox**:
1. **Open**: `about:preferences#privacy`
2. **Scroll**: to "Certificates" section
3. **Click**: "View Certificates"
4. **Click**: "Import"
5. **Select**: `nxcore.crt`
6. **Check**: "Trust this CA to identify websites"
7. **Restart**: Browser

### **Method 3: Command Line (Advanced)**
```cmd
# Run as Administrator
certlm.msc
# Then follow Step 2 above
```

---

## 🚨 **Troubleshooting**

### **If certificate still shows as untrusted**:
1. **Clear browser cache** and cookies
2. **Restart browser** completely
3. **Check certificate** is in "Trusted Root Certification Authorities"
4. **Try different browser** to test

### **If services still show certificate errors**:
1. **Verify certificate** is properly installed
2. **Check certificate** in browser settings
3. **Try alternative installation method**

### **If installation fails**:
1. **Run as Administrator**
2. **Check file permissions**
3. **Try different certificate format**

---

## 📊 **Verification**

### **Check Certificate Installation**:
1. **Open**: `certlm.msc`
2. **Navigate**: Trusted Root Certification Authorities → Certificates
3. **Look for**: "NXCore Infrastructure" certificate
4. **Verify**: Certificate is listed there

### **Test Certificate Trust**:
- **No certificate warnings** should appear
- **Green lock icon** should show in browser
- **Services should load** without certificate errors

---

## 🎯 **Quick Summary**

**To fix the certificate issue:**
1. **Download**: `nxcore.crt` from `./backups/20251019_051415/certificates/`
2. **Open**: `certlm.msc` (Windows Certificate Manager)
3. **Import**: to "Trusted Root Certification Authorities"
4. **Restart**: Browser
5. **Test**: Services

---

**Browser certificate fix guide ready!** 🎉

*Follow these steps carefully to resolve the certificate trust issues and enable full browser access to all services.*
