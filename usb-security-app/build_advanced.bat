@echo off
setlocal enabledelayedexpansion

echo ========================================
echo USB Security Software - Advanced Builder
echo ========================================
echo.

REM Set variables
set "APP_NAME=USB Security"
set "APP_VERSION=1.0.0"
set "COMPANY_NAME=Security Solutions"
set "EXE_NAME=USB_Security"

REM Check if Python is installed
echo [1/8] Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.8+ and add it to your PATH
    pause
    exit /b 1
)

REM Get Python version
for /f "tokens=2" %%i in ('python --version 2^>^&1') do set PYTHON_VERSION=%%i
echo Python %PYTHON_VERSION% detected

REM Check if required packages are installed
echo.
echo [2/8] Checking dependencies...
pip show pyinstaller >nul 2>&1
if errorlevel 1 (
    echo Installing PyInstaller...
    pip install pyinstaller
    if errorlevel 1 (
        echo ERROR: Failed to install PyInstaller
        pause
        exit /b 1
    )
)

pip show pyqt5 >nul 2>&1
if errorlevel 1 (
    echo Installing required dependencies...
    pip install -r requirements.txt
    if errorlevel 1 (
        echo ERROR: Failed to install dependencies
        pause
        exit /b 1
    )
)

REM Create build directories
echo.
echo [3/8] Preparing build environment...
if exist "dist" rmdir /s /q "dist"
if exist "build" rmdir /s /q "build"
mkdir "dist" 2>nul
mkdir "build" 2>nul
mkdir "installer" 2>nul

REM Create application icon
echo.
echo [4/8] Creating application resources...
python create_logo.py
if errorlevel 1 (
    echo Warning: Could not create logo, using default icon
)

REM Create version info file
echo.
echo [5/8] Creating version information...
(
echo VSVersionInfo^(
echo   ffi=FixedFileInfo^(
echo     filevers=^(1, 0, 0, 0^),
echo     prodvers=^(1, 0, 0, 0^),
echo     mask=0x3f,
echo     flags=0x0,
echo     OS=0x40004,
echo     fileType=0x1,
echo     subtype=0x0,
echo     date=^(0, 0^)
echo   ^),
echo   kids=[
echo     StringFileInfo^(
echo       [
echo         StringTable^(
echo           u'040904B0',
echo           [StringStruct^(u'CompanyName', u'%COMPANY_NAME%'^),
echo            StringStruct^(u'FileDescription', u'%APP_NAME%'^),
echo            StringStruct^(u'FileVersion', u'%APP_VERSION%'^),
echo            StringStruct^(u'InternalName', u'%EXE_NAME%'^),
echo            StringStruct^(u'LegalCopyright', u'Copyright ^(c^) 2024'^),
echo            StringStruct^(u'OriginalFilename', u'%EXE_NAME%.exe'^),
echo            StringStruct^(u'ProductName', u'%APP_NAME%'^),
echo            StringStruct^(u'ProductVersion', u'%APP_VERSION%'^)]
echo         ^)
echo       ]
echo     ^),
echo     VarFileInfo^([VarStruct^(u'Translation', [1033, 1200]^)]^)
echo   ]
echo ^)
) > build\version_info.py

REM Build the executable
echo.
echo [6/8] Building executable...
echo This may take several minutes...

set PYINSTALLER_ARGS=--onefile --windowed --name="%EXE_NAME%" --distpath="dist" --workpath="build" --specpath="build"
set PYINSTALLER_ARGS=%PYINSTALLER_ARGS% --version-file="build\version_info.py"
set PYINSTALLER_ARGS=%PYINSTALLER_ARGS% --add-data="config;config"

REM Add icon if available
if exist "assets\app_icon.ico" (
    set PYINSTALLER_ARGS=%PYINSTALLER_ARGS% --icon="assets\app_icon.ico"
)

