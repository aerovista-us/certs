#!/bin/bash
# NXCore Certificate Bundle Kit Deployment Script

echo "🔐 NXCore Certificate Bundle Kit - Deploying to Server..."

# Configuration
SERVER_HOST="nxcore.tail79107c.ts.net"
SERVER_USER="root"
BUNDLE_DIR="/opt/nexus/cert-bundles"

# Create local bundle directory
LOCAL_BUNDLE_DIR="./cert-bundles"
mkdir -p "$LOCAL_BUNDLE_DIR"

# Function to deploy files to server
deploy_to_server() {
    local local_file="$1"
    local server_path="$2"
    local description="$3"
    
    echo "📤 Deploying $description..."
    if scp "$local_file" "$SERVER_USER@$SERVER_HOST:$server_path"; then
        echo "✅ $description deployed successfully"
    else
        echo "❌ Failed to deploy $description"
        return 1
    fi
}

# Function to run commands on server
run_on_server() {
    local command="$1"
    local description="$2"
    
    echo "🔧 $description..."
    if ssh "$SERVER_USER@$SERVER_HOST" "$command"; then
        echo "✅ $description completed successfully"
    else
        echo "❌ Failed to $description"
        return 1
    fi
}

echo "🚀 Starting NXCore Certificate Bundle Kit Deployment..."

# Step 1: Create certificate bundle kit locally
echo "📦 Creating certificate bundle kit locally..."
if [ -f "./scripts/create-certificate-bundle-kit.sh" ]; then
    chmod +x "./scripts/create-certificate-bundle-kit.sh"
    ./scripts/create-certificate-bundle-kit.sh
else
    echo "❌ Certificate bundle kit script not found"
    exit 1
fi

# Step 2: Create Android installer locally
echo "📱 Creating Android certificate installer locally..."
if [ -f "./scripts/create-android-cert-installer.sh" ]; then
    chmod +x "./scripts/create-android-cert-installer.sh"
    ./scripts/create-android-cert-installer.sh
else
    echo "❌ Android installer script not found"
    exit 1
fi

# Step 3: Create Windows installer locally
echo "🖥️ Creating Windows certificate installer locally..."
if [ -f "./scripts/create-windows-cert-installer.sh" ]; then
    chmod +x "./scripts/create-windows-cert-installer.sh"
    ./scripts/create-windows-cert-installer.sh
else
    echo "❌ Windows installer script not found"
    exit 1
fi

# Step 4: Deploy certificate bundle kit to server
echo "📤 Deploying certificate bundle kit to server..."

# Create bundle directory on server
run_on_server "mkdir -p $BUNDLE_DIR/{android,windows,universal}" "Creating bundle directory structure"

# Deploy main certificate bundle kit
deploy_to_server "./scripts/create-certificate-bundle-kit.sh" "$BUNDLE_DIR/" "Certificate bundle kit script"
deploy_to_server "./scripts/create-android-cert-installer.sh" "$BUNDLE_DIR/" "Android installer script"
deploy_to_server "./scripts/create-windows-cert-installer.sh" "$BUNDLE_DIR/" "Windows installer script"

# Step 5: Run certificate bundle kit creation on server
echo "🔧 Running certificate bundle kit creation on server..."
run_on_server "cd $BUNDLE_DIR && chmod +x *.sh && ./create-certificate-bundle-kit.sh" "Creating certificate bundle kit"
run_on_server "cd $BUNDLE_DIR && ./create-android-cert-installer.sh" "Creating Android installer"
run_on_server "cd $BUNDLE_DIR && ./create-windows-cert-installer.sh" "Creating Windows installer"

# Step 6: Configure nginx for certificate bundles
echo "🌐 Configuring nginx for certificate bundles..."
run_on_server "cp $BUNDLE_DIR/nginx.conf /etc/nginx/sites-available/cert-bundles" "Copying nginx configuration"
run_on_server "ln -sf /etc/nginx/sites-available/cert-bundles /etc/nginx/sites-enabled/" "Enabling nginx site"
run_on_server "nginx -t && systemctl reload nginx" "Testing and reloading nginx"

# Step 7: Set proper permissions
echo "🔐 Setting proper permissions..."
run_on_server "chown -R www-data:www-data $BUNDLE_DIR" "Setting ownership"
run_on_server "chmod -R 644 $BUNDLE_DIR/*" "Setting permissions"

# Step 8: Test certificate bundle access
echo "🧪 Testing certificate bundle access..."
run_on_server "curl -s -o /dev/null -w '%{http_code}' https://$SERVER_HOST/certs/" "Testing main certificate page"
run_on_server "curl -s -o /dev/null -w '%{http_code}' https://$SERVER_HOST/certs/android/" "Testing Android installer page"
run_on_server "curl -s -o /dev/null -w '%{http_code}' https://$SERVER_HOST/certs/windows/" "Testing Windows installer page"

echo ""
echo "🎉 NXCore Certificate Bundle Kit Deployment Complete!"
echo ""
echo "📱 Android Certificate Installation:"
echo "   - Main Page: https://$SERVER_HOST/certs/android/"
echo "   - APK Download: https://$SERVER_HOST/certs/android/cert-installer.apk"
echo "   - Manual Guide: https://$SERVER_HOST/certs/android/manual/ANDROID_INSTALL.md"
echo ""
echo "🖥️ Windows Certificate Installation:"
echo "   - Main Page: https://$SERVER_HOST/certs/windows/"
echo "   - EXE Download: https://$SERVER_HOST/certs/windows/cert-installer.exe"
echo "   - Manual Guide: https://$SERVER_HOST/certs/windows/manual/WINDOWS_INSTALL.md"
echo ""
echo "🌐 Universal Certificate Files:"
echo "   - Root CA: https://$SERVER_HOST/certs/universal/AeroVista-RootCA.cer"
echo "   - Client Cert: https://$SERVER_HOST/certs/universal/User-Gold.p12"
echo ""
echo "🔐 Main Certificate Bundle Page:"
echo "   - https://$SERVER_HOST/certs/"
echo ""
echo "✅ All certificate bundle kits are now available for download and installation!"
echo "📱 Start with Android: https://$SERVER_HOST/certs/android/"
echo "🖥️ Then Windows: https://$SERVER_HOST/certs/windows/"
