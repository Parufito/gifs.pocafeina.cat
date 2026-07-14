# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Static image/GIF gallery with copy-to-clipboard, sharing, and category browsing. Written in Catalan. No frameworks — plain HTML/CSS/JS with a Bash build script. Deployed via GitHub Pages from the `master` branch.

## Build & Development

```bash
./build.sh        # Generates gallery.json from pics/ and gifs/ directories, updates tags.txt
```

There is no dev server — open `index.html` directly in a browser after building. The build must be run whenever media files are added/removed so `gallery.json` reflects the current contents.

## Architecture

**Build pipeline** (`build.sh`): Scans `pics/` and `gifs/` (one level of subdirectories = subcategories), generates `gallery.json` with categories and file metadata. Empty categories are omitted.

**Runtime** (`app.js`): Single-file vanilla JS app loaded as ES module. On page load, fetches `gallery.json` and renders a card grid. Key features:
- **Copy image**: Images are converted to PNG via canvas and copied as `image/png` clipboard items (GIFs and videos don't get this button — use copy-link or share instead)
- **Share**: Uses Web Share API with the file blob when available
- **Lightbox**: Custom implementation with keyboard (Escape/arrows) and touch swipe navigation
- **Categories**: Built dynamically from `gallery.json` category names; sidebar with hamburger toggle on mobile
- **Search**: Client-side filename filter across the currently-selected category

**Deployment** (`.github/workflows/`): On push to `master`, runs `build.sh` then deploys the entire repo root to GitHub Pages.

## Key Conventions

- Supported media extensions: `jpg`, `jpeg`, `png`, `webp`, `gif`, `mp4`
- Subdirectories under `pics/` or `gifs/` become subcategories (one level deep only)
- `gallery.json` is gitignored — it's a build artifact regenerated from the file tree
- UI language is Catalan throughout
