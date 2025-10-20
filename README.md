# ComfyUI Quick Install

[![Shell Script](https://img.shields.io/badge/Shell_Script-✓-green.svg)](https://www.gnu.org/software/bash/)
[![Python 3.12](https://img.shields.io/badge/Python-3.12-blue.svg)](https://www.python.org/)
[![Multi-Distro](https://img.shields.io/badge/Linux-Multi_Distro-orange.svg)](https://en.wikipedia.org/wiki/Linux)
[![Systemd Service](https://img.shields.io/badge/Systemd-Service-red.svg)](https://systemd.io/)

**One-command automated installation script for ComfyUI** with isolated Python environment and automatic service setup. Supports multiple Linux distributions.

## 🚀 Features

- **⚡ Single Command Setup** - Complete installation with one script
- **🐧 Multi-Distribution** - Supports Debian, Ubuntu, Arch, Fedora, openSUSE, and more
- **🔒 Isolated Python 3.12** - Custom compiled Python, no system conflicts
- **🎯 Automatic Service** - Systemd service for production use
- **📦 Comfy-CLI** - Official ComfyUI package management
- **🧹 Auto Cleanup** - Removes temporary files after installation
- **👤 No Root Required** - Runs as regular user (except for dependencies)

## 📋 Quick Start

### Method 1: Direct Download & Run
```bash
# Download and execute in one command
curl -sSL https://raw.githubusercontent.com/EigenFunction32/comfyui-quick-install/main/install.sh | bash
```

### Method 2: Download & Run Locally
```bash
# Download the script
curl -O https://raw.githubusercontent.com/EigenFunction32/comfyui-quick-install/main/install.sh

# Make executable and run
chmod +x install.sh
./install.sh
```

### Method 3: Clone Repository
```bash
git clone https://github.com/EigenFunction32/comfyui-quick-install.git
cd comfyui-quick-install
chmod +x install.sh
./install.sh
```

## 🐧 Supported Distributions

### ✅ Fully Tested & Supported
- **Debian** 11/12
- **Ubuntu** 20.04, 22.04, 24.04
- **Linux Mint** 20+, 21+
- **Pop!\_OS** 22.04+

### ✅ Community Supported
- **Arch Linux** & **Manjaro**
- **Fedora** 38+
- **CentOS** / **RHEL** 9+
- **openSUSE** Tumbleweed & Leap

### ⚠️ Limited Support
- **Alpine Linux** (no systemd, uses startup script)
- **Other distributions** (manual dependency installation may be needed)

## ⚡ What Gets Installed

The script automatically performs these steps:

1. **🔍 Detects your Linux distribution**
2. **📦 Installs build dependencies** (compiler, libraries, dev tools)
3. **🐍 Downloads & compiles Python 3.12.3** in `~/.local/python3.12.3/`
4. **🛠️ Sets up pipx environment** for isolated package management
5. **🎨 Installs comfy-cli** - the official ComfyUI manager
6. **🚀 Downloads ComfyUI** in `~/comfy/ComfyUI/`
7. **⚙️ Creates systemd service** for automatic startup (if available)
8. **🧹 Cleans up temporary files**

## 🔧 Usage

### Manual Start (Testing & Development)
```bash
comfy launch
```

### Service Management (Production)
```bash
# Start the service
sudo systemctl start comfyui

# Enable auto-start on boot
sudo systemctl enable comfyui

# Check service status
systemctl status comfyui

# View real-time logs
journalctl -u comfyui -f

# Restart service (after updates)
sudo systemctl restart comfyui

# Stop service
sudo systemctl stop comfyui
```

### Non-systemd Systems (Alpine, etc.)
```bash
# Use the provided startup script
~/start-comfyui.sh
```

## 🌐 Access

Once running, access ComfyUI at:
**http://localhost:8188**

## 📁 Project Structure

After installation:
```
~/.local/python3.12.3/          # Custom Python installation
~/comfy/ComfyUI/               # ComfyUI installation
~/.local/bin/comfy             # comfy-cli executable
/etc/systemd/system/comfyui.service  # Systemd service (if available)
~/start-comfyui.sh             # Startup script (non-systemd systems)
```

## 🔄 Updates & Maintenance

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

### Check Installation
```bash
# Verify Python installation
~/.local/python3.12.3/bin/python3.12 --version

# Verify ComfyUI CLI
comfy --version

# Check if service is running
systemctl is-active comfyui
```

## 🐛 Troubleshooting

### "comfy command not found"
```bash
# Reload shell configuration
source ~/.bashrc

# Or simply restart your terminal
```

### Service Fails to Start
```bash
# Check service status and logs
sudo systemctl status comfyui
journalctl -u comfyui -n 50

# Verify ComfyUI installation
ls ~/comfy/ComfyUI/

# Check permissions
sudo chown -R $USER:$USER ~/.local/python3.12.3 ~/comfy
```

### Distribution Not Supported
```bash
# Manual dependency installation for unsupported distros
# Install these packages equivalent to:
# - build-essential / base-devel
# - libssl-dev, zlib-dev, libbz2-dev, libffi-dev
# - libreadline-dev, libsqlite3-dev, curl, git
```

### Complete Reinstall
```bash
# Remove existing installation
rm -rf ~/.local/python3.12.3 ~/comfy
sudo systemctl stop comfyui 2>/dev/null || true
sudo systemctl disable comfyui 2>/dev/null || true
sudo rm -f /etc/systemd/system/comfyui.service
sudo systemctl daemon-reload

# Run fresh installation
./install.sh
```

## ❓ Frequently Asked Questions

### Q: Why compile Python instead of using system Python?
**A:** Isolated Python ensures compatibility, avoids conflicts with system packages, and provides a consistent environment across different distributions.

### Q: Can I change the port?
**A:** Yes! Edit the service file:
```bash
sudo systemctl edit comfyui
# Change ExecStart to: ExecStart=/home/username/.local/bin/comfy launch --port 8080
sudo systemctl restart comfyui
```

### Q: Where are models stored?
**A:** Models are in `~/comfy/ComfyUI/models/`. Use ComfyUI Manager (web interface) to download models easily.

### Q: How to run multiple instances?
**A:** Create separate service files with different ports and working directories.

### Q: Is internet required during installation?
**A:** Yes, for downloading Python source, dependencies, and ComfyUI components.

## 🛡️ Security Notes

- Runs as your regular user, not root
- Isolated Python environment prevents system conflicts
- Systemd service includes proper user isolation
- No unnecessary privileges required

## 📊 Performance Notes

- **Compilation time:** 5-15 minutes (depending on CPU)
- **Disk space:** ~2GB for Python + ~1GB for ComfyUI
- **Memory:** Service limited to 6GB by default (adjustable)
- **Network:** Requires internet for initial installation

## 🤝 Contributing

Found an issue? Want to add support for another distribution?

1. Fork the repository
2. Test on your target distribution
3. Submit a pull request
4. Update the compatibility matrix

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**Happy Generating!** 🎨

*Installation typically takes 10-20 minutes depending on your system speed and internet connection.*
