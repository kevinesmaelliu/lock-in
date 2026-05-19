#!/usr/bin/env bash
# Build Lock In (ProgressBar) and package LockIn.dmg for distribution.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

SCHEME="ProgressBar"
PROJECT="ProgressBar.xcodeproj"
DISPLAY_NAME="Lock In"
DMG_FILENAME="LockIn.dmg"
DERIVED_DATA="${DERIVED_DATA:-$ROOT_DIR/build/DerivedData}"
STAGING_DIR="${STAGING_DIR:-$ROOT_DIR/build/staging}"
DIST_DIR="${DIST_DIR:-$ROOT_DIR/build/dist}"

rm -rf "$STAGING_DIR" "$DIST_DIR"
mkdir -p "$STAGING_DIR" "$DIST_DIR"

VERSION="${VERSION:-}"
if [[ -z "$VERSION" && -n "${GITHUB_REF_NAME:-}" ]]; then
	VERSION="$GITHUB_REF_NAME"
fi
VERSION="${VERSION#v}"
VERSION_ARGS=()
if [[ -n "$VERSION" ]]; then
	echo "Building version $VERSION"
	VERSION_ARGS=(
		MARKETING_VERSION="$VERSION"
		CURRENT_PROJECT_VERSION="${BUILD_NUMBER:-1}"
	)
fi

SIGN_IDENTITY="${APPLE_SIGNING_IDENTITY:-}"
if [[ -n "${APPLE_TEAM_ID:-}" ]]; then
	CODE_SIGN_ARGS=(
		DEVELOPMENT_TEAM="$APPLE_TEAM_ID"
		CODE_SIGN_STYLE=Manual
		CODE_SIGN_IDENTITY="$SIGN_IDENTITY"
		OTHER_CODE_SIGN_FLAGS="--entitlements $ROOT_DIR/Release/entitlements.plist"
	)
elif [[ -n "$SIGN_IDENTITY" ]]; then
	CODE_SIGN_ARGS=(
		CODE_SIGN_STYLE=Manual
		CODE_SIGN_IDENTITY="$SIGN_IDENTITY"
		OTHER_CODE_SIGN_FLAGS="--entitlements $ROOT_DIR/Release/entitlements.plist"
	)
else
	echo "No signing certificate configured; using ad-hoc signature (users must bypass Gatekeeper)."
	CODE_SIGN_ARGS=(
		CODE_SIGN_IDENTITY="-"
		CODE_SIGNING_ALLOWED=YES
		DEVELOPMENT_TEAM=""
	)
fi

xcodebuild \
	-project "$PROJECT" \
	-scheme "$SCHEME" \
	-configuration Release \
	-derivedDataPath "$DERIVED_DATA" \
	ONLY_ACTIVE_ARCH=NO \
	"${VERSION_ARGS[@]}" \
	"${CODE_SIGN_ARGS[@]}" \
	build

APP_PATH="$(find "$DERIVED_DATA" -path "*/Build/Products/Release/ProgressBar.app" -type d | head -1)"
if [[ -z "$APP_PATH" || ! -d "$APP_PATH" ]]; then
	echo "Could not find ProgressBar.app in DerivedData" >&2
	exit 1
fi

STAGED_APP="$STAGING_DIR/$DISPLAY_NAME.app"
ditto "$APP_PATH" "$STAGED_APP"

if [[ -n "$SIGN_IDENTITY" && "$SIGN_IDENTITY" != "-" ]]; then
	echo "Signing $DISPLAY_NAME.app with hardened runtime..."
	codesign --force --options runtime --entitlements "$ROOT_DIR/Release/entitlements.plist" --sign "$SIGN_IDENTITY" "$STAGED_APP"
	codesign --verify --verbose "$STAGED_APP"
fi

DMG_PATH="$DIST_DIR/$DMG_FILENAME"
if command -v create-dmg >/dev/null 2>&1; then
	create-dmg \
		--volname "$DISPLAY_NAME" \
		--window-pos 200 120 \
		--window-size 600 400 \
		--icon-size 100 \
		--app-drop-link 400 185 \
		--no-internet-enable \
		"$DMG_PATH" \
		"$STAGED_APP"
else
	echo "create-dmg not found; using hdiutil"
	TEMP_DMG="$DIST_DIR/temp.dmg"
	hdiutil create -volname "$DISPLAY_NAME" -srcfolder "$STAGED_APP" -ov -format UDZO "$TEMP_DMG"
	mv "$TEMP_DMG" "$DMG_PATH"
fi

if [[ -n "${APPLE_ID:-}" && -n "$SIGN_IDENTITY" && "$SIGN_IDENTITY" != "-" ]]; then
	echo "Notarizing $DMG_FILENAME..."
	NOTARY_ARGS=(submit "$DMG_PATH" --wait)
	if [[ -n "${APP_STORE_CONNECT_API_KEY_ID:-}" ]]; then
		KEY_PATH="$RUNNER_TEMP/notary-key.p8"
		echo "${APP_STORE_CONNECT_API_KEY}" | base64 --decode >"$KEY_PATH"
		NOTARY_ARGS+=(
			--key "$KEY_PATH"
			--key-id "$APP_STORE_CONNECT_API_KEY_ID"
			--issuer "$APP_STORE_CONNECT_API_ISSUER_ID"
		)
	else
		NOTARY_ARGS+=(
			--apple-id "$APPLE_ID"
			--password "$APPLE_APP_SPECIFIC_PASSWORD"
			--team-id "$APPLE_TEAM_ID"
		)
	fi
	xcrun notarytool "${NOTARY_ARGS[@]}"
	xcrun stapler staple "$DMG_PATH"
	xcrun stapler validate "$DMG_PATH"
else
	echo "Skipping notarization (set Apple signing + notary secrets to enable)."
fi

echo "Release artifact: $DMG_PATH"
ls -lh "$DMG_PATH"
