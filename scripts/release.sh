#!/bin/bash
# Tag a new release and push it to trigger the GitHub Actions release workflow.
# Usage: ./scripts/release.sh <version>
# Example: ./scripts/release.sh 0.1.0

set -euo pipefail

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
  echo "Usage: $0 <version>  (e.g. 0.1.0)"
  exit 1
fi

TAG="v$VERSION"

# Update pubspec.yaml version
sed -i '' "s/^version: .*/version: $VERSION+1/" pubspec.yaml

# Confirm
echo "Releasing Xell $TAG"
echo ""
echo "  pubspec.yaml version → $VERSION+1"
echo "  git tag              → $TAG"
echo ""
read -rp "Proceed? [y/N] " confirm
[[ "$confirm" =~ ^[Yy]$ ]] || exit 0

# Commit, tag, push
git add pubspec.yaml
git commit -m "chore: release $TAG"
git tag "$TAG"
git push origin HEAD "$TAG"

echo ""
echo "✓ Pushed $TAG — GitHub Actions will build and publish the release."
echo "  https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]//' | sed 's/\.git$//')/releases/tag/$TAG"
