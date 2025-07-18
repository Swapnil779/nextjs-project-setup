@echo off
setlocal enabledelayedexpansion

echo ========================================
echo USB Security Software - Installer Creator
echo ========================================
echo.

REM Set variables
set "APP_NAME=USB Security"
set "APP_VERSION=1.0.0"
set "COMPANY_NAME=Security Solutions"
set "EXE_NAME=USB_Security"

echo Creating professional Windows installer for %APP_NAME%...
echo.

REM Step 1: Check prerequisites
echo [1/7] Checking prerequisites...
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.8+ and add it to your PATH
    pause
    exit /b 1
)

REM Check for Inno Setup (optional)
set "INNO_SETUP_PATH="
if exist "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" (
    set "INNO_SETUP_PATH=C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
) else if exist "C:\Program Files\Inno Setup 6\ISCC.exe" (
    set "INNO_SETUP_PATH=C:\Program Files\Inno Setup 6\ISCC.exe"
)

if defined INNO_SETUP_PATH (
    echo ✓ Inno Setup found: Professional installer will be created
) else (
    echo ! Inno Setup not found: Only portable version will be created
    echo   Download from: https://jrsoftware.org/isinfo.php
)

REM Step 2: Install dependencies
echo.
echo [2/7] Installing dependencies...
pip install -r requirements.txt
if errorlevel 1 (
    echo ERROR: Failed to install dependencies
    pause
    exit /b 1
)

REM Step 3: Generate assets
echo.
echo [3/7] Generating application assets...
python create_logo.py
if errorlevel 1 (
    echo Warning: Could not create all assets, using defaults
)

REM Step 4: Build executable
echo.
echo [4/7] Building executable...
call build_advanced.bat
if errorlevel 1 (
    echo ERROR: Failed to build executable
    pause
    exit /b 1
)

REM Step 5: Create license file
echo.
echo [5/7] Creating license and documentation...
(
echo MIT License
echo.
echo Copyright ^(c^) 2024 %COMPANY_NAME%
echo.
echo Permission is hereby granted, free of charge, to any person obtaining a copy
echo of this software and associated documentation files ^(the "Software"^), to deal
echo in the Software without restriction, including without limitation the rights
echo to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
echo copies of the Software, and to permit persons to whom the Software is
echo furnished to do so, subject to the following conditions:
echo.
echo The above copyright notice and this permission notice shall be included in all
echo copies or substantial portions of the Software.
echo.
echo THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
echo IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
echo FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
echo AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
echo LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
echo OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
echo SOFTWARE.
) > LICENSE.txt

REM Create installation info
(
echo %APP_NAME% v%APP_VERSION% - Installation Guide
echo ================================================
echo.
echo SYSTEM REQUIREMENTS:
echo - Windows 10/11 ^(64-bit^)
echo - Administrator privileges ^(recommended^)
echo - 100MB free disk space
echo.
echo INSTALLATION METHODS:
echo.
echo Method 1: Professional Installer ^(Recommended^)
echo - Run USB_Security_Setup_v%APP_VERSION%.exe
echo - Follow the installation wizard
echo - Application will be installed to Program Files
echo - Desktop and Start Menu shortcuts created
echo - Automatic startup configured ^(optional^)
echo.
echo Method 2: Portable Version
echo - Extract the dist folder to desired location
echo - Run Start_USB_Security.bat or USB_Security.exe
echo - No installation required
echo.
echo FIRST RUN:
echo 1. Right-click on the application and select "Run as Administrator"
echo 2. The application will appear in the system tray
echo 3. Right-click the tray icon to access settings
echo 4. Add trusted devices to the whitelist
echo.
echo FEATURES:
echo - Real-time USB/HDD monitoring
echo - Full-screen security alerts
echo - Device whitelisting system
echo - System tray integration
echo - Comprehensive event logging
echo - Configurable lockout duration
echo - Emergency override options
echo.
echo TROUBLESHOOTING:
echo - If the overlay doesn't appear, check display settings
echo - For permission errors, run as Administrator
echo - Check Windows Event Viewer for system errors
echo - Disable antivirus temporarily if installation fails
echo.
echo SUPPORT:
echo - Documentation: README.md
echo - Configuration: config/settings.json
echo - Logs: config/security_log.json
echo.
echo For technical support, please refer to the README.md file.
) > INSTALLATION_INFO.txt

REM Step 6: Create professional installer
echo.
echo [6/7] Creating installer package...

