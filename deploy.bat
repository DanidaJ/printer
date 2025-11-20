@echo off
title Printer Service Deployment
color 0A

echo ====================================================
echo           PRINTER SERVICE DEPLOYMENT
echo ====================================================
echo.

echo Checking prerequisites...

REM Check if Python is installed
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Python is not installed or not in PATH!
    echo Please install Python from https://www.python.org/downloads/
    echo Make sure to check "Add Python to PATH" during installation.
    echo.
    pause
    exit /b 1
)

echo [OK] Python is installed
python --version

REM Check if pip is available
pip --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] pip is not available!
    echo.
    pause
    exit /b 1
)

echo [OK] pip is available
echo.

echo ====================================================
echo Step 1: Installing Python dependencies...
echo ====================================================
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install dependencies!
    pause
    exit /b 1
)
echo [OK] Dependencies installed successfully
echo.

echo ====================================================
echo Step 2: Stopping existing service (if running)...
echo ====================================================
python service_wrapper.py stop 2>nul
echo [OK] Existing service stopped (if it was running)
echo.

echo ====================================================
echo Step 3: Installing/updating Windows service...
echo ====================================================
python service_wrapper.py install
if %errorlevel% neq 0 (
    echo [ERROR] Failed to install service!
    echo Make sure you are running as Administrator.
    pause
    exit /b 1
)
echo [OK] Service installed successfully
echo.

echo ====================================================
echo Step 4: Starting service...
echo ====================================================
python service_wrapper.py start
if %errorlevel% neq 0 (
    echo [ERROR] Failed to start service!
    pause
    exit /b 1
)
echo [OK] Service started successfully
echo.

echo ====================================================
echo Step 5: Testing service...
echo ====================================================
echo Waiting for service to initialize...
timeout /t 5 /nobreak >nul

REM Test if curl is available, if not use PowerShell
curl --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Using PowerShell for testing...
    powershell -Command "try { $response = Invoke-RestMethod -Uri 'http://localhost:8080/test' -Method Get; Write-Host '[OK] Service is responding:'; Write-Host $response.message -ForegroundColor Green } catch { Write-Host '[ERROR] Service test failed:' -ForegroundColor Red; Write-Host $_.Exception.Message -ForegroundColor Red }"
) else (
    echo Using curl for testing...
    curl -s http://localhost:8080/test
    if %errorlevel% neq 0 (
        echo [ERROR] Service test failed!
    ) else (
        echo [OK] Service is responding correctly!
    )
)

echo.
echo ====================================================
echo                DEPLOYMENT COMPLETE!
echo ====================================================
echo.
echo Service Status:
python service_wrapper.py status
echo.
echo The Printer Flask Service is now running and will
echo start automatically when Windows boots.
echo.
echo Service URL: http://localhost:8080
echo Test URL:    http://localhost:8080/test
echo Print URL:   http://localhost:8080/print/
echo.
echo To manage the service:
echo   python service_wrapper.py start     (Start service)
echo   python service_wrapper.py stop      (Stop service)  
echo   python service_wrapper.py restart   (Restart service)
echo   python service_wrapper.py remove    (Remove service)
echo.
echo Check Windows Services (services.msc) for "Printer Flask Service"
echo.
pause