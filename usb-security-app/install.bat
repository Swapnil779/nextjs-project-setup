@echo off
echo Installing USB Security Software...
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.8 or higher from https://python.org
    pause
    exit /b 1
)

echo Python found. Installing dependencies...
pip install -r requirements.txt

if errorlevel 1 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)

echo.
echo Installation completed successfully!
echo.
echo To run the USB Security Software:
echo 1. Double-click 'run.bat' to start the application
echo 2. Or run 'python main.py' from command line
echo.
echo The application will run in the system tray.
echo Right-click the tray icon to access settings and options.
echo.
pause
