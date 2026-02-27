#!/bin/bash
set -e

FIREFOX="/Applications/Firefox.app/Contents/MacOS/firefox"
PROFILE="/tmp/ff-headless-profile"
DIR="$(cd "$(dirname "$0")/../docs/images/screenshots" && pwd)"
URL="file://$(cd "$(dirname "$0")/../docs" && pwd)/index.html"

mkdir -p "$PROFILE" "$DIR"

echo "Generating narrow screenshot (430x932 -> 1290x2796 @3x)..."
"$FIREFOX" --headless --screenshot "$DIR/narrow.png" --window-size=430,932 \
  --profile "$PROFILE" "$URL"

echo "Generating wide screenshot (1280x800 -> 2560x1600 @2x)..."
"$FIREFOX" --headless --screenshot "$DIR/wide.png" --window-size=1280,800 \
  --profile "$PROFILE" "$URL"

echo "Done. Screenshots saved to $DIR"
