# NXCore Windows to Linux Server Deployment Script
# Deploys fixes from Windows development machine to Linux server

param(
    [string]$ServerIP = "100.115.9.61",
    [string]$ServerUser = "glyph",
    [string]$ServerPath = "/srv/core",
    [switch]$TestOnly = $false,
    [switch]$DeployFixes = $false,
    [switch]$RunTests = $false
)

# Colors for output
$Red = "`e[31m"
$Green = "`e[32m"
$Yellow = "`e[33m"
$Blue = "`e[34m"
$Reset = "`e[0m"

function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host "${Color}${Message}${Reset}"
}

function Test-ServerConnection {
    Write-ColorOutput "🔍 Testing server connection..." $Blue
    
    try {
        $result = ssh -o ConnectTimeout=10 -o BatchMode=yes ${ServerUser}@${ServerIP} "echo 'Connection successful'"
        if ($result -match "Connection successful") {
            Write-ColorOutput "✅ Server connection successful" $Green
            return $true
        }
    }
    catch {
        Write-ColorOutput "❌ Server connection failed: $($_.Exception.Message)" $Red
        return $false
    }
}

function Copy-ScriptsToServer {
    Write-ColorOutput "📤 Copying scripts to server..." $Blue
    
    $scripts = @(
        "comprehensive-fix-implementation.sh",
        "enhanced-service-monitor.py",
        "playwright-service-tester.js"
    )
    
    foreach ($script in $scripts) {
        $localPath = "scripts\$script"
        $remotePath = "${ServerPath}/scripts/$script"
        
        if (Test-Path $localPath) {
            Write-ColorOutput "  Copying $script..." $Blue
            scp $localPath "${ServerUser}@${ServerIP}:${remotePath}"
            
            # Make executable
            ssh ${ServerUser}@${ServerIP} "chmod +x ${remotePath}"
        } else {
            Write-ColorOutput "  ⚠️ Script not found: $localPath" $Yellow
        }
    }
}

function Copy-ConfigsToServer {
    Write-ColorOutput "📤 Copying configurations to server..." $Blue
    
    $configs = @(
        "docker/compose-traefik-fixed.yml",
        "docker/compose-grafana-fixed.yml", 
        "docker/compose-prometheus-fixed.yml",
        "docker/compose-cadvisor-fixed.yml"
    )
    
    foreach ($config in $configs) {
        $localPath = $config
        $remotePath = "${ServerPath}/$config"
        
        if (Test-Path $localPath) {
            Write-ColorOutput "  Copying $config..." $Blue
            scp $localPath "${ServerUser}@${ServerIP}:${remotePath}"
        } else {
            Write-ColorOutput "  ⚠️ Config not found: $localPath" $Yellow
        }
    }
}

function Run-ServerTests {
    Write-ColorOutput "🧪 Running tests on server..." $Blue
    
    # Run comprehensive test
    Write-ColorOutput "  Running comprehensive test..." $Blue
    ssh ${ServerUser}@${ServerIP} "cd ${ServerPath} && node comprehensive-test.js"
    
    # Run enhanced monitoring
    Write-ColorOutput "  Running enhanced monitoring..." $Blue
    ssh ${ServerUser}@${ServerIP} "cd ${ServerPath}/scripts && python3 enhanced-service-monitor.py"
}

function Deploy-ServerFixes {
    Write-ColorOutput "🚀 Deploying fixes to server..." $Blue
    
    # Run the comprehensive fix script
    Write-ColorOutput "  Running comprehensive fix implementation..." $Blue
    ssh ${ServerUser}@${ServerIP} "cd ${ServerPath}/scripts && ./comprehensive-fix-implementation.sh"
    
    # Verify fixes
    Write-ColorOutput "  Verifying fixes..." $Blue
    ssh ${ServerUser}@${ServerIP} "cd ${ServerPath} && node comprehensive-test.js"
}

function Run-LocalTests {
    Write-ColorOutput "🧪 Running local tests..." $Blue
    
    # Test if Node.js is available
    if (Get-Command node -ErrorAction SilentlyContinue) {
        Write-ColorOutput "  Running comprehensive test..." $Blue
        node ..\comprehensive-test.js
    } else {
        Write-ColorOutput "  ⚠️ Node.js not found, skipping local tests" $Yellow
    }
    
    # Test if Python is available
    if (Get-Command python -ErrorAction SilentlyContinue) {
        Write-ColorOutput "  Running enhanced monitoring..." $Blue
        python scripts\enhanced-service-monitor.py
    } else {
        Write-ColorOutput "  ⚠️ Python not found, skipping enhanced monitoring" $Yellow
    }
}

function Show-Status {
    Write-ColorOutput "📊 Current system status:" $Blue
    
    # Check server status
    Write-ColorOutput "  Checking server status..." $Blue
    ssh ${ServerUser}@${ServerIP} "docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'"
    
    # Check service health
    Write-ColorOutput "  Checking service health..." $Blue
    ssh ${ServerUser}@${ServerIP} "curl -k -s https://nxcore.tail79107c.ts.net/api/http/routers | head -20"
}

# Main execution
Write-ColorOutput "🚀 NXCore Windows to Server Deployment" $Blue
Write-ColorOutput "=====================================" $Blue
Write-ColorOutput "Server: ${ServerUser}@${ServerIP}" $Blue
Write-ColorOutput "Path: ${ServerPath}" $Blue
Write-ColorOutput ""

# Test connection
if (-not (Test-ServerConnection)) {
    Write-ColorOutput "❌ Cannot connect to server. Please check your SSH configuration." $Red
    exit 1
}

# Copy files to server
Copy-ScriptsToServer
Copy-ConfigsToServer

# Run local tests if requested
if ($RunTests) {
    Run-LocalTests
}

# Run server tests if requested
if ($TestOnly) {
    Run-ServerTests
    Show-Status
}

# Deploy fixes if requested
if ($DeployFixes) {
    Deploy-ServerFixes
    Show-Status
}

# Show status if no specific action
if (-not $TestOnly -and -not $DeployFixes -and -not $RunTests) {
    Show-Status
    Write-ColorOutput ""
    Write-ColorOutput "Usage examples:" $Blue
    Write-ColorOutput "  .\windows-to-server-deployment.ps1 -TestOnly" $Yellow
    Write-ColorOutput "  .\windows-to-server-deployment.ps1 -DeployFixes" $Yellow
    Write-ColorOutput "  .\windows-to-server-deployment.ps1 -RunTests" $Yellow
}

Write-ColorOutput "✅ Deployment script completed!" $Green
