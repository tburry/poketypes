#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT="$SCRIPT_DIR/.."
FIREFOX="/Applications/Firefox.app/Contents/MacOS/firefox"
PROFILE="/tmp/ff-headless-profile"
IMG_DIR="$ROOT/docs/images/screenshots"
HTML="$ROOT/docs/index.html"
MANIFEST="$ROOT/manifest.json"
URL="file://$ROOT/docs/index.html"
BASE_URL="https://tburry.github.io/poketypes"

mkdir -p "$PROFILE" "$IMG_DIR"

# Generate screenshots
echo "Generating narrow screenshot (430x932)..."
"$FIREFOX" --headless --screenshot "$IMG_DIR/narrow.png" --window-size=430,932 \
  --profile "$PROFILE" "$URL"

echo "Generating wide screenshot (1280x800)..."
"$FIREFOX" --headless --screenshot "$IMG_DIR/wide.png" --window-size=1280,800 \
  --profile "$PROFILE" "$URL"

# Read actual dimensions
NARROW_SIZE=$(sips -g pixelWidth -g pixelHeight "$IMG_DIR/narrow.png" | awk '/pixelWidth/{w=$2} /pixelHeight/{h=$2} END{print w"x"h}')
WIDE_SIZE=$(sips -g pixelWidth -g pixelHeight "$IMG_DIR/wide.png" | awk '/pixelWidth/{w=$2} /pixelHeight/{h=$2} END{print w"x"h}')

echo "Narrow: $NARROW_SIZE, Wide: $WIDE_SIZE"

# Update manifest.json sizes
python3 -c "
import json, sys
with open('$MANIFEST') as f:
    m = json.load(f)
for s in m['screenshots']:
    if s['form_factor'] == 'narrow':
        s['sizes'] = '$NARROW_SIZE'
    elif s['form_factor'] == 'wide':
        s['sizes'] = '$WIDE_SIZE'
with open('$MANIFEST', 'w') as f:
    json.dump(m, f, indent=2, ensure_ascii=False)
    f.write('\n')
"

# Build inlined manifest with absolute URLs
INLINE_JSON=$(python3 -c "
import json, urllib.parse
with open('$MANIFEST') as f:
    m = json.load(f)
base = '$BASE_URL'
m['scope'] = base + '/'
m['start_url'] = base + '/'
for icon in m['icons']:
    icon['src'] = base + '/' + icon['src']
for s in m['screenshots']:
    s['src'] = base + '/' + s['src']
print(urllib.parse.quote(json.dumps(m, ensure_ascii=False, separators=(',', ':')), safe=''))
")

# Update the inlined manifest in index.html
python3 -c "
import re
with open('$HTML') as f:
    html = f.read()
html = re.sub(
    r'href=\"data:application/json;charset=utf-8,[^\"]+\"',
    'href=\"data:application/json;charset=utf-8,$INLINE_JSON\"',
    html
)
with open('$HTML', 'w') as f:
    f.write(html)
"

echo "Done. Screenshots saved and manifest updated."
