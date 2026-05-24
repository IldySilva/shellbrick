#!/bin/bash
# Build a release DMG for macOS.
# Usage: ./scripts/build_macos.sh [version]
# Example: ./scripts/build_macos.sh 0.1.0

set -euo pipefail

VERSION="${1:-$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f1)}"
DMG_NAME="Xell-v${VERSION}-macos.dmg"
APP_PATH="build/macos/Build/Products/Release/xell.app"

echo "→ Building Xell $VERSION for macOS..."
flutter build macos --release

echo "→ Creating DMG..."
mkdir -p dist

if ! command -v create-dmg &>/dev/null; then
  echo "  Installing create-dmg via Homebrew..."
  brew install create-dmg
fi

create-dmg \
  --volname "Xell" \
  --window-pos 200 120 \
  --window-size 600 380 \
  --icon-size 120 \
  --icon "xell.app" 150 185 \
  --hide-extension "xell.app" \
  --app-drop-link 450 185 \
  --no-internet-enable \
  "dist/$DMG_NAME" \
  "$APP_PATH"

echo "✓ dist/$DMG_NAME"

# If the app is unsigned, remind the user how to open it.
if ! codesign -v "$APP_PATH" &>/dev/null; then
  echo ""
  echo "Note: this build is unsigned. To open it on another Mac without an Apple"
  echo "Developer certificate, run:"
  echo "  xattr -dr com.apple.quarantine /path/to/Xell.app"
fi
