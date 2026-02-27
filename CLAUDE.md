# Poketypes

Pokémon type matchup cheatsheet — a single-file PWA hosted on GitHub Pages.

## Keep name/description in sync

The app name and description appear in multiple places and must be kept consistent:

- `manifest.json` → `name`, `short_name`, `description` (source of truth)
- `package.json` → `description`
- `docs/index.html` → `<title>`, `<meta name="description">`, `<meta name="apple-mobile-web-app-title">`
- `docs/index.html` → inlined manifest data URI (updated by `scripts/screenshots.sh`)

When changing the name or description, update all of these locations.

## Manifest workflow

`manifest.json` uses relative URLs. The `scripts/screenshots.sh` script:

1. Generates screenshots with headless Firefox
2. Updates `manifest.json` with actual screenshot dimensions
3. Inlines the manifest into `docs/index.html` as a data URI, rewriting all URLs to absolute (`https://tburry.github.io/poketypes/...`)

Run `scripts/screenshots.sh` after any manifest change to keep the inlined version in sync.
