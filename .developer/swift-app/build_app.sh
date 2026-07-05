#!/bin/zsh
set -euo pipefail

DEV_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REPO_ROOT="$(cd "$DEV_ROOT/.." && pwd)"
PACKAGE_ROOT="$DEV_ROOT/swift-app"

APP_NAME="Perseus Local Reader.app"
REPO_APP_PATH="$REPO_ROOT/$APP_NAME"
VERSION="$(tr -d '[:space:]' < "$REPO_ROOT/VERSION")"

if [[ -z "$VERSION" ]]; then
  echo "VERSION is empty."
  exit 1
fi

OUT_ROOT="${PERSEUS_BUILD_OUTPUT:-$HOME/LocalBuilds/PerseusLocalReader/$VERSION}"
CLEAN_APP="$OUT_ROOT/$APP_NAME"
ZIP_PATH="$OUT_ROOT/Perseus-Local-Reader-${VERSION}-macOS-universal.zip"

BUILD_ROOT="$(
  /usr/bin/mktemp -d \
    "${TMPDIR:-/tmp}/perseus-local-reader-build.XXXXXX"
)"

trap '/bin/rm -rf "$BUILD_ROOT"' EXIT

ARM_BUILD="$BUILD_ROOT/swift-arm64"
INTEL_BUILD="$BUILD_ROOT/swift-x86_64"
UNIVERSAL_EXECUTABLE="$BUILD_ROOT/PerseusLocalReader"
STAGE_APP="$BUILD_ROOT/$APP_NAME"

echo "Building arm64 executable..."

/usr/bin/xcrun swift build \
  --package-path "$PACKAGE_ROOT" \
  --scratch-path "$ARM_BUILD" \
  --arch arm64 \
  --jobs 1 \
  -c release

echo "Building x86_64 executable..."

/usr/bin/xcrun swift build \
  --package-path "$PACKAGE_ROOT" \
  --scratch-path "$INTEL_BUILD" \
  --arch x86_64 \
  --jobs 1 \
  -c release

ARM_EXECUTABLE="$(
  /usr/bin/find "$ARM_BUILD" \
    -type f \
    -path '*/release/PerseusLocalReader' \
    ! -path '*.dSYM/*' \
    -print \
    | /usr/bin/head -n 1
)"

INTEL_EXECUTABLE="$(
  /usr/bin/find "$INTEL_BUILD" \
    -type f \
    -path '*/release/PerseusLocalReader' \
    ! -path '*.dSYM/*' \
    -print \
    | /usr/bin/head -n 1
)"

if [[ -z "$ARM_EXECUTABLE" || ! -x "$ARM_EXECUTABLE" ]]; then
  echo "arm64 executable not found under: $ARM_BUILD"
  exit 1
fi

if [[ -z "$INTEL_EXECUTABLE" || ! -x "$INTEL_EXECUTABLE" ]]; then
  echo "x86_64 executable not found under: $INTEL_BUILD"
  exit 1
fi

ARM_ARCHS="$(/usr/bin/lipo -archs "$ARM_EXECUTABLE")"
INTEL_ARCHS="$(/usr/bin/lipo -archs "$INTEL_EXECUTABLE")"

if [[ "$ARM_ARCHS" != *"arm64"* ]]; then
  echo "Unexpected arm64 product: $ARM_ARCHS"
  exit 1
fi

if [[ "$INTEL_ARCHS" != *"x86_64"* ]]; then
  echo "Unexpected x86_64 product: $INTEL_ARCHS"
  exit 1
fi

/usr/bin/lipo \
  -create \
  "$ARM_EXECUTABLE" \
  "$INTEL_EXECUTABLE" \
  -output "$UNIVERSAL_EXECUTABLE"

/bin/chmod +x "$UNIVERSAL_EXECUTABLE"

UNIVERSAL_ARCHS="$(
  /usr/bin/lipo -archs "$UNIVERSAL_EXECUTABLE"
)"

if [[ "$UNIVERSAL_ARCHS" != *"arm64"* ||
      "$UNIVERSAL_ARCHS" != *"x86_64"* ]]; then
  echo "Universal binary verification failed: $UNIVERSAL_ARCHS"
  exit 1
fi

echo "Built universal executable: $UNIVERSAL_ARCHS"

mkdir -p \
  "$STAGE_APP/Contents/MacOS" \
  "$STAGE_APP/Contents/Resources"

