# ComfyUI Quick Install

[![Shell Script](https://img.shields.io/badge/Shell_Script-✓-green.svg)](https://www.gnu.org/software/bash/)
[![Python 3.12](https://img.shields.io/badge/Python-3.12-blue.svg)](https://www.python.org/)
[![Systemd Service](https://img.shields.io/badge/Systemd-Service-red.svg)](https://systemd.io/)

One-command automated installation script for ComfyUI with isolated Python environment and systemd service.

## 🚀 Features

- **Isolated Python 3.12** - Custom compiled Python installation
- **Single Command Setup** - Complete installation with one script
- **Systemd Service** - Production-ready service management
- **Comfy-CLI** - Official ComfyUI package management
- **No Root Required** - Runs as regular user (except for dependencies)
- **Auto Cleanup** - Removes temporary files after installation

## 📋 Prerequisites

- Ubuntu 20.04+ or Debian-based system
- 10GB+ free disk space
- Internet connection

## 🛠️ Quick Installation

### Method 1: Direct Download
```bash
# Download and run the installer
curl -O https://raw.githubusercontent.com/EigenFunction32/comfyui-quick-install/main/install.sh
chmod +x install.sh
./install.sh
```

### Method 2: Clone Repository
```bash
git clone https://github.com/EigenFunction32/comfyui-quick-install.git
cd comfyui-quick-install
chmod +x install.sh
./install.sh
```

## ⚡ What the Script Does

The installation script automatically performs these steps:

1. **Installs build dependencies** (compiler, libraries, tools)
2. **Downloads and compiles Python 3.12.3** in `~/.local/python3.12.3/`
3. **Sets up pipx environment** for package management
4. **Installs comfy-cli** - the official ComfyUI manager
5. **Downloads ComfyUI** in `~/comfy/ComfyUI/`
6. **Creates systemd service** for automatic startup
7. **Cleans up temporary files**

## 🔧 Usage

### Manual Start (Testing)
```bash
comfy launch
```

### Service Management (Production)
```bash
# Start the service
sudo systemctl start comfyui

# Enable auto-start on boot
sudo systemctl enable comfyui

# Check status
systemctl status comfyui

# View logs in real-time
journalctl -u comfyui -f

# Restart service
sudo systemctl restart comfyui

# Stop service
sudo systemctl stop comfyui
```

## 🌐 Access

Once running, access ComfyUI at:
**http://localhost:8188**

## 📁 Project Structure

After installation:
```
~/.local/python3.12.3/     # Custom Python installation
~/comfy/ComfyUI/          # ComfyUI installation
~/.local/bin/             # comfy-cli executable
/etc/systemd/system/comfyui.service  # Systemd service
```

## 🔄 Updates

### Update ComfyUI
```bash
# Update via comfy-cli
comfy update

# Or through web interface: Manager → Update All
```

### Update comfy-cli
```bash
pipx upgrade comfy-cli
```

## 🐛 Troubleshooting

### "comfy command not found"
```bash
# Reload shell configuration
source ~/.bashrc

# Or restart your terminal
```

### Service not starting
```bash
# Check service status
sudo systemctl status comfyui

# View detailed logs
journalctl -u comfyui -n 50

# Check if ComfyUI installed correctly
ls ~/comfy/ComfyUI/
```

### Permission Issues
```bash
# Fix ownership if needed
sudo chown -R $USER:$USER ~/.local/python3.12.3
sudo chown -R $USER:$USER ~/comfy
```

### Reinstall from Scratch
```bash
# Remove existing installation
rm -rf ~/.local/python3.12.3 ~/comfy
sudo systemctl stop comfyui
sudo systemctl disable comfyui
sudo rm /etc/systemd/system/comfyui.service
sudo systemctl daemon-reload

# Run installer again
./install.sh
```

## ❓ Frequently Asked Questions

### Q: Why compile Python instead of using system Python?
**A:** Isolated Python ensures compatibility and avoids conflicts with system packages.

### Q: Can I run multiple ComfyUI instances?
**A:** Yes, modify the service file to use different ports and directories.

### Q: How to change the port?
**A:** Edit the service file and change the port in ExecStart:
```bash
sudo systemctl edit comfyui
# Change to: ExecStart=/home/username/.local/bin/comfy launch --port 8080
```

### Q: Where are models stored?
**A:** Models are in `~/comfy/ComfyUI/models/` - use ComfyUI Manager to download them.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🤝 Contributing

Feel free to open issues or submit pull requests for improvements.

---

**Happy Generating!** 🎨

*Note: This installer is designed for simplicity and reliability. The entire process takes 10-20 minutes depending on your system speed.*
