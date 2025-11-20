# Printer Service PowerShell Deployment Script
# Run this script as Administrator

param(
    [switch]$SkipTest = $false
)

Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "           PRINTER SERVICE DEPLOYMENT" -ForegroundColor Cyan  
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "[ERROR] This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "Checking prerequisites..." -ForegroundColor Yellow

# Check Python installation
try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] Python is installed: $pythonVersion" -ForegroundColor Green
    } else {
        throw "Python not found"
    }
} catch {
    Write-Host "[ERROR] Python is not installed or not in PATH!" -ForegroundColor Red
    Write-Host "Please install Python from https://www.python.org/downloads/" -ForegroundColor Yellow
    Write-Host "Make sure to check 'Add Python to PATH' during installation." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

# Check pip
try {
    $pipVersion = pip --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] pip is available" -ForegroundColor Green
    } else {
        throw "pip not found"
    }
} catch {
    Write-Host "[ERROR] pip is not available!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Step 1: Install dependencies
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "Step 1: Installing Python dependencies..." -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

try {
    pip install -r requirements.txt
    if ($LASTEXITCODE -ne 0) { throw "pip install failed" }
    Write-Host "[OK] Dependencies installed successfully" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to install dependencies!" -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Step 2: Stop existing service
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "Step 2: Stopping existing service (if running)..." -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

python service_wrapper.py stop 2>$null
Write-Host "[OK] Existing service stopped (if it was running)" -ForegroundColor Green
Write-Host ""

# Step 3: Install service
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "Step 3: Installing Windows service..." -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

try {
    python service_wrapper.py install
    if ($LASTEXITCODE -ne 0) { throw "Service install failed" }
    Write-Host "[OK] Service installed successfully" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to install service!" -ForegroundColor Red
    Write-Host "Make sure you are running PowerShell as Administrator." -ForegroundColor Yellow
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""

# Step 4: Start service
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "Step 4: Starting service..." -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan

try {
    python service_wrapper.py start
    if ($LASTEXITCODE -ne 0) { throw "Service start failed" }
    Write-Host "[OK] Service started successfully" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Failed to start service!" -ForegroundColor Red
    Read-Host "Press Enter to exit"  
    exit 1
}

Write-Host ""

# Step 5: Test service
if (-not $SkipTest) {
    Write-Host "=====================================================" -ForegroundColor Cyan
    Write-Host "Step 5: Testing service..." -ForegroundColor Cyan
    Write-Host "=====================================================" -ForegroundColor Cyan
    
    Write-Host "Waiting for service to initialize..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    
    try {
        $response = Invoke-RestMethod -Uri 'http://localhost:8080/test' -Method Get -TimeoutSec 10
        Write-Host "[OK] Service is responding correctly!" -ForegroundColor Green
        Write-Host "Response: $($response.message)" -ForegroundColor Green
    } catch {
        Write-Host "[ERROR] Service test failed!" -ForegroundColor Red
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "The service may still be starting. Try testing manually later." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host "                DEPLOYMENT COMPLETE!" -ForegroundColor Cyan
Write-Host "=====================================================" -ForegroundColor Cyan
Write-Host ""

# Show service status
Write-Host "Service Status:" -ForegroundColor Yellow
python service_wrapper.py status

Write-Host ""
Write-Host "The Printer Flask Service is now running and will" -ForegroundColor Green
Write-Host "start automatically when Windows boots." -ForegroundColor Green
Write-Host ""
Write-Host "Service URLs:" -ForegroundColor Yellow
Write-Host "  Service URL: http://localhost:8080" -ForegroundColor White
Write-Host "  Test URL:    http://localhost:8080/test" -ForegroundColor White  
Write-Host "  Print URL:   http://localhost:8080/print/" -ForegroundColor White
Write-Host ""
Write-Host "Service Management Commands:" -ForegroundColor Yellow
Write-Host "  python service_wrapper.py start     (Start service)" -ForegroundColor White
Write-Host "  python service_wrapper.py stop      (Stop service)" -ForegroundColor White
Write-Host "  python service_wrapper.py restart   (Restart service)" -ForegroundColor White
Write-Host "  python service_wrapper.py remove    (Remove service)" -ForegroundColor White
Write-Host ""
Write-Host "Check Windows Services (services.msc) for 'Printer Flask Service'" -ForegroundColor Yellow
Write-Host ""

Read-Host "Press Enter to exit"