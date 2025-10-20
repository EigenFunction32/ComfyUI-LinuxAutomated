#!/bin/bash
set -e

echo "🎯 ComfyUI Quick Install"
echo "========================"

# Verifica che non sia eseguito come root
if [ "$(id -u)" -eq 0 ]; then
    echo "❌ Non eseguire lo script come root o con sudo!"
    echo "   Esegui semplicemente: ./install.sh"
    exit 1
fi

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

# Aggiorna PATH per la sessione corrente
export PATH="$HOME/.local/bin:$PATH"

echo "5. Installing ComfyUI..."
$PYTHON_DIR/bin/pipx install comfy-cli --python $PYTHON_DIR/bin/python3.12

# Verifica che comfy sia disponibile
if ! command -v comfy &> /dev/null; then
    echo "❌ Comando 'comfy' non trovato, aggiungendo PATH manualmente..."
    export PATH="$HOME/.local/bin:$PATH"
fi

echo "6. Creating ComfyUI directory..."
mkdir -p $COMFY_DIR
cd $COMFY_DIR

echo "7. Installing ComfyUI (this may take a while)..."
comfy install

echo "8. Creating systemd service..."
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

echo ""
echo "✅ Installation complete!"
echo ""
echo "🔧 Next steps:"
echo "   source ~/.bashrc                 # Reload environment"
echo "   comfy launch                     # Test manually"
echo "   sudo systemctl start comfyui     # Start as service"
echo "   sudo systemctl enable comfyui    # Enable auto-start"
echo ""
echo "🌐 Access: http://localhost:8188"
echo ""
echo "📖 If 'comfy' command is not found, restart your terminal or run:"
echo "   export PATH=\"\$HOME/.local/bin:\$PATH\""
