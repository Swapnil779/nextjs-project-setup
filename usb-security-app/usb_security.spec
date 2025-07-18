# -*- mode: python ; coding: utf-8 -*-
"""
USB Security Software - PyInstaller Specification File
This file provides advanced configuration for building the executable
"""

import os
import sys
from PyInstaller.utils.hooks import collect_data_files, collect_submodules

# Application information
APP_NAME = 'USB_Security'
APP_VERSION = '1.0.0'
APP_DESCRIPTION = 'USB Security Software - Advanced USB/HDD Protection'
COMPANY_NAME = 'Security Solutions'

# Paths
SCRIPT_DIR = os.path.dirname(os.path.abspath(SPEC))
MAIN_SCRIPT = os.path.join(SCRIPT_DIR, 'main.py')
CONFIG_DIR = os.path.join(SCRIPT_DIR, 'config')
ASSETS_DIR = os.path.join(SCRIPT_DIR, 'assets')

# Data files to include
datas = []

# Include config directory
if os.path.exists(CONFIG_DIR):
    datas.append((CONFIG_DIR, 'config'))

# Include assets directory
if os.path.exists(ASSETS_DIR):
    datas.append((ASSETS_DIR, 'assets'))

# Include additional data files
additional_files = [
    'README.md',
    'requirements.txt',
    'LICENSE.txt'
]

for file in additional_files:
    file_path = os.path.join(SCRIPT_DIR, file)
    if os.path.exists(file_path):
        datas.append((file_path, '.'))

# Hidden imports - modules that PyInstaller might miss
hiddenimports = [
    # Windows-specific modules
    'win32api',
    'win32con',
    'win32event',
    'win32evtlog',
    'win32file',
    'win32gui',
    'win32process',
    'win32security',
    'win32service',
    'win32serviceutil',
    'win32timezone',
    'pywintypes',
    'pythoncom',
    
    # WMI and system monitoring
    'wmi',
    'psutil',
    
    # PyQt5 modules
    'PyQt5.QtCore',
    'PyQt5.QtGui',
    'PyQt5.QtWidgets',
    'PyQt5.sip',
    
    # PIL/Pillow
    'PIL',
    'PIL.Image',
    'PIL.ImageDraw',
    'PIL.ImageFont',
    
    # Standard library modules that might be missed
    'socket',
    'threading',
    'json',
    'datetime',
    'logging',
    'os',
    'sys',
    'time',
]

# Collect additional PyQt5 data
try:
    from PyQt5 import QtCore
    pyqt5_datas = collect_data_files('PyQt5')
    datas.extend(pyqt5_datas)
except ImportError:
    pass

# Collect WMI data
try:
    wmi_datas = collect_data_files('wmi')
    datas.extend(wmi_datas)
except ImportError:
    pass

# Analysis configuration
a = Analysis(
    [MAIN_SCRIPT],
    pathex=[SCRIPT_DIR],
    binaries=[],
    datas=datas,
    hiddenimports=hiddenimports,
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[
        # Exclude unnecessary modules to reduce size
        'tkinter',
        'matplotlib',
        'numpy',
        'scipy',
        'pandas',
        'jupyter',
        'IPython',
        'notebook',
        'tornado',
        'zmq',
        'sqlite3',
        'unittest',
        'doctest',
        'pdb',
        'profile',
        'pstats',
        'cProfile',
    ],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=None,
    noarchive=False,
)

# Remove duplicate entries
pyz = PYZ(a.pure, a.zipped_data, cipher=None)

# Executable configuration
exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.zipfiles,
    a.datas,
    [],
    name=APP_NAME,
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,  # Enable UPX compression to reduce file size
    upx_exclude=[],
    runtime_tmpdir=None,
    console=False,  # No console window
    disable_windowed_traceback=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    # Windows-specific options
    version='build/version_info.py' if os.path.exists('build/version_info.py') else None,
    icon='assets/app_icon.ico' if os.path.exists('assets/app_icon.ico') else None,
    # Manifest for Windows
    manifest='''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
  <assemblyIdentity
    version="1.0.0.0"
    processorArchitecture="*"
    name="USB_Security"
    type="win32"
  />
  <description>USB Security Software - Advanced USB/HDD Protection</description>
  <trustInfo xmlns="urn:schemas-microsoft-com:asm.v3">
    <security>
      <requestedPrivileges>
        <requestedExecutionLevel level="requireAdministrator" uiAccess="false"/>
      </requestedPrivileges>
    </security>
  </trustInfo>
  <compatibility xmlns="urn:schemas-microsoft-com:compatibility.v1">
    <application>
      <!-- Windows 10 -->
      <supportedOS Id="{8e0f7a12-bfb3-4fe8-b9a5-48fd50a15a9a}"/>
      <!-- Windows 8.1 -->
      <supportedOS Id="{1f676c76-80e1-4239-95bb-83d0f6d0da78}"/>
      <!-- Windows 8 -->
      <supportedOS Id="{4a2f28e3-53b9-4441-ba9c-d69d4a4a6e38}"/>
      <!-- Windows 7 -->
      <supportedOS Id="{35138b9a-5d96-4fbd-8e2d-a2440225f93a}"/>
    </application>
  </compatibility>
</assembly>''',
)

# Collection configuration (for --onedir mode, if needed)
coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name=APP_NAME,
)
