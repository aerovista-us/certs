param(
    [string]$ServerHost = "192.168.7.209",
    [string]$Username = "glyph"
)

$ErrorActionPreference = "Stop"
$VerbosePreference = "Continue"

Write-Host "🔍 NXCore Connection Test" -ForegroundColor Blue
Write-Host "=========================" -ForegroundColor Blue
Write-Host "Testing connection to: $ServerHost"
Write-Host "User: $Username"
Write-Host ""

# Test 1: Ping server
Write-Host "📡 Test 1: Ping server..." -ForegroundColor Yellow
try {
    $pingResult = ping -n 1 $ServerHost 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Server is reachable" -ForegroundColor Green
    } else {
        Write-Host "❌ Server ping failed" -ForegroundColor Red
        Write-Host "Ping output: $pingResult" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Ping test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 2: SSH connection
Write-Host "🔐 Test 2: SSH connection..." -ForegroundColor Yellow
try {
    $sshTest = ssh -o ConnectTimeout=10 -o BatchMode=yes ${Username}@${ServerHost} "echo 'SSH connection successful'" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ SSH connection successful" -ForegroundColor Green
        Write-Host "SSH output: $sshTest" -ForegroundColor Green
    } else {
        Write-Host "❌ SSH connection failed" -ForegroundColor Red
        Write-Host "SSH error: $sshTest" -ForegroundColor Red
        Write-Host "Troubleshooting:" -ForegroundColor Red
        Write-Host "1. Check SSH key: ssh-add -l" -ForegroundColor Red
        Write-Host "2. Test manual SSH: ssh ${Username}@${ServerHost}" -ForegroundColor Red
        Write-Host "3. Check key permissions: icacls ~/.ssh/id_*" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ SSH test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 3: Check directories
Write-Host "📁 Test 3: Check server directories..." -ForegroundColor Yellow
try {
    $dirTest = ssh ${Username}@${ServerHost} "ls -la /srv/core/ 2>/dev/null || echo 'Directory not found'" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Directory check successful" -ForegroundColor Green
        Write-Host "Directory contents: $dirTest" -ForegroundColor Green
    } else {
        Write-Host "❌ Directory check failed" -ForegroundColor Red
        Write-Host "Directory error: $dirTest" -ForegroundColor Red
        Write-Host "Troubleshooting:" -ForegroundColor Red
        Write-Host "1. Check if /srv/core/ exists" -ForegroundColor Red
        Write-Host "2. Check permissions: ls -la /srv/" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Directory test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 4: Test sudo access
Write-Host "🔑 Test 4: Test sudo access..." -ForegroundColor Yellow
try {
    $sudoTest = ssh ${Username}@${ServerHost} "sudo whoami 2>/dev/null || echo 'Sudo failed'" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Sudo access successful" -ForegroundColor Green
        Write-Host "Sudo output: $sudoTest" -ForegroundColor Green
    } else {
        Write-Host "❌ Sudo access failed" -ForegroundColor Red
        Write-Host "Sudo error: $sudoTest" -ForegroundColor Red
        Write-Host "Troubleshooting:" -ForegroundColor Red
        Write-Host "1. Check sudoers: sudo -l" -ForegroundColor Red
        Write-Host "2. Check if user is in sudo group" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ Sudo test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""

# Test 5: Test file copying
Write-Host "📤 Test 5: Test file copying..." -ForegroundColor Yellow
try {
    # Create a test file
    $testFile = "test-connection.txt"
    "This is a test file" | Out-File -FilePath $testFile -Encoding UTF8
    
    $copyTest = scp $testFile ${Username}@${ServerHost}:/tmp/ 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ File copying successful" -ForegroundColor Green
        Write-Host "Copy output: $copyTest" -ForegroundColor Green
        
        # Clean up test file
        Remove-Item $testFile -Force
        ssh ${Username}@${ServerHost} "rm -f /tmp/$testFile" 2>&1 | Out-Null
    } else {
        Write-Host "❌ File copying failed" -ForegroundColor Red
        Write-Host "Copy error: $copyTest" -ForegroundColor Red
        Write-Host "Troubleshooting:" -ForegroundColor Red
        Write-Host "1. Check SCP permissions" -ForegroundColor Red
        Write-Host "2. Check target directory permissions" -ForegroundColor Red
    }
} catch {
    Write-Host "❌ File copy test failed: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "🏁 Connection test complete!" -ForegroundColor Blue
Write-Host "If all tests pass, you can run: .\deploy-all-fixes.ps1" -ForegroundColor Blue