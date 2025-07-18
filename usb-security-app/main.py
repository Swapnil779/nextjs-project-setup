import sys
import os
import json
import threading
import time
from datetime import datetime
from PyQt5.QtWidgets import (QApplication, QSystemTrayIcon, QMenu, QAction, 
                            QMessageBox, QDialog, QVBoxLayout, QHBoxLayout,
                            QLabel, QPushButton, QListWidget, QTextEdit,
                            QCheckBox, QSpinBox, QGroupBox, QFormLayout)
from PyQt5.QtCore import Qt, QTimer, pyqtSignal, QObject
from PyQt5.QtGui import QIcon, QPixmap, QPainter, QColor

from device_monitor import DeviceMonitor
from security_overlay import SecurityOverlay, BlinkingOverlay

class USBSecurityApp(QObject):
    device_detected = pyqtSignal(str, dict)
    device_removed = pyqtSignal(str, dict)
    
    def __init__(self):
        super().__init__()
        self.app = QApplication(sys.argv)
        self.app.setQuitOnLastWindowClosed(False)
        
        # Initialize components
        self.device_monitor = DeviceMonitor(callback=self.handle_device_event)
        self.security_overlay = None
        self.overlay_active = False
        self.settings = self.load_settings()
        
        # Create system tray
        self.create_tray_icon()
        
        # Connect signals
        self.device_detected.connect(self.on_device_detected)
        self.device_removed.connect(self.on_device_removed)
        
        # Start monitoring
        self.device_monitor.start_monitoring()
        
    def load_settings(self):
        """Load application settings"""
        settings_path = os.path.join('config', 'settings.json')
        default_settings = {
            'lockout_duration': 15,  # minutes
            'enable_blinking': True,
            'enable_notifications': True,
            'auto_start': True,
            'whitelist': []
        }
        
        if os.path.exists(settings_path):
            try:
                with open(settings_path, 'r') as f:
                    settings = json.load(f)
                    # Merge with defaults
                    for key, value in default_settings.items():
                        if key not in settings:
                            settings[key] = value
                    return settings
            except:
                pass
                
        return default_settings
    
    def save_settings(self):
        """Save application settings"""
        settings_path = os.path.join('config', 'settings.json')
        os.makedirs('config', exist_ok=True)
        
        with open(settings_path, 'w') as f:
            json.dump(self.settings, f, indent=2)
    
    def create_tray_icon(self):
        """Create system tray icon and menu"""
        # Create a simple icon programmatically
        icon = self.create_app_icon()
        
        self.tray_icon = QSystemTrayIcon(icon, self.app)
        
        # Create context menu
        menu = QMenu()
        
        # Status action
        self.status_action = QAction("USB Security: Active", self.app)
        self.status_action.setEnabled(False)
        menu.addAction(self.status_action)
        
        menu.addSeparator()
        
        # Settings action
        settings_action = QAction("Settings", self.app)
        settings_action.triggered.connect(self.show_settings)
        menu.addAction(settings_action)
        
        # View logs action
        logs_action = QAction("View Security Logs", self.app)
        logs_action.triggered.connect(self.show_logs)
        menu.addAction(logs_action)
        
        # Device whitelist action
        whitelist_action = QAction("Manage Whitelist", self.app)
        whitelist_action.triggered.connect(self.show_whitelist)
        menu.addAction(whitelist_action)
        
        menu.addSeparator()
        
        # Test overlay action (for debugging)
        test_action = QAction("Test Security Overlay", self.app)
        test_action.triggered.connect(self.test_overlay)
        menu.addAction(test_action)
        
        menu.addSeparator()
        
        # Exit action
        exit_action = QAction("Exit", self.app)
        exit_action.triggered.connect(self.exit_application)
        menu.addAction(exit_action)
        
        self.tray_icon.setContextMenu(menu)
        self.tray_icon.show()
        
        # Show startup notification
        if self.settings.get('enable_notifications', True):
            self.tray_icon.showMessage(
                "USB Security Active",
                "USB/HDD protection is now monitoring your system.",
                QSystemTrayIcon.Information,
                3000
            )
    
    def create_app_icon(self):
        """Create application icon programmatically"""
        pixmap = QPixmap(32, 32)
        pixmap.fill(Qt.transparent)
        
        painter = QPainter(pixmap)
        painter.setRenderHint(QPainter.Antialiasing)
        
        # Draw shield shape
        painter.setBrush(QColor(0, 100, 200))
        painter.setPen(QColor(0, 50, 150))
        
        # Shield outline
        points = [
            (16, 2), (26, 8), (26, 20), (16, 30), (6, 20), (6, 8)
        ]
        from PyQt5.QtGui import QPolygon
        from PyQt5.QtCore import QPoint
        
        polygon = QPolygon([QPoint(x, y) for x, y in points])
        painter.drawPolygon(polygon)
        
        # Draw USB symbol
        painter.setBrush(QColor(255, 255, 255))
        painter.setPen(QColor(255, 255, 255))
        painter.drawRect(14, 12, 4, 8)
        painter.drawRect(12, 10, 8, 2)
        
        painter.end()
        
        return QIcon(pixmap)
    
    def handle_device_event(self, event_type, device_info):
        """Handle device events from monitor"""
        if event_type == 'device_connected':
            self.device_detected.emit(event_type, device_info)
        elif event_type == 'device_removed':
            self.device_removed.emit(event_type, device_info)
    
    def on_device_detected(self, event_type, device_info):
        """Handle unauthorized device detection"""
        if not self.overlay_active:
            self.show_security_overlay(device_info)
            
            if self.settings.get('enable_notifications', True):
                self.tray_icon.showMessage(
                    "Security Alert!",
                    f"Unauthorized device detected: {device_info.get('drive_letter', 'Unknown')}",
                    QSystemTrayIcon.Critical,
                    5000
                )
    
    def on_device_removed(self, event_type, device_info):
        """Handle device removal"""
        if self.overlay_active and self.security_overlay:
            # Check if any unauthorized devices are still connected
            connected_drives = self.device_monitor.get_connected_removable_drives()
            unauthorized_count = 0
            
            for drive in connected_drives:
                device_id = f"{drive['device']}_{drive.get('fstype', 'unknown')}"
                device_name = f"Drive {drive['device']}"
                if not self.device_monitor.is_device_whitelisted(device_id, device_name):
                    unauthorized_count += 1
            
            # If no unauthorized devices remain, close overlay
            if unauthorized_count == 0:
                self.close_security_overlay()
                
                if self.settings.get('enable_notifications', True):
                    self.tray_icon.showMessage(
                        "Security Restored",
                        "All unauthorized devices removed. System restored to normal.",
                        QSystemTrayIcon.Information,
                        3000
                    )
    
    def show_security_overlay(self, device_info):
        """Show the security overlay"""
        if self.overlay_active:
            return
            
        self.overlay_active = True
        duration = self.settings.get('lockout_duration', 15)
        
        if self.settings.get('enable_blinking', True):
            self.security_overlay = BlinkingOverlay(duration_minutes=duration)
        else:
            self.security_overlay = SecurityOverlay(duration_minutes=duration)
        
        self.security_overlay.overlay_closed.connect(self.on_overlay_closed)
        self.security_overlay.show()
        
        # Update tray status
        self.status_action.setText("USB Security: LOCKED")
    
    def close_security_overlay(self):
        """Close the security overlay"""
        if self.security_overlay:
            self.security_overlay.close()
    
    def on_overlay_closed(self):
        """Handle overlay closure"""
        self.overlay_active = False
        self.security_overlay = None
        self.status_action.setText("USB Security: Active")
    
    def test_overlay(self):
        """Test the security overlay (for debugging)"""
        test_device_info = {
            'drive_letter': 'X:',
            'detection_time': datetime.now().isoformat()
        }
        self.show_security_overlay(test_device_info)
    
    def show_settings(self):
        """Show settings dialog"""
        dialog = SettingsDialog(self.settings, self)
        if dialog.exec_() == QDialog.Accepted:
            self.settings = dialog.get_settings()
            self.save_settings()
    
    def show_logs(self):
        """Show security logs"""
        dialog = LogsDialog(self)
        dialog.exec_()
    
    def show_whitelist(self):
        """Show device whitelist management"""
        dialog = WhitelistDialog(self.device_monitor, self)
        dialog.exec_()
    
    def exit_application(self):
        """Exit the application"""
        self.device_monitor.stop_monitoring()
        if self.security_overlay:
            self.security_overlay.close()
        self.tray_icon.hide()
        self.app.quit()
    
    def run(self):
        """Run the application"""
        return self.app.exec_()

