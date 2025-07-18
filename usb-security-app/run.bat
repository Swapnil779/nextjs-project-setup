@echo off
echo Starting USB Security Software...

REM Check if Python is available
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please run install.bat first
    pause
    exit /b 1
)

REM Run the application
python main.py

if errorlevel 1 (
    echo ERROR: Failed to start USB Security Software
    echo Make sure all dependencies are installed by running install.bat
    pause
)
