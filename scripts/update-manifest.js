const fs = require('fs');
const path = require('path');

// Read the manifest JSON from project root
const manifestPath = path.join(__dirname, '../manifest.json');
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf-8'));

// Encode it for use in data URL
const encoded = encodeURIComponent(JSON.stringify(manifest));
const dataUrl = `data:application/json;charset=utf-8,${encoded}`;

// Read index.html
const indexPath = path.join(__dirname, '../docs/index.html');
let html = fs.readFileSync(indexPath, 'utf-8');

// Replace the manifest link
const newLink = `<link rel="manifest" href="${dataUrl}">`;
html = html.replace(
  /<link rel="manifest" href="data:application\/json[^"]*">/,
  newLink
);

// Write back to index.html
fs.writeFileSync(indexPath, html);
console.log('✓ Updated manifest in index.html');
console.log(`  Manifest size: ${encoded.length} characters`);
