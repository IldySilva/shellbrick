#!/bin/bash
# Xell installer
# Usage: curl -fsSL https://raw.githubusercontent.com/IldySilva/xell/master/install.sh | bash
# Or:    ./install.sh [--version v0.1.0]

set -euo pipefail

# ── Config ────────────────────────────────────────────────────────────────────
REPO="ildysilva/xell"   
APP_NAME="Xell"
BIN_NAME="xell"
INSTALL_VERSION=""     # empty = latest

# ── Args ──────────────────────────────────────────────────────────────────────
while [[ $# -gt 0 ]]; do
  case "$1" in
    --version) INSTALL_VERSION="$2"; shift 2 ;;
    --help|-h)
      echo "Usage: install.sh [--version v0.1.0]"
      exit 0 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# ── Helpers ───────────────────────────────────────────────────────────────────
info() { printf "  %s\n" "$*"; }
ok()   { printf "\033[32m✓\033[0m %s\n" "$*"; }
warn() { printf "\033[33m!\033[0m %s\n" "$*"; }
die()  { printf "\033[31m✗\033[0m %s\n" "$*" >&2; exit 1; }

need() {
  command -v "$1" &>/dev/null || die "Required tool not found: $1. Install it and retry."
}

# ── Platform detection ────────────────────────────────────────────────────────
OS="$(uname -s)"
ARCH="$(uname -m)"

case "$OS" in
  Darwin) PLATFORM="macos" ;;
  Linux)  PLATFORM="linux" ;;
  *)      die "Unsupported OS: $OS. Install manually from https://github.com/$REPO/releases" ;;
esac

need curl

if [[ "$PLATFORM" == "macos" ]]; then
  need hdiutil
fi

# ── Fetch release metadata ────────────────────────────────────────────────────
if [[ -n "$INSTALL_VERSION" ]]; then
  API_URL="https://api.github.com/repos/$REPO/releases/tags/$INSTALL_VERSION"
else
  API_URL="https://api.github.com/repos/$REPO/releases/latest"
fi

info "Checking latest release..."
RELEASE_JSON="$(curl -fsSL "$API_URL" 2>/dev/null)" \
  || die "Could not reach GitHub API. Check your internet connection."

VERSION="$(printf '%s' "$RELEASE_JSON" | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"\([^"]*\)".*/\1/')"
[[ -n "$VERSION" ]] || die "No release found. Check https://github.com/$REPO/releases"

# ── Resolve download URL ──────────────────────────────────────────────────────
case "$PLATFORM" in
  macos)
    ASSET_PATTERN="macos.dmg"
    ;;
  linux)
    case "$ARCH" in
      x86_64)        ASSET_PATTERN="linux-x64.tar.gz" ;;
      aarch64|arm64) ASSET_PATTERN="linux-arm64.tar.gz" ;;
      *)             die "Unsupported architecture: $ARCH" ;;
    esac
    ;;
esac

