#!/bin/bash
# Usage:
#   ./scripts/bump_version.sh              # patch bump: 1.14.0 → 1.14.1, build +1
#   ./scripts/bump_version.sh minor        # minor bump: 1.14.1 → 1.15.0, build +1
#   ./scripts/bump_version.sh major        # major bump: 1.15.0 → 2.0.0, build +1
#   ./scripts/bump_version.sh --build-only # build number +1 only, version unchanged
#
# After bump: commits, creates alpha tag, and optionally pushes.

set -e

cd "$(dirname "$0")/.."

PUBSPEC="pubspec.yaml"
BUMP_TYPE="${1:-patch}"

# Read current version
CURRENT=$(grep '^version:' "$PUBSPEC" | head -1 | sed 's/version: //')
VERSION="${CURRENT%%+*}"
BUILD="${CURRENT##*+}"

IFS='.' read -r MAJOR MINOR PATCH <<< "$VERSION"

# Bump version
case "$BUMP_TYPE" in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
  --build-only)
    ;;
  *)
    echo "Usage: $0 [patch|minor|major|--build-only]"
    exit 1
    ;;
esac

NEW_BUILD=$((BUILD + 1))
NEW_VERSION="$MAJOR.$MINOR.$PATCH"
NEW_FULL="$NEW_VERSION+$NEW_BUILD"
TAG="v$NEW_VERSION-alpha.1"

echo "Current: $CURRENT"
echo "New:     $NEW_FULL"
echo "Tag:     $TAG"
echo ""

# Update pubspec.yaml
sed -i '' "s/^version: .*/version: $NEW_FULL/" "$PUBSPEC"

# Commit and tag
git add "$PUBSPEC"
git commit -m "chore: bump version to $NEW_VERSION ($NEW_BUILD)"
git tag "$TAG"

echo ""
echo "Done! To push:"
echo "  git push origin main --tags"