class SettingsDialog(QDialog):
    def __init__(self, settings, parent=None):
        super().__init__(parent)
        self.settings = settings.copy()
        self.init_ui()
    
    def init_ui(self):
        self.setWindowTitle("USB Security Settings")
        self.setFixedSize(400, 300)
        
        layout = QVBoxLayout()
        
        # General settings group
        general_group = QGroupBox("General Settings")
        general_layout = QFormLayout()
        
        # Lockout duration
        self.duration_spin = QSpinBox()
        self.duration_spin.setRange(1, 60)
        self.duration_spin.setValue(self.settings.get('lockout_duration', 15))
        self.duration_spin.setSuffix(" minutes")
        general_layout.addRow("Lockout Duration:", self.duration_spin)
        
        # Enable blinking
        self.blinking_check = QCheckBox()
        self.blinking_check.setChecked(self.settings.get('enable_blinking', True))
        general_layout.addRow("Enable Blinking Effect:", self.blinking_check)
        
        # Enable notifications
        self.notifications_check = QCheckBox()
        self.notifications_check.setChecked(self.settings.get('enable_notifications', True))
        general_layout.addRow("Enable Notifications:", self.notifications_check)
        
        # Auto start
        self.autostart_check = QCheckBox()
        self.autostart_check.setChecked(self.settings.get('auto_start', True))
        general_layout.addRow("Start with Windows:", self.autostart_check)
        
        general_group.setLayout(general_layout)
        layout.addWidget(general_group)
        
        # Buttons
        button_layout = QHBoxLayout()
        
        ok_button = QPushButton("OK")
        ok_button.clicked.connect(self.accept)
        
        cancel_button = QPushButton("Cancel")
        cancel_button.clicked.connect(self.reject)
        
        button_layout.addWidget(ok_button)
        button_layout.addWidget(cancel_button)
        
        layout.addLayout(button_layout)
        self.setLayout(layout)
    
    def get_settings(self):
        return {
            'lockout_duration': self.duration_spin.value(),
            'enable_blinking': self.blinking_check.isChecked(),
            'enable_notifications': self.notifications_check.isChecked(),
            'auto_start': self.autostart_check.isChecked(),
            'whitelist': self.settings.get('whitelist', [])
        }

