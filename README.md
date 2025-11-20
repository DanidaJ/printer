# Printer Service Setup Guide

This guide will help you set up the Flask printer service on a Windows computer after downloading from GitHub.

**Note**: You can extract the files to any folder location. Throughout this guide, we use `C:\printer\` as an example, but replace it with your actual folder path.

## Prerequisites

- Windows 10 or later
- Administrator access
- Internet connection
- Zebra printer connected and configured

## Step 1: Download and Extract

1. Go to: https://github.com/DanidaJ/printer
2. Click **"Code"** → **"Download ZIP"**
3. Extract the ZIP file to any folder you prefer:
   - `C:\printer\` (recommended)
   - `C:\PrinterService\`
   - `D:\MyPrinter\`
   - Or any other location

## Step 2: Install Python

1. Download Python from: https://www.python.org/downloads/
2. **IMPORTANT**: During installation, check **"Add Python to PATH"**
3. Verify installation by opening Command Prompt and typing:
   ```cmd
   python --version
   ```

## Step 3: Configure Printer

1. Open **Control Panel** → **Devices and Printers**
2. Find your Zebra printer
3. **Option A**: Rename it to "Zebra" (recommended)
4. **Option B**: Edit `app.py` and change `PRINTER_NAME = "Zebra"` to match your printer name

## Step 4: Automatic Setup

1. Open **Command Prompt as Administrator**
2. Navigate to the folder where you extracted the files:
   ```cmd
   cd C:\printer
   ```
   (Replace `C:\printer` with your actual folder path)
3. Run the deployment script:
   ```cmd
   deploy.bat
   ```

The script will automatically:
- Install Python dependencies
- Stop any existing service
- Install the Windows service
- Start the service
- Test the installation

## Step 5: Verify Installation

After the script completes, you should see:
```json
{"status": "success", "message": "Server is running!"}
```

### Manual Testing

Test the service manually:
```cmd
curl http://localhost:8080/test
```

Test printing (replace with actual values):
```cmd
curl -X POST http://localhost:8080/print/ -H "Content-Type: application/json" -d "{\"barcode\":\"123456\",\"order\":\"ORD001\",\"size\":\"L\",\"piece\":\"1\"}"
```

## Service Management

### Check Service Status
```cmd
python service_wrapper.py status
```

### Start Service
```cmd
python service_wrapper.py start
```

### Stop Service
```cmd
python service_wrapper.py stop
```

### Remove Service
```cmd
python service_wrapper.py remove
```

### View Service in Windows
1. Press `Win + R`, type `services.msc`
2. Look for **"Printer Flask Service"**

## Troubleshooting

### Service Won't Start
1. Check Python is installed correctly
2. Verify all dependencies are installed:
   ```cmd
   pip list
   ```
3. Check Windows Event Viewer:
   - Press `Win + R`, type `eventvwr.msc`
   - Navigate to **Windows Logs** → **Application**
   - Look for **"PrinterFlaskService"** entries

### Printer Not Working
1. Verify printer name matches `PRINTER_NAME` in `app.py`
2. Test printer outside the application
3. Ensure printer is configured as RAW/Generic printer

### Port Issues
- Service runs on port 8080
- Check Windows Firewall if accessing from other computers
- Use `netstat -an | findstr 8080` to verify port is listening

### Permission Issues
- Ensure you run Command Prompt as Administrator
- Service runs under Local System account
- If printer access issues occur, you may need to configure service to run under a specific user account

## Network Access

If you need to access the service from other computers on the network:

1. **Windows Firewall**: Allow port 8080
   ```cmd
   netsh advfirewall firewall add rule name="Printer Service" dir=in action=allow protocol=TCP localport=8080
   ```

2. **Access from other computers**:
   ```
   http://[FACTORY-COMPUTER-IP]:8080/test
   http://[FACTORY-COMPUTER-IP]:8080/print/
   ```

## Auto-Start Configuration

The service is configured to start automatically with Windows. No manual intervention is required after initial setup.

## Files Overview

- `app.py` - Main Flask application
- `service_wrapper.py` - Windows service wrapper
- `requirements.txt` - Python dependencies
- `deploy.bat` - Automated deployment script
- `static/` - Static web files (if any)
- `templates/` - HTML templates (if any)

## Support

If you encounter issues:
1. Check the troubleshooting section above
2. Review Windows Event Logs
3. Verify all prerequisites are met
4. Ensure printer is properly configured

---

**Important**: Always run the Command Prompt as Administrator when managing the Windows service.