@echo off
echo Building USB Security Software Executable...
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    pause
    exit /b 1
)

REM Check if PyInstaller is installed
pip show pyinstaller >nul 2>&1
if errorlevel 1 (
    echo Installing PyInstaller...
    pip install pyinstaller
)

REM Create build directory
if not exist "dist" mkdir dist
if not exist "build" mkdir build

echo.
echo Building executable...
echo This may take a few minutes...

REM Build the executable
pyinstaller --onefile --windowed --name="USB_Security" --distpath="dist" --workpath="build" --specpath="build" main.py

if errorlevel 1 (
    echo ERROR: Build failed
    pause
    exit /b 1
)

REM Copy necessary files to dist folder
echo.
echo Copying configuration files...
xcopy /E /I /Y "config" "dist\config\"
xcopy /Y "README.md" "dist\"
xcopy /Y "requirements.txt" "dist\"

REM Create run script for executable
echo @echo off > "dist\run_usb_security.bat"
echo echo Starting USB Security Software... >> "dist\run_usb_security.bat"
echo USB_Security.exe >> "dist\run_usb_security.bat"
echo if errorlevel 1 ( >> "dist\run_usb_security.bat"
echo     echo ERROR: Failed to start USB Security Software >> "dist\run_usb_security.bat"
echo     pause >> "dist\run_usb_security.bat"
echo ) >> "dist\run_usb_security.bat"

echo.
echo Build completed successfully!
echo.
echo Executable created: dist\USB_Security.exe
echo.
echo To distribute:
echo 1. Copy the entire 'dist' folder to target computer
echo 2. Run 'USB_Security.exe' or 'run_usb_security.bat'
echo.
echo Note: The executable includes all dependencies and can run
echo without Python being installed on the target system.
echo.
pause