class LogsDialog(QDialog):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.init_ui()
        self.load_logs()
    
    def init_ui(self):
        self.setWindowTitle("Security Logs")
        self.setFixedSize(600, 400)
        
        layout = QVBoxLayout()
        
        self.log_text = QTextEdit()
        self.log_text.setReadOnly(True)
        layout.addWidget(self.log_text)
        
        # Buttons
        button_layout = QHBoxLayout()
        
        refresh_button = QPushButton("Refresh")
        refresh_button.clicked.connect(self.load_logs)
        
        clear_button = QPushButton("Clear Logs")
        clear_button.clicked.connect(self.clear_logs)
        
        close_button = QPushButton("Close")
        close_button.clicked.connect(self.accept)
        
        button_layout.addWidget(refresh_button)
        button_layout.addWidget(clear_button)
        button_layout.addWidget(close_button)
        
        layout.addLayout(button_layout)
        self.setLayout(layout)
    
    def load_logs(self):
        log_file = os.path.join('config', 'security_log.json')
        if os.path.exists(log_file):
            try:
                with open(log_file, 'r') as f:
                    logs = json.load(f)
                
                log_text = ""
                for log in reversed(logs[-50:]):  # Show last 50 entries
                    timestamp = log.get('timestamp', 'Unknown')
                    event = log.get('event', 'Unknown')
                    device = log.get('device', {})
                    
                    log_text += f"[{timestamp}] {event}\n"
                    log_text += f"  Device: {device.get('drive_letter', 'Unknown')}\n"
                    log_text += f"  Type: {device.get('fstype', 'Unknown')}\n"
                    log_text += "-" * 50 + "\n"
                
                self.log_text.setPlainText(log_text)
            except:
                self.log_text.setPlainText("Error loading logs.")
        else:
            self.log_text.setPlainText("No logs found.")
    
    def clear_logs(self):
        log_file = os.path.join('config', 'security_log.json')
        if os.path.exists(log_file):
            os.remove(log_file)
        self.log_text.setPlainText("Logs cleared.")

