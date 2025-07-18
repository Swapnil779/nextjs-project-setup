# USB Security Software

A Windows security application that protects your system from unauthorized external storage devices (USB drives, external HDDs). When an unauthorized device is connected, the software displays a full-screen security alert for 15 minutes (configurable) with a virus warning.

## Features

- **Real-time USB/HDD Monitoring**: Detects when external storage devices are connected
- **Security Overlay**: Displays a full-screen white warning screen with virus alert
- **Device Whitelisting**: Allow trusted devices to connect without triggering alerts
- **Configurable Lockout**: Set custom lockout duration (1-60 minutes)
- **System Tray Integration**: Runs quietly in the background
- **Security Logging**: Tracks all device connection attempts
- **Blinking Alert**: Optional blinking effect for enhanced visibility
- **Auto-start**: Automatically starts with Windows (optional)

## System Requirements

- Windows 10/11
- Python 3.8 or higher
- Administrator privileges (recommended for full functionality)

## Installation

### Method 1: Quick Install (Recommended)

1. Download or clone this repository
2. Double-click `install.bat` to automatically install dependencies
3. Double-click `run.bat` to start the application

### Method 2: Manual Install

1. Ensure Python 3.8+ is installed
2. Open Command Prompt as Administrator
3. Navigate to the application directory
4. Run: `pip install -r requirements.txt`
5. Run: `python main.py`

## Usage

### Starting the Application

- **Easy Start**: Double-click `run.bat`
- **Command Line**: `python main.py`

The application will start and appear as an icon in the system tray.

### System Tray Menu

Right-click the tray icon to access:

- **Settings**: Configure lockout duration, effects, and notifications
- **View Security Logs**: See history of device connections
- **Manage Whitelist**: Add/remove trusted devices
- **Test Security Overlay**: Test the alert screen
- **Exit**: Close the application

### When a Device is Detected

1. **Unauthorized Device Connected**: 
   - Full-screen white alert appears immediately
   - Shows virus warning logo and countdown timer
   - Screen remains locked for configured duration (default: 15 minutes)
   - System tray notification appears

2. **Device Removed**:
   - Alert screen disappears automatically
   - System returns to normal operation
   - Removal is logged

### Managing Trusted Devices

1. Connect your trusted USB/HDD devices
2. Right-click tray icon → "Manage Whitelist"
3. Click "Add Current Devices"
4. Trusted devices won't trigger alerts in future

## Configuration

### Settings Options

- **Lockout Duration**: 1-60 minutes (default: 15)
- **Enable Blinking Effect**: Makes alert more noticeable
- **Enable Notifications**: System tray popup notifications
- **Start with Windows**: Auto-start on system boot

### Configuration Files

Settings are stored in `config/settings.json`:

```json
{
  "lockout_duration": 15,
  "enable_blinking": true,
  "enable_notifications": true,
  "auto_start": true,
  "whitelist": []
}
```

## Security Features

### Alert Screen Details

- **Full-screen overlay**: Cannot be minimized or closed easily
- **Virus warning**: Clear indication of potential threat
- **Countdown timer**: Shows remaining lockout time
- **Emergency exit**: Ctrl+Shift+Esc or Alt+F4 (can be password-protected)

### Logging

All events are logged in `config/security_log.json`:
- Device connections (authorized/unauthorized)
- Device removals
- Timestamps and device details
- Automatic log rotation (keeps last 1000 entries)

## Advanced Usage

### Running as Windows Service

For maximum security, consider running as a Windows service:

1. Install `pywin32`: `pip install pywin32`
2. Use Windows Task Scheduler to run at startup
3. Set to run with highest privileges

### Creating Executable

To create a standalone .exe file:

```bash
pip install pyinstaller
pyinstaller --onefile --windowed --icon=assets/icon.ico main.py
```

## Troubleshooting

### Common Issues

1. **"Python not found"**
   - Install Python from https://python.org
   - Ensure Python is added to PATH during installation

2. **"Permission denied" errors**
   - Run Command Prompt as Administrator
   - Some USB monitoring requires elevated privileges

3. **Alert screen not appearing**
   - Check if device is already whitelisted
   - Verify USB device is detected by Windows
   - Check security logs for events

4. **Application won't start**
   - Run `install.bat` to reinstall dependencies
   - Check Python version: `python --version`

### Debug Mode

Run with debug output:
```bash
python main.py --debug
```

## File Structure

```
usb-security-app/
├── main.py                 # Main application
├── device_monitor.py       # USB/HDD detection
├── security_overlay.py     # Alert screen
├── requirements.txt        # Dependencies
├── install.bat            # Installation script
├── run.bat               # Run script
├── README.md             # This file
├── config/
│   ├── settings.json     # Configuration
│   └── security_log.json # Event logs
└── assets/
    └── (icons and images)
```

## Security Considerations

- **Admin Rights**: Run with administrator privileges for full USB monitoring
- **Whitelist Management**: Regularly review whitelisted devices
- **Log Monitoring**: Check security logs for suspicious activity
- **Emergency Access**: Remember emergency exit combinations
- **Updates**: Keep Python and dependencies updated

## Customization

### Custom Alert Messages

Edit `security_overlay.py` to customize:
- Alert text and messages
- Colors and styling
- Countdown format
- Logo/images

### Custom Detection Logic

Edit `device_monitor.py` to modify:
- Device detection criteria
- Whitelisting logic
- Logging format
- Event handling

## License

This software is provided as-is for educational and security purposes. Use responsibly and in accordance with your organization's security policies.

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review security logs for error details
3. Test with debug mode enabled

---

**Warning**: This software is designed for security purposes. Ensure you have proper authorization before deploying in any environment. The full-screen alert may interfere with normal computer operation during the lockout period.
