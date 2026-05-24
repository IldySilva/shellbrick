#!/bin/bash
# Build a release tar.gz for Linux.
# Usage: ./scripts/build_linux.sh [version]
# Example: ./scripts/build_linux.sh 0.1.0

set -euo pipefail

VERSION="${1:-$(grep '^version:' pubspec.yaml | awk '{print $2}' | cut -d'+' -f1)}"
ARCHIVE_NAME="Xell-v${VERSION}-linux-x64.tar.gz"

echo "→ Building Xell $VERSION for Linux..."
flutter build linux --release

echo "→ Packaging..."
mkdir -p dist
cd build/linux/x64/release/bundle
tar -czf "$OLDPWD/dist/$ARCHIVE_NAME" .
cd "$OLDPWD"

echo "✓ dist/$ARCHIVE_NAME"
echo ""
echo "Install instructions for users:"
echo "  tar -xzf $ARCHIVE_NAME"
echo "  ./xell"
