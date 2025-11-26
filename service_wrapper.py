import os
import sys
import subprocess
import time

import win32event
import win32service
import win32serviceutil
import servicemanager


class PrinterFlaskService(win32serviceutil.ServiceFramework):
    _svc_name_ = "PrinterFlaskService"
    _svc_display_name_ = "Printer Flask Service"
    _svc_description_ = "Runs the Flask label-printing app via Waitress (Windows service wrapper)."

    def __init__(self, args):
        super().__init__(args)
        # Event for stop signal
        self.hWaitStop = win32event.CreateEvent(None, 0, 0, None)
        self.process = None

    def SvcStop(self):
        # Called when service is asked to stop
        self.ReportServiceStatus(win32service.SERVICE_STOP_PENDING)
        servicemanager.LogInfoMsg("PrinterFlaskService: stopping...")
        try:
            if self.process and self.process.poll() is None:
                self.process.terminate()
                try:
                    self.process.wait(timeout=10)
                except Exception:
                    self.process.kill()
        except Exception as e:
            servicemanager.LogErrorMsg(f"PrinterFlaskService: error stopping process: {e}")
        win32event.SetEvent(self.hWaitStop)

    def SvcDoRun(self):
        # Called when the service is started
        servicemanager.LogInfoMsg("PrinterFlaskService: starting")

        # Ensure working directory is the app folder
        this_dir = os.path.dirname(os.path.abspath(__file__))

        # Get the correct Python executable - when running as Windows service,
        # sys.executable points to pythonservice.exe, but we need python.exe
        if sys.executable.endswith('pythonservice.exe'):
            # Replace pythonservice.exe with python.exe
            python = sys.executable.replace('pythonservice.exe', 'python.exe')
        else:
            python = sys.executable

        # Command: run waitress serve to host app:app
        cmd = [python, "-m", "waitress", "serve", "--host=0.0.0.0", "--port=8080", "app:app"]

        servicemanager.LogInfoMsg(f"PrinterFlaskService: running {cmd}")

        # Start subprocess (will inherit the service account environment)
        try:
            self.process = subprocess.Popen(cmd, cwd=this_dir)
        except Exception as e:
            servicemanager.LogErrorMsg(f"PrinterFlaskService: failed to start subprocess: {e}")
            return

        # Wait for stop event
        win32event.WaitForSingleObject(self.hWaitStop, win32event.INFINITE)

        servicemanager.LogInfoMsg("PrinterFlaskService: stopped")


if __name__ == "__main__":
    # When executed from the command line, allow install/start/stop/remove
    win32serviceutil.HandleCommandLine(PrinterFlaskService)
