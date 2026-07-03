#!/usr/bin/env bash
set -e

REPO="hefy2027/cf-manager"
RAW_URL="https://raw.githubusercontent.com/${REPO}/master/reg"
INSTALL_DIR="${CF_REG_INSTALL_DIR:-$HOME/.cf-reg}"
BIN_LINK="/usr/local/bin/cf-reg"
MIN_NODE_VERSION=20

echo "🌐 Cloudflare Batch Registration Tool - Installer"
echo "=================================================="
echo ""

# ── 检测 Node.js ────────────────────────────────────────
echo "[1/5] Checking Node.js..."

if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js >= ${MIN_NODE_VERSION}"
    echo "   Visit: https://nodejs.org"
    exit 1
fi

NODE_VERSION=$(node -e "console.log(process.version.split('.')[0].replace('v',''))")
if [ "$NODE_VERSION" -lt "$MIN_NODE_VERSION" ]; then
    echo "❌ Node.js v${NODE_VERSION} is too old. Requires >= v${MIN_NODE_VERSION}"
    echo "   Visit: https://nodejs.org"
    exit 1
fi

echo "✅ Node.js v$(node -v) detected"

# ── 检测 OS ─────────────────────────────────────────────
echo "[2/5] Detecting OS..."
OS="$(uname -s)"
echo "✅ OS: $OS"

# ── 检测/安装 npm ───────────────────────────────────────
echo "[3/5] Checking npm..."
if ! command -v npm &> /dev/null; then
    echo "❌ npm not found. Please reinstall Node.js (npm is included)"
    exit 1
fi
echo "✅ npm v$(npm -v) detected"

# ── 获取最新 release 下载地址 ────────────────────────────
echo "[4/5] Downloading cf-reg..."

mkdir -p "$INSTALL_DIR"

echo "   Downloading cf-reg.mjs..."
curl -fsSL "${RAW_URL}/cf-reg.mjs" -o "${INSTALL_DIR}/cf-reg.mjs"

# 创建 cf-reg 包装器（不依赖 shebang）
cat > "${INSTALL_DIR}/cf-reg" << EOF
#!/usr/bin/env bash
node "\$(dirname "\$0")/cf-reg.mjs" "\$@"
EOF
chmod +x "${INSTALL_DIR}/cf-reg"

# 下载 config.example.json
curl -fsSL "${RAW_URL}/config.example.json" -o "${INSTALL_DIR}/config.json"

echo "✅ Downloaded to ${INSTALL_DIR}"

# ── 安装依赖 ─────────────────────────────────────────────
echo "[5/5] Installing dependencies..."

cd "$INSTALL_DIR"
cat > package.json << EOF
{
  "name": "cf-reg-local",
  "version": "1.0.0",
  "type": "module"
}
EOF

npm install --no-save cloakbrowser commander node-fetch playwright-core &> /dev/null || {
    echo "⚠️  Failed to install some dependencies. You may need to run manually:"
    echo "   cd ${INSTALL_DIR} && npm install cloakbrowser commander node-fetch playwright-core"
}

echo "✅ Dependencies installed"

# ── 创建 symlink ─────────────────────────────────────────
if [ "$OS" = "Darwin" ] || [ "$OS" = "Linux" ]; then
    if [ -w "$(dirname $BIN_LINK)" ]; then
        ln -sf "${INSTALL_DIR}/cf-reg" "$BIN_LINK"
        echo "✅ Symlink created: $BIN_LINK"
    else
        echo "⚠️  To create symlink, run:"
        echo "    sudo ln -sf ${INSTALL_DIR}/cf-reg ${BIN_LINK}"
    fi
fi

# ── 添加到 PATH ──────────────────────────────────────────
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    SHELL_RC=""
    if [ -n "$ZSH_VERSION" ] || [ -f "$HOME/.zshrc" ]; then
        SHELL_RC="$HOME/.zshrc"
    elif [ -f "$HOME/.bashrc" ]; then
        SHELL_RC="$HOME/.bashrc"
    fi

    if [ -n "$SHELL_RC" ]; then
        echo "" >> "$SHELL_RC"
        echo "export PATH=\"\$PATH:${INSTALL_DIR}\"" >> "$SHELL_RC"
        echo "✅ Added to PATH in $SHELL_RC"
        echo "   (restart shell or run: source $SHELL_RC)"
    fi
fi

echo ""
echo "=================================================="
echo "  🎉 Installation complete!"
echo "=================================================="
echo ""
echo "Usage:"
echo "  cf-reg --help"
echo "  cf-reg --count 5"
echo ""
echo "Config:"
echo "  Edit ${INSTALL_DIR}/config.json to customize settings"
echo ""
echo "CF Manager: https://github.com/${REPO}"
echo ""
