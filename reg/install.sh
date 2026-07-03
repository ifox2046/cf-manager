#!/usr/bin/env bash
set -e

REPO="hefy2027/cf-manager"
RAW_URL="https://raw.githubusercontent.com/${REPO}/master/reg"
INSTALL_DIR="${CF_REG_INSTALL_DIR:-$PWD}"
MIN_NODE_VERSION=20

echo "🌐 Cloudflare Batch Registration Tool - Installer"
echo "=================================================="
echo ""

# ── 检测 Node.js ────────────────────────────────────────
echo "[1/4] Checking Node.js..."

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

# ── 检测 npm ─────────────────────────────────────────────
echo "[2/4] Checking npm..."
if ! command -v npm &> /dev/null; then
    echo "❌ npm not found. Please reinstall Node.js (npm is included)"
    exit 1
fi
echo "✅ npm v$(npm -v) detected"

# ── 下载 / 确认文件 ──────────────────────────────────────
echo "[3/4] Preparing files..."

mkdir -p "$INSTALL_DIR"

if [ ! -f "${INSTALL_DIR}/cf-reg.mjs" ]; then
    echo "   Downloading cf-reg.mjs..."
    curl -fsSL "${RAW_URL}/cf-reg.mjs" -o "${INSTALL_DIR}/cf-reg.mjs"
else
    echo "   cf-reg.mjs already exists, skip download"
fi

if [ ! -f "${INSTALL_DIR}/config.json" ]; then
    echo "   Downloading config.json..."
    curl -fsSL "${RAW_URL}/config.example.json" -o "${INSTALL_DIR}/config.json"
else
    echo "   config.json already exists, skip download"
fi

# 创建 cf-reg 包装器
cat > "${INSTALL_DIR}/cf-reg" << EOF
#!/usr/bin/env bash
node "${INSTALL_DIR}/cf-reg.mjs" "\$@"
EOF
chmod +x "${INSTALL_DIR}/cf-reg"

echo "✅ Files ready in ${INSTALL_DIR}"

# ── 安装依赖 ─────────────────────────────────────────────
echo "[4/4] Installing dependencies..."

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

echo ""
echo "=================================================="
echo "  🎉 Installation complete!"
echo "=================================================="
echo ""
echo "Usage:"
echo "  ./cf-reg --help"
echo "  ./cf-reg --count 5"
echo ""
echo "Or add to PATH for global access:"
echo "  export PATH=\"\$PATH:${INSTALL_DIR}\""
echo ""
echo "Config:"
echo "  Edit ${INSTALL_DIR}/config.json to customize settings"
echo ""
echo "CF Manager: https://github.com/${REPO}"
echo ""