cp \
  "$UNIVERSAL_EXECUTABLE" \
  "$STAGE_APP/Contents/MacOS/PerseusLocalReader"

ICON_SOURCE=""

for candidate in \
  "$PACKAGE_ROOT/Resources/AppIcon.icns" \
  "$REPO_ROOT/Open Perseus Local Reader.app/Contents/Resources/applet.icns" \
  "$REPO_ROOT/.developer/assets/apology-icon.icns"
do
  if [[ -f "$candidate" ]]; then
    ICON_SOURCE="$candidate"
    break
  fi
done

ICON_PLIST=""

if [[ -n "$ICON_SOURCE" ]]; then
  cp \
    "$ICON_SOURCE" \
    "$STAGE_APP/Contents/Resources/AppIcon.icns"

  ICON_PLIST="<key>CFBundleIconFile</key><string>AppIcon</string>"
fi

cat > "$STAGE_APP/Contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
  "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleDisplayName</key>
  <string>Perseus Local Reader</string>
  <key>CFBundleExecutable</key>
  <string>PerseusLocalReader</string>
  <key>CFBundleIdentifier</key>
  <string>jp.keio.sohma.perseus-local-reader</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>Perseus Local Reader</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>${VERSION}</string>
  <key>CFBundleVersion</key>
  <string>${VERSION}</string>
  ${ICON_PLIST}
  <key>LSMinimumSystemVersion</key>
  <string>13.0</string>
  <key>NSAppTransportSecurity</key>
  <dict>
    <key>NSAllowsLocalNetworking</key>
    <true/>
  </dict>
  <key>NSHighResolutionCapable</key>
  <true/>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
EOF

find "$STAGE_APP" \
  -name '._*' \
  -delete \
  2>/dev/null || true

/usr/bin/xattr -cr "$STAGE_APP"

/usr/bin/codesign \
  --force \
  --deep \
  --sign - \
  "$STAGE_APP"

/usr/bin/codesign \
  --verify \
  --deep \
  --strict \
  --verbose=2 \
  "$STAGE_APP"

rm -rf "$OUT_ROOT"
mkdir -p "$OUT_ROOT"

/usr/bin/ditto \
  --norsrc \
  --noextattr \
  --noqtn \
  "$STAGE_APP" \
  "$CLEAN_APP"

/usr/bin/codesign \
  --verify \
  --deep \
  --strict \
  --verbose=2 \
  "$CLEAN_APP"

CLEAN_ARCHS="$(
  /usr/bin/lipo -archs \
    "$CLEAN_APP/Contents/MacOS/PerseusLocalReader"
)"

if [[ "$CLEAN_ARCHS" != *"arm64"* ||
      "$CLEAN_ARCHS" != *"x86_64"* ]]; then
  echo "Clean app is not universal: $CLEAN_ARCHS"
  exit 1
fi

/usr/bin/ditto \
  -c \
  -k \
  --keepParent \
  --norsrc \
  --noextattr \
  --noqtn \
  "$CLEAN_APP" \
  "$ZIP_PATH"

TEST_ROOT="$BUILD_ROOT/zip-test"
mkdir -p "$TEST_ROOT"

/usr/bin/ditto \
  -x \
  -k \
  "$ZIP_PATH" \
  "$TEST_ROOT"

TEST_APP="$TEST_ROOT/$APP_NAME"

/usr/bin/codesign \
  --verify \
  --deep \
  --strict \
  --verbose=2 \
  "$TEST_APP"

TEST_ARCHS="$(
  /usr/bin/lipo -archs \
    "$TEST_APP/Contents/MacOS/PerseusLocalReader"
)"

if [[ "$TEST_ARCHS" != *"arm64"* ||
      "$TEST_ARCHS" != *"x86_64"* ]]; then
  echo "ZIP test app is not universal: $TEST_ARCHS"
  exit 1
fi

rm -rf "$REPO_APP_PATH"

/usr/bin/ditto \
  --norsrc \
  --noextattr \
  --noqtn \
  "$CLEAN_APP" \
  "$REPO_APP_PATH"

/usr/bin/xattr -cr "$REPO_APP_PATH" 2>/dev/null || true

echo ""
echo "Built application:"
echo "  $CLEAN_APP"
echo ""
echo "Built ZIP:"
echo "  $ZIP_PATH"
echo ""
echo "Architectures:"
echo "  $TEST_ARCHS"
echo ""
echo "SHA-256:"

/usr/bin/shasum \
  -a 256 \
  "$ZIP_PATH"
