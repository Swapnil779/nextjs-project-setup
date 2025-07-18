#!/usr/bin/env python3
"""
Create virus warning logo for USB Security Software
This script creates a simple warning logo using PIL (Pillow)
"""

import os
from PIL import Image, ImageDraw, ImageFont

def create_virus_logo():
    """Create a virus warning logo"""
    # Create image with transparent background
    size = (200, 200)
    img = Image.new('RGBA', size, (255, 255, 255, 0))
    draw = ImageDraw.Draw(img)
    
    # Colors
    red = (255, 0, 0, 255)
    dark_red = (180, 0, 0, 255)
    white = (255, 255, 255, 255)
    black = (0, 0, 0, 255)
    
    # Draw warning triangle background
    triangle_points = [
        (100, 20),   # Top
        (180, 160),  # Bottom right
        (20, 160)    # Bottom left
    ]
    draw.polygon(triangle_points, fill=red, outline=dark_red, width=3)
    
    # Draw exclamation mark
    # Vertical line
    draw.rectangle([90, 50, 110, 120], fill=white)
    # Dot
    draw.ellipse([85, 130, 115, 160], fill=white)
    
    # Add border
    draw.rectangle([0, 0, size[0]-1, size[1]-1], outline=red, width=2)
    
    return img

def create_shield_icon():
    """Create a shield icon for system tray"""
    size = (32, 32)
    img = Image.new('RGBA', size, (255, 255, 255, 0))
    draw = ImageDraw.Draw(img)
    
    # Colors
    blue = (0, 100, 200, 255)
    dark_blue = (0, 50, 150, 255)
    white = (255, 255, 255, 255)
    
    # Draw shield shape
    shield_points = [
        (16, 2),   # Top
        (26, 8),   # Top right
        (26, 20),  # Bottom right
        (16, 30),  # Bottom
        (6, 20),   # Bottom left
        (6, 8)     # Top left
    ]
    draw.polygon(shield_points, fill=blue, outline=dark_blue, width=1)
    
    # Draw USB symbol
    draw.rectangle([14, 12, 18, 20], fill=white)  # USB body
    draw.rectangle([12, 10, 20, 12], fill=white)  # USB connector
    draw.rectangle([11, 8, 13, 10], fill=white)   # Left prong
    draw.rectangle([19, 8, 21, 10], fill=white)   # Right prong
    
    return img

def main():
    """Create all logo files"""
    print("Creating logo files...")
    
    # Create assets directory
    os.makedirs('assets', exist_ok=True)
    
    try:
        # Create virus warning logo
        virus_logo = create_virus_logo()
        virus_logo.save('assets/virus_logo.png')
        print("✓ Created virus_logo.png")
        
        # Create shield icon
        shield_icon = create_shield_icon()
        shield_icon.save('assets/shield_icon.png')
        print("✓ Created shield_icon.png")
        
        # Create ICO file for Windows
        shield_icon.save('assets/app_icon.ico')
        print("✓ Created app_icon.ico")
        
        print("\nLogo files created successfully!")
        print("Files created in 'assets' folder:")
        print("- virus_logo.png (200x200) - Warning logo for security overlay")
        print("- shield_icon.png (32x32) - System tray icon")
        print("- app_icon.ico - Windows application icon")
        
    except ImportError:
        print("Error: PIL (Pillow) is required to create logo files.")
        print("Install with: pip install pillow")
        print("\nAlternatively, you can use the text-based logos in the application.")
        
    except Exception as e:
        print(f"Error creating logo files: {e}")

if __name__ == "__main__":
    main()
