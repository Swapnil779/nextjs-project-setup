#!/usr/bin/env python3
"""
Test script for USB Security Software
Tests basic functionality without requiring actual USB devices
"""

import sys
import os
import json
import time
from datetime import datetime

def test_imports():
    """Test if all required modules can be imported"""
    print("Testing imports...")
    
    try:
        import wmi
        print("✓ WMI module imported successfully")
    except ImportError as e:
        print(f"✗ WMI import failed: {e}")
        return False
    
    try:
        from PyQt5.QtWidgets import QApplication
        from PyQt5.QtCore import Qt
        from PyQt5.QtGui import QIcon
        print("✓ PyQt5 modules imported successfully")
    except ImportError as e:
        print(f"✗ PyQt5 import failed: {e}")
        return False
    
    try:
        import psutil
        print("✓ psutil module imported successfully")
    except ImportError as e:
        print(f"✗ psutil import failed: {e}")
        return False
    
    return True

def test_device_monitor():
    """Test device monitor functionality"""
    print("\nTesting Device Monitor...")
    
    try:
        from device_monitor import DeviceMonitor
        
        def test_callback(event_type, device_info):
            print(f"Callback received: {event_type} - {device_info}")
        
        monitor = DeviceMonitor(callback=test_callback)
        print("✓ DeviceMonitor created successfully")
        
        # Test whitelist functionality
        monitor.add_to_whitelist("test_device_id", "Test Device")
        if monitor.is_device_whitelisted("test_device_id", "Test Device"):
            print("✓ Whitelist functionality working")
        else:
            print("✗ Whitelist functionality failed")
            return False
        
        # Test getting connected drives
        drives = monitor.get_connected_removable_drives()
        print(f"✓ Found {len(drives)} removable drives")
        
        return True
        
    except Exception as e:
        print(f"✗ Device Monitor test failed: {e}")
        return False

def test_security_overlay():
    """Test security overlay (without showing it)"""
    print("\nTesting Security Overlay...")
    
    try:
        from PyQt5.QtWidgets import QApplication
        from security_overlay import SecurityOverlay
        
        # Create QApplication if it doesn't exist
        app = QApplication.instance()
        if app is None:
            app = QApplication(sys.argv)
        
        # Create overlay but don't show it
        overlay = SecurityOverlay(duration_minutes=1)
        print("✓ SecurityOverlay created successfully")
        
        # Test overlay properties
        if overlay.duration_minutes == 1:
            print("✓ Duration setting working")
        else:
            print("✗ Duration setting failed")
            return False
        
        overlay.close()
        return True
        
    except Exception as e:
        print(f"✗ Security Overlay test failed: {e}")
        return False

def test_configuration():
    """Test configuration file handling"""
    print("\nTesting Configuration...")
    
    try:
        # Test config directory creation
        os.makedirs('config', exist_ok=True)
        print("✓ Config directory created")
        
        # Test settings file
        test_settings = {
            "lockout_duration": 15,
            "enable_blinking": True,
            "enable_notifications": True,
            "auto_start": True,
            "whitelist": []
        }
        
        settings_path = os.path.join('config', 'test_settings.json')
        with open(settings_path, 'w') as f:
            json.dump(test_settings, f, indent=2)
        print("✓ Settings file created")
        
        # Test reading settings
        with open(settings_path, 'r') as f:
            loaded_settings = json.load(f)
        
        if loaded_settings == test_settings:
            print("✓ Settings file read/write working")
        else:
            print("✗ Settings file read/write failed")
            return False
        
        # Clean up test file
        os.remove(settings_path)
        
        return True
        
    except Exception as e:
        print(f"✗ Configuration test failed: {e}")
        return False

def test_logging():
    """Test logging functionality"""
    print("\nTesting Logging...")
    
    try:
        from device_monitor import DeviceMonitor
        
        monitor = DeviceMonitor()
        
        # Test logging
        test_device_info = {
            'drive_letter': 'X:',
            'detection_time': datetime.now().isoformat()
        }
        
        monitor.log_event("TEST_EVENT", test_device_info)
        print("✓ Event logging working")
        
        # Check if log file was created
        log_file = os.path.join('config', 'security_log.json')
        if os.path.exists(log_file):
            print("✓ Log file created")
            
            # Read and verify log
            with open(log_file, 'r') as f:
                logs = json.load(f)
            
            if len(logs) > 0 and logs[-1]['event'] == 'TEST_EVENT':
                print("✓ Log entry verified")
            else:
                print("✗ Log entry verification failed")
                return False
        else:
            print("✗ Log file not created")
            return False
        
        return True
        
    except Exception as e:
        print(f"✗ Logging test failed: {e}")
        return False

def test_system_requirements():
    """Test system requirements"""
    print("\nTesting System Requirements...")
    
    # Check Python version
    python_version = sys.version_info
    if python_version >= (3, 8):
        print(f"✓ Python version {python_version.major}.{python_version.minor} is supported")
    else:
        print(f"✗ Python version {python_version.major}.{python_version.minor} is too old (need 3.8+)")
        return False
    
    # Check platform
    if sys.platform.startswith('win'):
        print("✓ Running on Windows")
    else:
        print(f"⚠ Running on {sys.platform} (designed for Windows)")
    
    # Check if running as admin (Windows only)
    if sys.platform.startswith('win'):
        try:
            import ctypes
            is_admin = ctypes.windll.shell32.IsUserAnAdmin()
            if is_admin:
                print("✓ Running with administrator privileges")
            else:
                print("⚠ Not running as administrator (some features may not work)")
        except:
            print("⚠ Could not check administrator status")
    
    return True

def main():
    """Run all tests"""
    print("USB Security Software - Test Suite")
    print("=" * 50)
    
    tests = [
        ("System Requirements", test_system_requirements),
        ("Module Imports", test_imports),
        ("Configuration", test_configuration),
        ("Device Monitor", test_device_monitor),
        ("Security Overlay", test_security_overlay),
        ("Logging", test_logging),
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        print(f"\n{test_name}:")
        print("-" * 30)
        
        try:
            if test_func():
                passed += 1
                print(f"✓ {test_name} PASSED")
            else:
                print(f"✗ {test_name} FAILED")
        except Exception as e:
            print(f"✗ {test_name} FAILED with exception: {e}")
    
    print("\n" + "=" * 50)
    print(f"Test Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("✓ All tests passed! USB Security Software is ready to use.")
        return 0
    else:
        print("✗ Some tests failed. Please check the installation.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
