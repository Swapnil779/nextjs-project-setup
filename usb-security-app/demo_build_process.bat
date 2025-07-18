@echo off
setlocal enabledelayedexpansion

echo ========================================
echo USB Security Software - Build Demo
echo ========================================
echo.
echo This script demonstrates the complete process of converting
echo your Python USB Security Software into a Windows EXE setup.
echo.

REM Set colors for better visibility
for /F %%a in ('echo prompt $E ^| cmd') do set "ESC=%%a"
set "GREEN=%ESC%[92m"
set "YELLOW=%ESC%[93m"
set "RED=%ESC%[91m"
set "BLUE=%ESC%[94m"
set "RESET=%ESC%[0m"

echo %BLUE%Available Build Options:%RESET%
echo.
echo %GREEN%1. Quick Professional Build%RESET% (Recommended)
echo    - Creates complete installer package
echo    - Professional Windows installer (.exe)
echo    - Portable ZIP version
echo    - Complete documentation
echo    - Ready for distribution
echo.
echo %GREEN%2. Advanced Executable Build%RESET%
echo    - Enhanced standalone executable
echo    - Better error handling
echo    - Version information
echo    - Launcher scripts
echo.
echo %GREEN%3. Basic Executable Build%RESET%
echo    - Simple PyInstaller build
echo    - Basic executable creation
echo    - Minimal configuration
echo.
echo %GREEN%4. Custom Build with Spec File%RESET%
echo    - Advanced PyInstaller configuration
echo    - Fine-grained control
echo    - Optimized build settings
echo.
echo %GREEN%5. Generate Assets Only%RESET%
echo    - Create application icons
echo    - Generate logos and graphics
echo    - Prepare visual assets
echo.
echo %GREEN%6. View Documentation%RESET%
echo    - Open setup guide
echo    - View project summary
echo    - Check requirements
echo.

set /p choice=%YELLOW%Enter your choice (1-6): %RESET%

echo.

if "%choice%"=="1" goto professional_build
if "%choice%"=="2" goto advanced_build
if "%choice%"=="3" goto basic_build
if "%choice%"=="4" goto custom_build
if "%choice%"=="5" goto generate_assets
if "%choice%"=="6" goto view_docs
goto invalid_choice

:professional_build
echo %GREEN%Starting Professional Build Process...%RESET%
echo.
echo This will create a complete installer package including:
echo - Professional Windows installer
echo - Portable version
echo - Documentation
echo - License files
echo.
pause
echo.
call create_installer.bat
goto end

:advanced_build
echo %GREEN%Starting Advanced Build Process...%RESET%
echo.
echo This will create an enhanced standalone executable with:
echo - Better error handling
echo - Version information
echo - Enhanced launcher
echo - Uninstaller
echo.
pause
echo.
call build_advanced.bat
goto end

:basic_build
echo %GREEN%Starting Basic Build Process...%RESET%
echo.
echo This will create a basic executable using the original build script.
echo.
pause
echo.
call build.bat
goto end

:custom_build
echo %GREEN%Starting Custom Build with Spec File...%RESET%
echo.
echo This uses the advanced PyInstaller specification file for:
echo - Fine-grained control
echo - Optimized settings
echo - Custom manifest
echo.
pause
echo.

REM Check if Python and PyInstaller are available
python --version >nul 2>&1
if errorlevel 1 (
    echo %RED%ERROR: Python is not installed or not in PATH%RESET%
    pause
    goto end
)

pip show pyinstaller >nul 2>&1
if errorlevel 1 (
    echo Installing PyInstaller...
    pip install pyinstaller
)

echo Building with custom spec file...
pyinstaller usb_security.spec

if errorlevel 1 (
    echo %RED%Build failed. Check the output above for errors.%RESET%
) else (
    echo %GREEN%Build completed successfully!%RESET%
    echo Executable created in: dist\USB_Security.exe
)
goto end

:generate_assets
echo %GREEN%Generating Application Assets...%RESET%
echo.
echo This will create:
echo - Application icons (.ico, .png)
echo - Warning logos
echo - System tray icons
echo - Installer graphics
echo.
pause
echo.

python --version >nul 2>&1
if errorlevel 1 (
    echo %RED%ERROR: Python is not installed%RESET%
    pause
    goto end
)

pip show pillow >nul 2>&1
if errorlevel 1 (
    echo Installing Pillow for image generation...
    pip install pillow
)

python create_logo.py

if errorlevel 1 (
    echo %YELLOW%Warning: Some assets may not have been created%RESET%
) else (
    echo %GREEN%Assets generated successfully!%RESET%
    if exist "assets" (
        echo.
        echo Generated files in assets folder:
        dir /b assets
    )
)
goto end

:view_docs
echo %GREEN%Opening Documentation...%RESET%
echo.
echo Available documentation files:
echo.

if exist "WINDOWS_EXE_SETUP_GUIDE.md" (
    echo %GREEN%✓%RESET% WINDOWS_EXE_SETUP_GUIDE.md - Complete setup guide
)
if exist "PROJECT_SUMMARY.md" (
    echo %GREEN%✓%RESET% PROJECT_SUMMARY.md - Project overview
)
if exist "README.md" (
    echo %GREEN%✓%RESET% README.md - General documentation
)
if exist "requirements.txt" (
    echo %GREEN%✓%RESET% requirements.txt - Python dependencies
)

echo.
set /p doc_choice=%YELLOW%Which document would you like to view? (1=Setup Guide, 2=Project Summary, 3=README): %RESET%

if "%doc_choice%"=="1" (
    if exist "WINDOWS_EXE_SETUP_GUIDE.md" (
        notepad "WINDOWS_EXE_SETUP_GUIDE.md"
    ) else (
        echo %RED%Setup guide not found%RESET%
    )
)
if "%doc_choice%"=="2" (
    if exist "PROJECT_SUMMARY.md" (
        notepad "PROJECT_SUMMARY.md"
    ) else (
        echo %RED%Project summary not found%RESET%
    )
)
if "%doc_choice%"=="3" (
    if exist "README.md" (
        notepad "README.md"
    ) else (
        echo %RED%README not found%RESET%
    )
)
goto end

:invalid_choice
echo %RED%Invalid choice. Please select 1-6.%RESET%
pause
goto end

:end
echo.
echo %BLUE%========================================%RESET%
echo %BLUE%Build Process Information%RESET%
echo %BLUE%========================================%RESET%
echo.

REM Show current directory contents
echo %YELLOW%Current directory contents:%RESET%
dir /b *.bat *.py *.md *.txt *.iss *.spec 2>nul

echo.
if exist "dist" (
    echo %YELLOW%Distribution folder (dist):%RESET%
    dir /b dist 2>nul
    echo.
)

if exist "installer" (
    echo %YELLOW%Installer folder:%RESET%
    dir /b installer 2>nul
    echo.
)

if exist "assets" (
    echo %YELLOW%Assets folder:%RESET%
    dir /b assets 2>nul
    echo.
)

echo %GREEN%Next Steps:%RESET%
echo.
echo 1. Test the built executable on a clean Windows system
echo 2. Verify all features work correctly
echo 3. Create user documentation
echo 4. Consider code signing for enterprise deployment
echo 5. Set up distribution channels
echo.
echo %BLUE%For detailed instructions, see WINDOWS_EXE_SETUP_GUIDE.md%RESET%
echo.
pause
