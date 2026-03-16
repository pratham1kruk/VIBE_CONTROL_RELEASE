#!/usr/bin/env bash
# ============================================================
#  VBC — VIBE Control  |  Linux Binary Installer
#  Created by Pratham Kumar Uikey — github.com/pratham1kruk
#
#  Installs the compiled vbc binary — no source code exposed,
#  no Node.js required on the target machine.
#
#  Usage:
#    bash vbc-install.sh
#    bash vbc-install.sh --uninstall
#    bash vbc-install.sh --update
# ============================================================

set -e

VBC_VERSION="1.0.0"
VBC_AUTHOR="Pratham Kumar Uikey"
VBC_GITHUB="https://github.com/pratham1kruk"
VBC_INSTALL_DIR="$HOME/.vbc-cli"
VBC_BIN_LINK="/usr/local/bin/vbc"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BINARY_SRC="$SCRIPT_DIR/vbc-linux-x64-v${VBC_VERSION}"

# ── Colors ───────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; RESET='\033[0m'

ok()      { echo -e "  ${GREEN}✔${RESET}  $1"; }
info()    { echo -e "  ${CYAN}→${RESET}  $1"; }
warn()    { echo -e "  ${YELLOW}⚠${RESET}  $1"; }
err()     { echo -e "  ${RED}✖${RESET}  $1"; exit 1; }

print_banner() {
  echo ""
  echo -e "${BOLD}${CYAN}"
  echo "  ██╗   ██╗██████╗  ██████╗ "
  echo "  ██║   ██║██╔══██╗██╔════╝ "
  echo "  ██║   ██║██████╔╝██║      "
  echo "  ╚██╗ ██╔╝██╔══██╗██║      "
  echo "   ╚████╔╝ ██████╔╝╚██████╗ "
  echo "    ╚═══╝  ╚═════╝  ╚═════╝ "
  echo -e "${RESET}"
  echo -e "  ${BOLD}VIBE Control${RESET}  ${DIM}v${VBC_VERSION}${RESET}"
  echo -e "  ${DIM}Created by ${VBC_AUTHOR}  —  ${VBC_GITHUB}${RESET}"
  echo ""
}

check_binary() {
  if [ ! -f "$BINARY_SRC" ]; then
    err "Binary not found: vbc-linux-x64-v${VBC_VERSION}"
    echo -e "  Make sure this installer is in the same folder as the binary."
    exit 1
  fi
}

add_to_path() {
  local EXPORT_LINE="export PATH=\"\$PATH:$VBC_INSTALL_DIR\""
  local RC_FILE=""
  local SHELL_NAME
  SHELL_NAME=$(basename "$SHELL")

  case "$SHELL_NAME" in
    bash) RC_FILE="$HOME/.bashrc" ;;
    zsh)  RC_FILE="$HOME/.zshrc"  ;;
    fish)
      RC_FILE="$HOME/.config/fish/config.fish"
      EXPORT_LINE="set -gx PATH \$PATH $VBC_INSTALL_DIR"
      ;;
    *)    RC_FILE="$HOME/.profile" ;;
  esac

  grep -q "$VBC_INSTALL_DIR" "$RC_FILE" 2>/dev/null && {
    ok "PATH already set in $RC_FILE"
    return
  }

  echo "" >> "$RC_FILE"
  echo "# VBC — VIBE Control" >> "$RC_FILE"
  echo "$EXPORT_LINE" >> "$RC_FILE"
  ok "Added to PATH in $RC_FILE"
  warn "Run: source $RC_FILE  (or open a new terminal)"
}