class WhitelistDialog(QDialog):
    def __init__(self, device_monitor, parent=None):
        super().__init__(parent)
        self.device_monitor = device_monitor
        self.init_ui()
        self.load_whitelist()
    
    def init_ui(self):
        self.setWindowTitle("Device Whitelist Management")
        self.setFixedSize(500, 400)
        
        layout = QVBoxLayout()
        
        # Instructions
        info_label = QLabel("Whitelisted devices will not trigger security alerts.")
        layout.addWidget(info_label)
        
        # Whitelist display
        self.whitelist_widget = QListWidget()
        layout.addWidget(self.whitelist_widget)
        
        # Buttons
        button_layout = QHBoxLayout()
        
        add_button = QPushButton("Add Current Devices")
        add_button.clicked.connect(self.add_current_devices)
        
        remove_button = QPushButton("Remove Selected")
        remove_button.clicked.connect(self.remove_selected)
        
        close_button = QPushButton("Close")
        close_button.clicked.connect(self.accept)
        
        button_layout.addWidget(add_button)
        button_layout.addWidget(remove_button)
        button_layout.addWidget(close_button)
        
        layout.addLayout(button_layout)
        self.setLayout(layout)
    
    def load_whitelist(self):
        self.whitelist_widget.clear()
        for device in self.device_monitor.whitelist:
            item_text = f"{device.get('name', 'Unknown')} ({device.get('id', 'Unknown')})"
            self.whitelist_widget.addItem(item_text)
    
    def add_current_devices(self):
        drives = self.device_monitor.get_connected_removable_drives()
        for drive in drives:
            device_id = f"{drive['device']}_{drive.get('fstype', 'unknown')}"
            device_name = f"Drive {drive['device']}"
            
            if not self.device_monitor.is_device_whitelisted(device_id, device_name):
                self.device_monitor.add_to_whitelist(device_id, device_name)
        
        self.load_whitelist()
        QMessageBox.information(self, "Success", f"Added {len(drives)} devices to whitelist.")
    
    def remove_selected(self):
        current_row = self.whitelist_widget.currentRow()
        if current_row >= 0:
            del self.device_monitor.whitelist[current_row]
            self.device_monitor.save_whitelist()
            self.load_whitelist()

def main():
    # Ensure single instance
    import socket
    try:
        # Try to bind to a port to ensure single instance
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        sock.bind(('localhost', 12345))
    except socket.error:
        print("USB Security is already running!")
        return 1
    
    try:
        app = USBSecurityApp()
        return app.run()
    except Exception as e:
        print(f"Error starting application: {e}")
        return 1
    finally:
        try:
            sock.close()
        except:
            pass

if __name__ == "__main__":
    sys.exit(main())
