const fs = require('fs');
const path = require('path');

// Read package.json to get the deployment URL
const pkgPath = path.join(__dirname, '../package.json');
const pkg = JSON.parse(fs.readFileSync(pkgPath, 'utf-8'));
const baseUrl = pkg.homepage || 'http://localhost:8000/';

// Read the manifest JSON from project root
const manifestPath = path.join(__dirname, '../manifest.json');
let manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf-8'));

// Fix relative paths to be absolute based on deployment URL
manifest.scope = manifest.scope.startsWith('http') ? manifest.scope : new URL(manifest.scope, baseUrl).href;
manifest.start_url = manifest.start_url.startsWith('http') ? manifest.start_url : new URL(manifest.start_url, baseUrl).href;
manifest.icons = manifest.icons.map(icon => ({
  ...icon,
  src: icon.src.startsWith('http') ? icon.src : new URL(icon.src, baseUrl).href
}));

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
console.log(`  Base URL: ${baseUrl}`);
console.log(`  Manifest size: ${encoded.length} characters`);
