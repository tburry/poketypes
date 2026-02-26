const sharp = require('sharp');
const fs = require('fs');
const path = require('path');

// sources live in assets/ directory
const ICON_SRC = 'assets/icon.png';
const FAVICON_SRC = 'assets/favicon.png';
const OUTPUT_DIR = './docs/images';

async function makeIcons(src, destDir, sizes, prefix = 'poketype') {
  if (!fs.existsSync(src)) {
    throw new Error(`source file not found: ${src}`);
  }
  if (!fs.existsSync(destDir)) fs.mkdirSync(destDir, { recursive: true });
  for (const size of sizes) {
    const out = path.join(destDir, `${prefix}-${size}.png`);
    await sharp(src).resize(size, size).toFile(out);
    console.log('created', out);
  }
}

(async () => {
  try {
    // create poketype-{size}.png files
    await makeIcons(ICON_SRC, OUTPUT_DIR, [512, 192, 180, 152, 167, 32, 16], 'poketype');
    if (fs.existsSync(FAVICON_SRC)) {
      // create favicon sizes
      await makeIcons(FAVICON_SRC, OUTPUT_DIR, [32, 16], 'favicon');
      console.log('favicon sizes created');
    } else {
      console.warn('favicon source not found, skipping');
    }
  } catch (e) {
    console.error('error generating icons', e);
    process.exit(1);
  }
})();