DOWNLOAD_URL="$(printf '%s' "$RELEASE_JSON" \
  | grep '"browser_download_url"' \
  | grep "$ASSET_PATTERN" \
  | head -1 \
  | sed 's/.*"browser_download_url": *"\([^"]*\)".*/\1/')"

[[ -n "$DOWNLOAD_URL" ]] \
  || die "No $PLATFORM build in release $VERSION. Check https://github.com/$REPO/releases"

# ── Download ──────────────────────────────────────────────────────────────────
echo ""
echo "Installing $APP_NAME $VERSION on $OS ($ARCH)"
echo ""

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

DOWNLOAD_FILE="$TMP_DIR/$(basename "$DOWNLOAD_URL")"

info "Downloading from GitHub Releases..."
curl -fSL --progress-bar "$DOWNLOAD_URL" -o "$DOWNLOAD_FILE"

# ── Install: macOS ────────────────────────────────────────────────────────────
if [[ "$PLATFORM" == "macos" ]]; then
  INSTALL_DIR="/Applications"
  DEST="$INSTALL_DIR/$APP_NAME.app"

  info "Mounting DMG..."
  MOUNT_OUTPUT="$(hdiutil attach "$DOWNLOAD_FILE" -nobrowse -quiet)"
  MOUNT_POINT="$(echo "$MOUNT_OUTPUT" | awk '{print $NF}' | tail -1)"

  APP_SRC="$(find "$MOUNT_POINT" -maxdepth 1 -name "*.app" | head -1)"
  [[ -n "$APP_SRC" ]] || { hdiutil detach "$MOUNT_POINT" -quiet 2>/dev/null; die "Could not find .app inside DMG"; }

  info "Installing to $DEST..."
  [[ -d "$DEST" ]] && rm -rf "$DEST"
  cp -R "$APP_SRC" "$INSTALL_DIR/"

  hdiutil detach "$MOUNT_POINT" -quiet

  # Strip quarantine so macOS doesn't block unsigned builds
  if xattr -l "$DEST" 2>/dev/null | grep -q "com.apple.quarantine"; then
    xattr -dr com.apple.quarantine "$DEST"
  fi

  echo ""
  ok "$APP_NAME $VERSION installed to $DEST"
  info "Launch it from Applications or run: open -a $APP_NAME"
fi

# ── Install: Linux ────────────────────────────────────────────────────────────
if [[ "$PLATFORM" == "linux" ]]; then
  BUNDLE_DIR="$HOME/.local/share/$BIN_NAME"
  BIN_DIR="$HOME/.local/bin"
  BIN_LINK="$BIN_DIR/$BIN_NAME"
  DESKTOP_DIR="$HOME/.local/share/applications"
  ICON_DIR="$HOME/.local/share/icons/hicolor/256x256/apps"

  # Check libsecret (required for secure credential storage)
  if ! { ldconfig -p 2>/dev/null | grep -q "libsecret-1" || \
         find /usr/lib /usr/lib64 /usr/local/lib /lib 2>/dev/null \
              -name "libsecret-1.so*" | grep -q .; }; then
    warn "libsecret-1 not detected — credential storage may not work."
    echo "    Install it before launching Xell:"
    echo "      Ubuntu/Debian:  sudo apt install libsecret-1-0"
    echo "      Fedora:         sudo dnf install libsecret"
    echo "      Arch:           sudo pacman -S libsecret"
    echo ""
  fi

  info "Extracting bundle..."
  rm -rf "$BUNDLE_DIR"
  mkdir -p "$BUNDLE_DIR" "$BIN_DIR" "$DESKTOP_DIR" "$ICON_DIR"
  tar -xzf "$DOWNLOAD_FILE" -C "$BUNDLE_DIR"

  # The Flutter Linux bundle has the binary at the root of the extracted dir.
  # Try the canonical name first, then any executable (handles legacy builds
  # where the binary was still named after the old project name).
  BINARY="$(find "$BUNDLE_DIR" -maxdepth 1 -name "$BIN_NAME" -type f | head -1)"
  if [[ -z "$BINARY" ]]; then
    BINARY="$(find "$BUNDLE_DIR" -maxdepth 1 -type f -executable \
              ! -name "*.so" ! -name "*.so.*" | head -1)"
  fi
  [[ -n "$BINARY" ]] || die "Could not find the application binary in the bundle. Please report this at https://github.com/$REPO/issues"
  chmod +x "$BINARY"

  info "Linking to $BIN_LINK..."
  ln -sf "$BINARY" "$BIN_LINK"

  # Install icon if bundled
  ICON_SRC="$(find "$BUNDLE_DIR" -name "$BIN_NAME.png" 2>/dev/null | head -1)"
  if [[ -n "$ICON_SRC" ]]; then
    cp "$ICON_SRC" "$ICON_DIR/$BIN_NAME.png"
    ICON_VALUE="$BIN_NAME"
  else
    ICON_VALUE="utilities-terminal"
  fi

  # Create .desktop entry so the app appears in GNOME / KDE / app launchers
  info "Creating desktop entry..."
  cat > "$DESKTOP_DIR/$BIN_NAME.desktop" <<EOF
[Desktop Entry]
Name=Xell
Comment=Open-source SSH workspace
Exec=$BINARY
Icon=$ICON_VALUE
Terminal=false
Type=Application
Categories=Network;RemoteAccess;System;
StartupNotify=true
EOF
  chmod +x "$DESKTOP_DIR/$BIN_NAME.desktop"

  # Refresh desktop and icon databases
  command -v update-desktop-database &>/dev/null \
    && update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
  command -v gtk-update-icon-cache &>/dev/null \
    && gtk-update-icon-cache -f -t "$HOME/.local/share/icons/hicolor" 2>/dev/null || true

  echo ""
  ok "$APP_NAME $VERSION installed"
  ok "Appears in your app launcher"

  # PATH hint if ~/.local/bin is not in PATH
  if ! echo ":$PATH:" | grep -q ":$BIN_DIR:"; then
    echo ""
    warn "~/.local/bin is not in your PATH. To also launch from terminal:"
    echo "    Add this to ~/.bashrc or ~/.zshrc:"
    echo ""
    echo "      export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo ""
  else
    ok "Launch from terminal: $BIN_NAME"
  fi
fi
