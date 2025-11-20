# Manual Setup Instructions

If the automated `deploy.bat` script doesn't work, follow these manual steps:

## Manual Installation Steps

### 1. Install Python Dependencies
Open Command Prompt as Administrator and navigate to the printer folder:
```cmd
cd C:\PrinterService
pip install Flask==3.0.0
pip install waitress>=2.1.2
pip install pywin32>=306
```

### 2. Test Flask App (Optional)
Before installing as a service, test the Flask app directly:
```cmd
python -m waitress --host=0.0.0.0 --port=8080 app:app
```
Open browser and go to: http://localhost:8080/test
Press Ctrl+C to stop.

### 3. Install Windows Service
```cmd
python service_wrapper.py install
```

### 4. Start the Service
```cmd
python service_wrapper.py start
```

### 5. Verify Service is Running
```cmd
python service_wrapper.py status
```

## Alternative Testing Methods

### Using PowerShell (if curl is not available)
```powershell
Invoke-RestMethod -Uri "http://localhost:8080/test" -Method Get
```

### Test Print Request
```powershell
$body = @{
    barcode = "123456"
    order = "ORD001"
    size = "L"
    piece = "1"
} | ConvertTo-Json

Invoke-RestMethod -Uri "http://localhost:8080/print/" -Method Post -Body $body -ContentType "application/json"
```

## Troubleshooting Common Issues

### "Python is not recognized"
- Reinstall Python and check "Add Python to PATH"
- Or add Python manually to PATH in System Environment Variables

### "Access is denied"
- Run Command Prompt as Administrator
- Right-click Command Prompt → "Run as administrator"

### Service fails to start
1. Check Windows Event Viewer (eventvwr.msc)
2. Look under Windows Logs → Application
3. Find entries from "PrinterFlaskService"

### Printer not found
1. Check printer name in Control Panel → Printers & Scanners
2. Update `PRINTER_NAME` in `app.py` if needed:
   ```python
   PRINTER_NAME = "Your Actual Printer Name"
   ```

## Service Management Commands

```cmd
# Install service
python service_wrapper.py install

# Start service  
python service_wrapper.py start

# Stop service
python service_wrapper.py stop

# Check status
python service_wrapper.py status

# Remove service
python service_wrapper.py remove

# Debug service (run in foreground)
python service_wrapper.py debug
```

## Network Configuration

To allow access from other computers:

### Windows Firewall
```cmd
netsh advfirewall firewall add rule name="Printer Service Port 8080" dir=in action=allow protocol=TCP localport=8080
```

### Find Computer IP Address
```cmd
ipconfig
```
Use the IPv4 address to access from other computers:
`http://192.168.1.XXX:8080/test`