#!/bin/bash
set -e

echo "🎯 ComfyUI Quick Install - Multi-Distribution"
echo "=============================================="

# Verifica che non sia eseguito come root
if [ "$(id -u)" -eq 0 ]; then
    echo "❌ Do not run as root or with sudo!"
    echo "   Simply run: ./install.sh"
    exit 1
fi

# Rileva distribuzione
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        OS_LIKE=$ID_LIKE
    else
        echo "❌ Cannot detect Linux distribution"
        exit 1
    fi
}

install_dependencies() {
    case $OS in
        debian|ubuntu|linuxmint)
            echo "📦 Installing dependencies for Debian-based system..."
            sudo apt update
            sudo apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
                libreadline-dev libsqlite3-dev curl libffi-dev git
            ;;
        arch|manjaro)
            echo "📦 Installing dependencies for Arch-based system..."
            sudo pacman -S --needed --noconfirm base-devel openssl zlib bzip2 readline sqlite curl libffi git
            ;;
        fedora|rhel|centos)
            if command -v dnf &> /dev/null; then
                echo "📦 Installing dependencies for Fedora/RHEL..."
                sudo dnf groupinstall -y "Development Tools"
                sudo dnf install -y openssl-devel zlib-devel bzip2-devel readline-devel sqlite-devel curl libffi-devel git
            else
                echo "📦 Installing dependencies for CentOS/RHEL (yum)..."
                sudo yum groupinstall -y "Development Tools"
                sudo yum install -y openssl-devel zlib-devel bzip2-devel readline-devel sqlite-devel curl libffi-devel git
            fi
            ;;
        opensuse|suse)
            echo "📦 Installing dependencies for openSUSE..."
            sudo zypper install -y -t pattern devel_basis
            sudo zypper install -y libopenssl-devel zlib-devel libbz2-devel readline-devel sqlite3-devel curl libffi-devel git
            ;;
        alpine)
            echo "📦 Installing dependencies for Alpine Linux..."
            sudo apk add build-base libffi-dev openssl-dev bzip2-dev zlib-dev readline-dev sqlite-dev curl git
            ;;
        *)
            echo "❌ Unsupported distribution: $OS"
            echo "   Please install build dependencies manually:"
            echo "   - build-essential / base-devel"
            echo "   - libssl-dev, zlib-dev, libbz2-dev, libffi-dev"
            echo "   - libreadline-dev, libsqlite3-dev, curl, git"
            exit 1
            ;;
    esac
}

# Variabili
PYTHON_VERSION="3.12.3"
PYTHON_DIR="$HOME/.local/python$PYTHON_VERSION"
COMFY_DIR="$HOME/comfy"
DOWNLOAD_DIR="$HOME/python-build"

# Rileva distribuzione
detect_distro
echo "🔍 Detected OS: $OS"

echo "1. Installing dependencies..."
install_dependencies

echo "2. Creating build directory..."
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

echo "3. Downloading Python $PYTHON_VERSION..."
if [ ! -f "Python-$PYTHON_VERSION.tgz" ]; then
    curl -f -O "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz"
fi

echo "4. Extracting Python..."
tar -xf "Python-$PYTHON_VERSION.tgz"
cd "Python-$PYTHON_VERSION"

echo "5. Compiling Python (5-15 minutes)..."
./configure --enable-optimizations --prefix="$PYTHON_DIR"
make -j$(nproc)
make install

echo "6. Setting up environment..."
"$PYTHON_DIR/bin/python3.12" -m pip install --upgrade pip
"$PYTHON_DIR/bin/pip3" install pipx
"$PYTHON_DIR/bin/pipx" ensurepath

# Aggiorna PATH per la sessione corrente
export PATH="$HOME/.local/bin:$PATH"

echo "7. Installing ComfyUI CLI..."
"$PYTHON_DIR/bin/pipx" install comfy-cli --python "$PYTHON_DIR/bin/python3.12"

# Forza l'aggiornamento del PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
[ -f ~/.zshrc ] && echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.bashrc

echo "8. Creating ComfyUI directory..."
mkdir -p "$COMFY_DIR"
cd "$COMFY_DIR"

echo "9. Installing ComfyUI (this may take a while)..."
comfy install

# Crea service systemd solo se systemd è disponibile
if command -v systemctl &> /dev/null && [ "$OS" != "alpine" ]; then
    echo "10. Creating systemd service..."
    sudo tee /etc/systemd/system/comfyui.service > /dev/null << EOF
[Unit]
Description=ComfyUI Service
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$COMFY_DIR/ComfyUI
ExecStart=$HOME/.local/bin/comfy launch
Restart=always
Environment=PATH=$PYTHON_DIR/bin:$HOME/.local/bin:/usr/bin:/bin

[Install]
WantedBy=multi-user.target
EOF

    sudo systemctl daemon-reload
    echo "   Systemd service created and enabled"
else
    echo "⚠️  Systemd not available, creating startup script instead..."
    # Crea script di avvio per sistemi senza systemd
    cat > ~/start-comfyui.sh << 'EOF'
#!/bin/bash
cd ~/comfy/ComfyUI
~/.local/bin/comfy launch
EOF
    chmod +x ~/start-comfyui.sh
    echo "   Startup script created: ~/start-comfyui.sh"
fi

# Pulizia
rm -rf "$DOWNLOAD_DIR"

echo ""
echo "✅ Installation complete!"
echo ""
echo "🔧 Quick commands:"
if command -v systemctl &> /dev/null && [ "$OS" != "alpine" ]; then
    echo "   sudo systemctl start comfyui     # Start as service"
    echo "   sudo systemctl enable comfyui    # Enable auto-start"
else
    echo "   ./start-comfyui.sh               # Start manually"
fi
echo "   comfy launch                     # Test manually"
echo ""
echo "🌐 Access: http://localhost:8188"
echo ""
echo "🔄 If you restart your terminal, run: source ~/.bashrc"