do_install() {
  print_banner
  echo -e "${BOLD}  Installing VBC${RESET}"
  echo -e "${DIM}  ────────────────────────────────────────${RESET}"
  echo ""

  check_binary

  # Create install dir and copy binary
  info "Installing to $VBC_INSTALL_DIR"
  mkdir -p "$VBC_INSTALL_DIR"
  cp "$BINARY_SRC" "$VBC_INSTALL_DIR/vbc"
  chmod +x "$VBC_INSTALL_DIR/vbc"
  ok "Binary installed"

  # Also install VS Code extension files if present
  if [ -d "$SCRIPT_DIR/vbc-extension" ]; then
    cp -r "$SCRIPT_DIR/vbc-extension"        "$VBC_INSTALL_DIR/"
    cp -f "$SCRIPT_DIR/install-extension.sh" "$VBC_INSTALL_DIR/" 2>/dev/null || true
    ok "VS Code extension files installed"
  fi

  # Symlink to /usr/local/bin
  local LINK_OK=false
  if [ -w "/usr/local/bin" ]; then
    ln -sf "$VBC_INSTALL_DIR/vbc" "$VBC_BIN_LINK"
    LINK_OK=true
    ok "Symlink: $VBC_BIN_LINK → $VBC_INSTALL_DIR/vbc"
  else
    sudo ln -sf "$VBC_INSTALL_DIR/vbc" "$VBC_BIN_LINK" 2>/dev/null && {
      LINK_OK=true
      ok "Symlink: $VBC_BIN_LINK (via sudo)"
    } || true
  fi

  [ "$LINK_OK" = false ] && {
    warn "Could not write to /usr/local/bin — adding to PATH via shell profile."
    add_to_path
  }

  # Write metadata
  cat > "$VBC_INSTALL_DIR/.vbc-meta" << METAEOF
VBC_VERSION=${VBC_VERSION}
VBC_AUTHOR=${VBC_AUTHOR}
VBC_GITHUB=${VBC_GITHUB}
INSTALL_DATE=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
INSTALL_DIR=${VBC_INSTALL_DIR}
METAEOF

  echo ""
  echo -e "  ${GREEN}${BOLD}✔  VBC v${VBC_VERSION} installed${RESET}"
  echo ""
  echo -e "  Open a new terminal and run:  ${CYAN}${BOLD}vbc help${RESET}"
  echo ""
  echo -e "  ${DIM}${VBC_AUTHOR}  —  ${VBC_GITHUB}${RESET}"
  echo ""
}

do_update() {
  print_banner
  echo -e "${BOLD}  Updating VBC${RESET}"
  echo -e "${DIM}  ────────────────────────────────────────${RESET}"
  echo ""

  check_binary

  [ ! -d "$VBC_INSTALL_DIR" ] && { warn "Not installed. Running fresh install..."; do_install; return; }

  cp "$BINARY_SRC" "$VBC_INSTALL_DIR/vbc"
  chmod +x "$VBC_INSTALL_DIR/vbc"
  ok "Binary updated"

  [ -L "$VBC_BIN_LINK" ] && {
    if [ -w "/usr/local/bin" ]; then
      ln -sf "$VBC_INSTALL_DIR/vbc" "$VBC_BIN_LINK"
    else
      sudo ln -sf "$VBC_INSTALL_DIR/vbc" "$VBC_BIN_LINK" 2>/dev/null || true
    fi
    ok "Symlink refreshed"
  }

  echo ""
  ok "VBC updated to v${VBC_VERSION}"
  echo ""
}

do_uninstall() {
  print_banner
  echo -e "${BOLD}  Uninstalling VBC${RESET}"
  echo -e "${DIM}  ────────────────────────────────────────${RESET}"
  echo ""
  echo -e "  This will remove:"
  echo -e "  ${DIM}  $VBC_INSTALL_DIR${RESET}"
  echo -e "  ${DIM}  $VBC_BIN_LINK${RESET}"
  echo ""
  read -r -p "  Are you sure? (y/N) " CONFIRM
  case "$CONFIRM" in [yY]*) ;; *) echo "  Cancelled."; exit 0 ;; esac

  [ -d "$VBC_INSTALL_DIR" ] && rm -rf "$VBC_INSTALL_DIR" && ok "Removed $VBC_INSTALL_DIR"

  if [ -L "$VBC_BIN_LINK" ]; then
    if [ -w "/usr/local/bin" ]; then
      rm -f "$VBC_BIN_LINK"
    else
      sudo rm -f "$VBC_BIN_LINK" 2>/dev/null || true
    fi
    ok "Removed $VBC_BIN_LINK"
  fi

  for RC in "$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.zshrc" "$HOME/.profile" "$HOME/.config/fish/config.fish"; do
    [ -f "$RC" ] && grep -q "vbc-cli" "$RC" 2>/dev/null && {
      sed -i '/# VBC/d; /vbc-cli/d' "$RC" 2>/dev/null || \
      sed -i '' '/# VBC/d; /vbc-cli/d' "$RC" 2>/dev/null || true
      ok "Cleaned $RC"
    }
  done

  echo ""
  ok "VBC uninstalled."
  echo -e "  ${DIM}Thank you for using VBC — ${VBC_AUTHOR}${RESET}"
  echo ""
}

case "${1:-}" in
  --uninstall|-u) do_uninstall ;;
  --update|-U)    do_update    ;;
  --help|-h)
    echo ""
    echo -e "  ${BOLD}VBC Linux Installer  v${VBC_VERSION}${RESET}"
    echo -e "  ${DIM}${VBC_AUTHOR}  —  ${VBC_GITHUB}${RESET}"
    echo ""
    echo "  bash vbc-install.sh             Install"
    echo "  bash vbc-install.sh --update    Update"
    echo "  bash vbc-install.sh --uninstall Remove"
    echo ""
    ;;
  "") do_install ;;
  *)  err "Unknown option: $1. Use --help." ;;
esac