if defined INNO_SETUP_PATH (
    echo Creating professional installer with Inno Setup...
    "%INNO_SETUP_PATH%" installer_setup.iss
    if errorlevel 1 (
        echo Warning: Inno Setup compilation failed, check the script
    ) else (
        echo ✓ Professional installer created: installer\USB_Security_Setup_v%APP_VERSION%.exe
    )
) else (
    echo Creating portable installer package...
    if not exist "installer" mkdir installer
    
    REM Create self-extracting archive script
    (
    echo @echo off
    echo title %APP_NAME% Installer
    echo echo ========================================
    echo echo %APP_NAME% v%APP_VERSION% Installer
    echo echo ========================================
    echo echo.
    echo echo This will install %APP_NAME% on your computer.
    echo echo.
    echo pause
    echo echo.
    echo echo Extracting files...
    echo.
    echo REM Create installation directory
    echo set "INSTALL_DIR=%%ProgramFiles%%\%APP_NAME%"
    echo if not exist "%%INSTALL_DIR%%" mkdir "%%INSTALL_DIR%%"
    echo.
    echo REM Copy files
    echo xcopy /E /I /Y "dist\*" "%%INSTALL_DIR%%\" ^>nul
    echo if errorlevel 1 ^(
    echo     echo ERROR: Failed to copy files
    echo     pause
    echo     exit /b 1
    echo ^)
    echo.
    echo REM Create desktop shortcut
    echo echo Creating desktop shortcut...
    echo powershell -Command "$$WshShell = New-Object -comObject WScript.Shell; $$Shortcut = $$WshShell.CreateShortcut('%%USERPROFILE%%\Desktop\%APP_NAME%.lnk'^); $$Shortcut.TargetPath = '%%INSTALL_DIR%%\%EXE_NAME%.exe'; $$Shortcut.Save(^)"
    echo.
    echo REM Create start menu entry
    echo echo Creating start menu entry...
    echo if not exist "%%APPDATA%%\Microsoft\Windows\Start Menu\Programs\%APP_NAME%" mkdir "%%APPDATA%%\Microsoft\Windows\Start Menu\Programs\%APP_NAME%"
    echo powershell -Command "$$WshShell = New-Object -comObject WScript.Shell; $$Shortcut = $$WshShell.CreateShortcut('%%APPDATA%%\Microsoft\Windows\Start Menu\Programs\%APP_NAME%\%APP_NAME%.lnk'^); $$Shortcut.TargetPath = '%%INSTALL_DIR%%\%EXE_NAME%.exe'; $$Shortcut.Save(^)"
    echo.
    echo echo Installation completed successfully!
    echo echo.
    echo echo %APP_NAME% has been installed to: %%INSTALL_DIR%%
    echo echo.
    echo echo You can now:
    echo echo 1. Start the application from the desktop shortcut
    echo echo 2. Find it in the Start Menu under "%APP_NAME%"
    echo echo 3. Run it directly from: %%INSTALL_DIR%%\%EXE_NAME%.exe
    echo echo.
    echo echo For best results, run as Administrator.
    echo echo.
    echo pause
    ) > installer\Install_%EXE_NAME%.bat
    
    REM Copy distribution files to installer
    xcopy /E /I /Y "dist" "installer\dist\" >nul
    
    echo ✓ Portable installer created: installer\Install_%EXE_NAME%.bat
)

REM Step 7: Create deployment package
echo.
echo [7/7] Creating deployment package...

REM Create ZIP package for easy distribution
if exist "installer\%APP_NAME%_v%APP_VERSION%_Portable.zip" del "installer\%APP_NAME%_v%APP_VERSION%_Portable.zip"

powershell -Command "Compress-Archive -Path 'dist\*' -DestinationPath 'installer\%APP_NAME%_v%APP_VERSION%_Portable.zip'"
if errorlevel 1 (
    echo Warning: Could not create ZIP package
) else (
    echo ✓ Portable ZIP package created
)

REM Create deployment summary
(
echo %APP_NAME% v%APP_VERSION% - Deployment Package
echo =============================================
echo.
echo Created: %DATE% %TIME%
echo.
echo PACKAGE CONTENTS:
echo.
if defined INNO_SETUP_PATH (
echo ✓ Professional Installer:
echo   - installer\USB_Security_Setup_v%APP_VERSION%.exe
echo   - Full installation wizard with shortcuts
echo   - Automatic uninstaller
echo   - Registry integration
echo.
)
echo ✓ Portable Version:
echo   - installer\%APP_NAME%_v%APP_VERSION%_Portable.zip
echo   - No installation required
echo   - Extract and run
echo.
echo ✓ Manual Installer:
echo   - installer\Install_%EXE_NAME%.bat
echo   - Batch script installer
echo   - Creates shortcuts and start menu entries
echo.
echo ✓ Source Files:
echo   - dist\ folder with all application files
echo   - LICENSE.txt
echo   - INSTALLATION_INFO.txt
echo.
echo DISTRIBUTION RECOMMENDATIONS:
echo.
echo For End Users:
if defined INNO_SETUP_PATH (
echo - Use USB_Security_Setup_v%APP_VERSION%.exe for easiest installation
)
echo - Use %APP_NAME%_v%APP_VERSION%_Portable.zip for portable use
echo.
echo For IT Departments:
echo - Use Install_%EXE_NAME%.bat for scripted deployment
echo - Distribute dist\ folder for manual installation
echo - Test on clean Windows systems before deployment
echo.
echo SECURITY NOTES:
echo - Application requires Administrator privileges for full functionality
echo - May trigger antivirus warnings due to system monitoring features
echo - Add to antivirus whitelist if necessary
echo - Digital signing recommended for enterprise deployment
echo.
echo SUPPORT:
echo - See INSTALLATION_INFO.txt for detailed setup instructions
echo - Check README.md for troubleshooting
echo - Review config\settings.json for configuration options
) > installer\DEPLOYMENT_GUIDE.txt

echo.
echo ========================================
echo INSTALLER CREATION COMPLETED!
echo ========================================
echo.
echo Package created successfully!
echo.
echo Available installers:
if defined INNO_SETUP_PATH (
echo ✓ Professional: installer\USB_Security_Setup_v%APP_VERSION%.exe
)
echo ✓ Portable ZIP: installer\%APP_NAME%_v%APP_VERSION%_Portable.zip
echo ✓ Batch Installer: installer\Install_%EXE_NAME%.bat
echo ✓ Manual Files: dist\ folder
echo.
echo Documentation:
echo ✓ Installation Guide: INSTALLATION_INFO.txt
echo ✓ Deployment Guide: installer\DEPLOYMENT_GUIDE.txt
echo ✓ License: LICENSE.txt
echo.
echo Next steps:
echo 1. Test the installer on a clean Windows system
echo 2. Consider digital signing for enterprise deployment
echo 3. Create user documentation and training materials
echo 4. Set up support procedures for end users
echo.
echo The installer is ready for distribution!
echo.
pause
