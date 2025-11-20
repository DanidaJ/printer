@echo off
echo Installing Printer Service...

echo Step 1: Installing Python dependencies...
pip install -r requirements.txt

echo Step 2: Stopping existing service (if running)...
python service_wrapper.py stop

echo Step 3: Installing/updating service...
python service_wrapper.py install

echo Step 4: Starting service...
python service_wrapper.py start

echo Step 5: Testing service...
timeout /t 3
curl http://localhost:8080/test

echo.
echo Deployment complete!
echo Check above for any errors.
pause