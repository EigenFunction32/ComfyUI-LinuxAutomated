#!/bin/bash
set -e

echo "🎯 ComfyUI Quick Install"
echo "========================"

# Variabili
PYTHON_VERSION="3.12.3"
PYTHON_DIR="$HOME/.local/python$PYTHON_VERSION"
COMFY_DIR="$HOME/comfy"

echo "1. Installing dependencies..."
sudo apt update
sudo apt install -y build-essential libssl-dev zlib1g-dev libbz2-dev \
    libreadline-dev libsqlite3-dev curl libffi-dev git

echo "2. Downloading Python $PYTHON_VERSION..."
cd /tmp
curl -O https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tgz
tar -xf Python-$PYTHON_VERSION.tgz
cd Python-$PYTHON_VERSION

echo "3. Compiling Python (5-10 minutes)..."
./configure --enable-optimizations --prefix=$PYTHON_DIR
make -j$(nproc)
make install

echo "4. Setting up environment..."
$PYTHON_DIR/bin/python3.12 -m pip install --upgrade pip
$PYTHON_DIR/bin/pip3 install pipx
$PYTHON_DIR/bin/pipx ensurepath

echo "5. Installing ComfyUI..."
$PYTHON_DIR/bin/pipx install comfy-cli --python $PYTHON_DIR/bin/python3.12
mkdir -p $COMFY_DIR
cd $COMFY_DIR
comfy install

echo "6. Creating systemd service..."
sudo tee /etc/systemd/system/comfyui.service > /dev/null << EOF
[Unit]
Description=ComfyUI Service
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$COMFY_DIR/ComfyUI
ExecStart=$HOME/.local/pipx/venvs/comfy-cli/bin/comfy launch
Restart=always
Environment=PATH=$PYTHON_DIR/bin:/usr/bin:/bin

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload

echo ""
echo "✅ Installation complete!"
echo ""
echo "Quick start:"
echo "  comfy launch          # Start manually"
echo "  sudo systemctl start comfyui    # Start as service"
echo "  sudo systemctl enable comfyui   # Enable auto-start"
echo ""
echo "Access: http://localhost:8188"
