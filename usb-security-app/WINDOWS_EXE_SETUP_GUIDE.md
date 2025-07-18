# Windows EXE Setup Guide - USB Security Software

This comprehensive guide explains how to convert your USB Security Software Python application into a professional Windows executable setup.

## Table of Contents
1. [Quick Start](#quick-start)
2. [Prerequisites](#prerequisites)
3. [Build Methods](#build-methods)
4. [Professional Installer Creation](#professional-installer-creation)
5. [Distribution Options](#distribution-options)
6. [Troubleshooting](#troubleshooting)
7. [Advanced Configuration](#advanced-configuration)

## Quick Start

### Method 1: One-Click Professional Installer (Recommended)
```batch
# Run the comprehensive installer creator
create_installer.bat
```
This creates:
- Professional Windows installer (.exe)
- Portable ZIP package
- Manual installation scripts
- Complete documentation

### Method 2: Advanced Build Only
```batch
# Run the advanced build script
build_advanced.bat
```
This creates a standalone executable in the `dist/` folder.

### Method 3: Basic Build
```batch
# Run the original build script
build.bat
```
This creates a basic executable package.

## Prerequisites

### Required Software
1. **Python 3.8+** with pip
2. **All dependencies** from requirements.txt
3. **Inno Setup 6** (optional, for professional installer)

### Installation Commands
```batch
# Install Python dependencies
pip install -r requirements.txt

# Verify installation
python --version
pip show pyinstaller
```

### Optional: Inno Setup
Download from: https://jrsoftware.org/isinfo.php
- Enables professional installer creation
- Adds uninstaller and registry integration
- Creates Start Menu and Desktop shortcuts

## Build Methods

### 1. Professional Build (`create_installer.bat`)

**Features:**
- Complete installer package creation
- Multiple distribution formats
- Professional documentation
- Asset generation
- License file creation
- Deployment guides

**Output:**
```
installer/
├── USB_Security_Setup_v1.0.0.exe    # Professional installer
├── USB Security_v1.0.0_Portable.zip # Portable version
├── Install_USB_Security.bat          # Manual installer
├── DEPLOYMENT_GUIDE.txt              # IT deployment guide
└── dist/                             # Raw files
```

**Usage:**
```batch
create_installer.bat
```

### 2. Advanced Build (`build_advanced.bat`)

**Features:**
- Enhanced error handling
- Version information embedding
- Icon integration
- Resource bundling
- Launcher scripts
- Uninstaller creation

**Output:**
```
dist/
├── USB_Security.exe              # Main executable
├── Start_USB_Security.bat        # Enhanced launcher
├── Uninstall.bat                 # Uninstaller
├── INSTALLATION_INFO.txt         # Setup guide
└── config/                       # Configuration files
```

**Usage:**
```batch
build_advanced.bat
```

### 3. Custom Build with Spec File

**Features:**
- Fine-grained control
- Advanced PyInstaller options
- Custom manifest
- Optimized size
- Hidden imports handling

**Usage:**
```batch
pyinstaller usb_security.spec
```

## Professional Installer Creation

### Inno Setup Configuration

The `installer_setup.iss` file provides:

**Features:**
- Modern wizard interface
- Administrator privilege handling
- Auto-start configuration
- Desktop/Start Menu shortcuts
- Proper uninstallation
- Registry integration
- Process management

**Customization:**
Edit `installer_setup.iss` to modify:
- Company information
- Installation paths
- Feature selection
- UI appearance
- Registry entries

### Manual Compilation
```batch
# If Inno Setup is installed
"C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer_setup.iss
```

## Distribution Options

### 1. Professional Installer (.exe)
**Best for:** End users, automatic deployment
- Single file installation
- Guided setup wizard
- Automatic shortcuts
- Clean uninstallation
- Registry integration

### 2. Portable ZIP Package
**Best for:** Temporary use, restricted environments
- No installation required
- Extract and run
- No registry changes
- Easy cleanup

### 3. Manual Installer Script
**Best for:** IT departments, scripted deployment
- Batch file installation
- Customizable paths
- Silent installation options
- Group Policy deployment

### 4. Raw Distribution Folder
**Best for:** Developers, custom deployment
- Direct file access
- Manual configuration
- Development testing
- Custom integration

## Troubleshooting

### Common Build Issues

#### Python Not Found
```
ERROR: Python is not installed or not in PATH
```
**Solution:** Install Python 3.8+ and add to system PATH

#### PyInstaller Fails
```
ERROR: Build failed
```
**Solutions:**
1. Update PyInstaller: `pip install --upgrade pyinstaller`
2. Clear build cache: Delete `build/` and `dist/` folders
3. Check for missing modules in `hiddenimports`
4. Run with verbose output: `pyinstaller --log-level DEBUG main.py`

#### Missing Dependencies
```
ModuleNotFoundError: No module named 'xyz'
```
**Solution:** Add to `hiddenimports` in spec file or install missing package

#### Icon Issues
```
Warning: Could not create logo
```
**Solution:** Install Pillow: `pip install pillow`

#### Permission Errors
```
ERROR: Failed to copy files
```
**Solutions:**
1. Run as Administrator
2. Close any running instances
3. Disable antivirus temporarily
4. Check file permissions

### Runtime Issues

#### Application Won't Start
**Checks:**
1. Run as Administrator
2. Check Windows Event Viewer
3. Verify all DLL dependencies
4. Test on clean Windows system

#### Overlay Not Appearing
**Solutions:**
1. Check display settings
2. Verify admin privileges
3. Test with "Test Security Overlay" option
4. Check antivirus interference

#### Device Detection Issues
**Solutions:**
1. Verify WMI service is running
2. Check USB device functionality
3. Run Windows Hardware Troubleshooter
4. Update device drivers

## Advanced Configuration

### Custom Icon Creation
```python
# Modify create_logo.py to customize icons
python create_logo.py
```

### Version Information
Edit `build_advanced.bat` variables:
```batch
set "APP_NAME=Your App Name"
set "APP_VERSION=2.0.0"
set "COMPANY_NAME=Your Company"
```

### PyInstaller Optimization
Edit `usb_security.spec`:
- Add/remove hidden imports
- Exclude unnecessary modules
- Adjust UPX compression
- Modify manifest

### Installer Customization
Edit `installer_setup.iss`:
- Change UI appearance
- Add custom pages
- Modify installation logic
- Add registry entries

## Security Considerations

### Code Signing
For enterprise deployment:
1. Obtain code signing certificate
2. Sign the executable:
   ```batch
   signtool sign /f certificate.pfx /p password USB_Security.exe
   ```

### Antivirus Compatibility
- Add to antivirus whitelist
- Submit to antivirus vendors
- Use reputable code signing certificate
- Document security features

### Deployment Security
- Test on isolated systems
- Use Group Policy for deployment
- Implement centralized logging
- Regular security updates

## Performance Optimization

### Executable Size Reduction
1. Enable UPX compression
2. Exclude unnecessary modules
3. Use `--onefile` mode
4. Remove debug information

### Startup Time Optimization
1. Minimize hidden imports
2. Use lazy loading
3. Optimize Python code
4. Consider `--onedir` for faster startup

### Memory Usage
1. Monitor resource usage
2. Optimize PyQt5 usage
3. Implement proper cleanup
4. Use memory profiling tools

## Testing Checklist

### Pre-Distribution Testing
- [ ] Build completes without errors
- [ ] Executable runs on clean Windows system
- [ ] All features work correctly
- [ ] No missing dependencies
- [ ] Proper error handling
- [ ] Admin privileges work
- [ ] System tray integration
- [ ] Device detection functional
- [ ] Overlay displays correctly
- [ ] Settings persist correctly

### Installer Testing
- [ ] Installation completes successfully
- [ ] Shortcuts created properly
- [ ] Auto-start works (if enabled)
- [ ] Uninstaller removes all files
- [ ] No registry orphans
- [ ] Works on different Windows versions
- [ ] Handles existing installations
- [ ] Admin privilege elevation

## Support and Maintenance

### User Support
- Provide INSTALLATION_INFO.txt
- Create troubleshooting guide
- Document common issues
- Set up support channels

### Updates and Patches
- Version control system
- Automated build process
- Update distribution mechanism
- Backward compatibility testing

### Monitoring and Logging
- Application telemetry
- Error reporting
- Usage analytics
- Performance monitoring

---

## Summary

This guide provides multiple methods to convert your USB Security Software into a professional Windows executable:

1. **Quick Setup:** Use `create_installer.bat` for complete package
2. **Advanced Build:** Use `build_advanced.bat` for enhanced executable
3. **Custom Build:** Use `usb_security.spec` for fine control
4. **Professional Installer:** Use Inno Setup for enterprise deployment

Choose the method that best fits your distribution needs and technical requirements.

For additional support, refer to the generated documentation files and the main README.md.
