#!/bin/bash
# ============================================================
#  VBC — VIBE Control  |  macOS .pkg Builder
#  Created by Pratham Kumar Uikey
#  github.com/pratham1kruk
#
#  Run this on a macOS machine.
#  Required files in same folder:
#    vbc-macos-x64-v1.0.0     (or vbc-macos-arm64-v1.0.0 for Apple Silicon)
#    vbc-vibe-control-0.1.0.vsix
# ============================================================

set -e

PACKAGE_NAME="vbc"
VERSION="1.0.1"
ARCH="${1:-x64}"                          # pass arm64 as argument for Apple Silicon
BINARY_FILE="vbc-macos-${ARCH}-v${VERSION}"
VSIX_FILE="vbc-vibe-control-0.1.0.vsix"
BUILD_DIR="vbc-pkg-build"
SCRIPTS_DIR="vbc-pkg-scripts"
OUTPUT_PKG="vbc_${VERSION}_macos_${ARCH}.pkg"

# ── Colors ───────────────────────────────────────────────────
GREEN='\033[0;32m'; CYAN='\033[0;36m'; RED='\033[0;31m'; RESET='\033[0m'; BOLD='\033[1m'
ok()   { echo -e "  ${GREEN}✔${RESET}  $1"; }
info() { echo -e "  ${CYAN}→${RESET}  $1"; }
err()  { echo -e "  ${RED}✖${RESET}  $1"; exit 1; }

echo ""
echo -e "${BOLD}${CYAN}  VBC .pkg Builder  (macOS ${ARCH})${RESET}"
echo -e "  ────────────────────────────────────────"
echo ""

# ---------------------------------------------------------------
# Checks
# ---------------------------------------------------------------
info "Checking dependencies..."

if ! command -v pkgbuild >/dev/null 2>&1; then
    err "pkgbuild not found. Install Xcode Command Line Tools: xcode-select --install"
fi

if [ ! -f "$BINARY_FILE" ]; then
    err "Binary not found: $BINARY_FILE"$'\n'"  Place $BINARY_FILE next to this script and try again."$'\n'"  For Apple Silicon run: ./build-macos-pkg.sh arm64"
fi

if [ ! -f "$VSIX_FILE" ]; then
    err "VSIX not found: $VSIX_FILE"$'\n'"  Place $VSIX_FILE next to this script and try again."
fi

ok "All files found"

# ---------------------------------------------------------------
# Clean previous build
# ---------------------------------------------------------------
info "Cleaning previous build..."
rm -rf "$BUILD_DIR" "$SCRIPTS_DIR"
rm -f "$OUTPUT_PKG"

# ---------------------------------------------------------------
# Create payload structure
# (pkgbuild copies this tree into the target machine)
# ---------------------------------------------------------------
info "Creating payload structure..."

mkdir -p "$BUILD_DIR/usr/local/bin"
mkdir -p "$BUILD_DIR/opt/vbc"

# Binary → /usr/local/bin/vbc
cp "$BINARY_FILE" "$BUILD_DIR/usr/local/bin/vbc"
chmod 755 "$BUILD_DIR/usr/local/bin/vbc"
ok "Binary → /usr/local/bin/vbc"

# VSIX → /opt/vbc/
cp "$VSIX_FILE" "$BUILD_DIR/opt/vbc/"
ok "VSIX → /opt/vbc/$VSIX_FILE"

# Manual extension installer → /opt/vbc/
cat > "$BUILD_DIR/opt/vbc/install-extension.sh" <<'EOF'
#!/bin/bash
VSIX_PATH="/opt/vbc/vbc-vibe-control-0.1.0.vsix"

if command -v code >/dev/null 2>&1; then
    code --install-extension "$VSIX_PATH"
    echo "VBC extension installed. Restart VS Code to activate."
else
    echo "VS Code not found."
    echo "Install VS Code from: https://code.visualstudio.com"
    echo "Then re-run: /opt/vbc/install-extension.sh"
fi
EOF
chmod 755 "$BUILD_DIR/opt/vbc/install-extension.sh"

# ---------------------------------------------------------------
# Scripts — postinstall (runs after pkg installs)
# ---------------------------------------------------------------
mkdir -p "$SCRIPTS_DIR"

cat > "$SCRIPTS_DIR/postinstall" <<'EOF'
#!/bin/bash
set -e

echo ""
echo "  ██╗   ██╗██████╗  ██████╗ "
echo "  ██║   ██║██╔══██╗██╔════╝ "
echo "  ██║   ██║██████╔╝██║      "
echo "  ╚██╗ ██╔╝██╔══██╗██║      "
echo "   ╚████╔╝ ██████╔╝╚██████╗ "
echo "    ╚═══╝  ╚═════╝  ╚═════╝ "
echo ""
echo "  VBC — VIBE Control  v1.0.1"
echo "  github.com/pratham1kruk"
echo ""

VSIX_PATH="/opt/vbc/vbc-vibe-control-0.1.0.vsix"

# Install VS Code extension if code is on PATH
if command -v code >/dev/null 2>&1; then
    echo "  → Installing VS Code extension..."
    code --install-extension "$VSIX_PATH" && \
        echo "  ✔  VBC extension installed." || \
        echo "  ⚠  Run manually: code --install-extension $VSIX_PATH"
else
    echo "  ⚠  VS Code not found."
    echo "     Install from: https://code.visualstudio.com"
    echo "     Then run: /opt/vbc/install-extension.sh"
fi

echo ""
echo "  ✔  VBC installed. Open a new terminal and run:  vbc help"
echo ""
EOF
chmod 755 "$SCRIPTS_DIR/postinstall"

# preremove is not natively supported by macOS .pkg
# but we include a manual uninstall script inside the package
cat > "$BUILD_DIR/opt/vbc/uninstall.sh" <<'EOF'
#!/bin/bash
echo ""
echo "  → Uninstalling VBC..."

# Remove VS Code extension
if command -v code >/dev/null 2>&1; then
    code --uninstall-extension vbc.vbc-vibe-control 2>/dev/null && \
        echo "  ✔  VS Code extension removed." || \
        echo "  ⚠  Remove extension manually in VS Code."
fi

# Remove binary
sudo rm -f /usr/local/bin/vbc
echo "  ✔  Removed /usr/local/bin/vbc"

# Remove package files
sudo rm -rf /opt/vbc
echo "  ✔  Removed /opt/vbc"

# Forget the package so macOS doesn't think it's still installed
sudo pkgutil --forget com.pratham1kruk.vbc 2>/dev/null && \
    echo "  ✔  Package receipt removed." || true

echo ""
echo "  ✔  VBC uninstalled."
echo ""
EOF
chmod 755 "$BUILD_DIR/opt/vbc/uninstall.sh"

# ---------------------------------------------------------------
# Build .pkg
# ---------------------------------------------------------------
info "Building .pkg..."

pkgbuild \
    --root "$BUILD_DIR" \
    --scripts "$SCRIPTS_DIR" \
    --identifier "com.pratham1kruk.vbc" \
    --version "$VERSION" \
    --install-location "/" \
    "$OUTPUT_PKG"

echo ""
echo -e "  ${GREEN}${BOLD}✔  Done!${RESET}  ${CYAN}${OUTPUT_PKG}${RESET}"
echo ""
echo "  Install on any macOS machine:"
echo "    sudo installer -pkg $OUTPUT_PKG -target /"
echo ""
echo "  Or double-click the .pkg file in Finder."
echo ""
echo "  To uninstall later:"
echo "    sudo /opt/vbc/uninstall.sh"
echo ""
