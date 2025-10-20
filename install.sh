#!/bin/bash
set -e

echo "🎯 ComfyUI Quick Install"
echo "========================"

# Verifica che non sia eseguito come root
if [ "$(id -u)" -eq 0 ]; then
    echo "❌ Do not run as root or with sudo!"
    echo "   Simply run: ./install.sh"
    exit 1
fi

# Variabili
PYTHON_VERSION="3.12.3"
PYTHON_DIR="$HOME/.local/python$PYTHON_VERSION"
COMFY_DIR="$HOME/comfy"
DOWNLOAD_DIR="$HOME/python-build"

echo "1. Installing dependencies..."
sudo apt update
sudo apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev curl libffi-dev git

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
source ~/.bashrc

echo "8. Creating ComfyUI directory..."
mkdir -p "$COMFY_DIR"
cd "$COMFY_DIR"

echo "9. Installing ComfyUI (this may take a while)..."
comfy install

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

# Pulizia
rm -rf "$DOWNLOAD_DIR"

echo ""
echo "✅ Installation complete!"
echo ""
echo "🔧 Quick commands:"
echo "   comfy launch                     # Start manually"
echo "   sudo systemctl start comfyui     # Start as service"
echo "   sudo systemctl enable comfyui    # Enable auto-start"
echo ""
echo "🌐 Access: http://localhost:8188"
echo ""
echo "🔄 If you restart your terminal, run: source ~/.bashrc"