REM Hidden imports for common issues
set PYINSTALLER_ARGS=%PYINSTALLER_ARGS% --hidden-import=win32timezone
set PYINSTALLER_ARGS=%PYINSTALLER_ARGS% --hidden-import=pywintypes
set PYINSTALLER_ARGS=%PYINSTALLER_ARGS% --hidden-import=win32api

pyinstaller %PYINSTALLER_ARGS% main.py

if errorlevel 1 (
    echo ERROR: Build failed
    echo Check the build log above for details
    pause
    exit /b 1
)

REM Copy additional files
echo.
echo [7/8] Copying additional files...
xcopy /E /I /Y "config" "dist\config\" >nul
xcopy /Y "README.md" "dist\" >nul
xcopy /Y "requirements.txt" "dist\" >nul

REM Create launcher script
echo.
echo [8/8] Creating launcher and installer...

REM Create enhanced run script
(
echo @echo off
echo title %APP_NAME%
echo echo Starting %APP_NAME%...
echo echo.
echo if not exist "%EXE_NAME%.exe" ^(
echo     echo ERROR: %EXE_NAME%.exe not found
echo     echo Please ensure you're running this from the correct directory
echo     pause
echo     exit /b 1
echo ^)
echo.
echo REM Check for admin privileges
echo net session ^>nul 2^>^&1
echo if errorlevel 1 ^(
echo     echo WARNING: Not running as Administrator
echo     echo Some features may not work properly
echo     echo.
echo     timeout /t 3 /nobreak ^>nul
echo ^)
echo.
echo start "" "%EXE_NAME%.exe"
echo if errorlevel 1 ^(
echo     echo ERROR: Failed to start %APP_NAME%
echo     echo Please check the error message above
echo     pause
echo ^)
) > "dist\Start_%EXE_NAME%.bat"

REM Create uninstaller
(
echo @echo off
echo title Uninstall %APP_NAME%
echo echo Uninstalling %APP_NAME%...
echo echo.
echo taskkill /f /im "%EXE_NAME%.exe" 2^>nul
echo timeout /t 2 /nobreak ^>nul
echo.
echo echo Removing files...
echo del /q "%EXE_NAME%.exe" 2^>nul
echo rmdir /s /q "config" 2^>nul
echo del /q "README.md" 2^>nul
echo del /q "requirements.txt" 2^>nul
echo del /q "Start_%EXE_NAME%.bat" 2^>nul
echo echo.
echo echo %APP_NAME% has been uninstalled.
echo pause
echo del /q "%%~f0"
) > "dist\Uninstall.bat"

REM Create installer info
(
echo %APP_NAME% v%APP_VERSION%
echo ========================
echo.
echo Installation completed successfully!
echo.
echo Files included:
echo - %EXE_NAME%.exe          ^(Main application^)
echo - Start_%EXE_NAME%.bat    ^(Launcher script^)
echo - config\                 ^(Configuration files^)
echo - README.md               ^(Documentation^)
echo - Uninstall.bat           ^(Uninstaller^)
echo.
echo To start the application:
echo 1. Double-click "Start_%EXE_NAME%.bat" OR
echo 2. Double-click "%EXE_NAME%.exe" directly
echo.
echo For best results, run as Administrator.
echo.
echo Support: Check README.md for troubleshooting
) > "dist\INSTALLATION_INFO.txt"

echo.
echo ========================================
echo BUILD COMPLETED SUCCESSFULLY!
echo ========================================
echo.
echo Executable created: dist\%EXE_NAME%.exe
echo Size: 
for %%A in ("dist\%EXE_NAME%.exe") do echo %%~zA bytes
echo.
echo Distribution folder: dist\
echo.
echo Files ready for distribution:
dir /b "dist\"
echo.
echo To distribute:
echo 1. Copy the entire 'dist' folder to target computers
echo 2. Run 'Start_%EXE_NAME%.bat' on target system
echo 3. Or create an installer using the installer script
echo.
echo Next steps:
echo - Test the executable on a clean Windows system
echo - Consider creating an MSI installer for enterprise deployment
echo - Add digital signature for enhanced security
echo.
pause
