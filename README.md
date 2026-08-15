# Core Network Documentation

A docs-as-code reference document covering the architecture and signaling
procedures of the mobile core network.

## Stack

| Concern            | Tool                                           |
|--------------------|------------------------------------------------|
| Source format      | AsciiDoc (`.adoc`)                             |
| PDF output         | `asciidoctor-pdf` (pure Ruby, no LaTeX needed) |
| HTML output        | `asciidoctor` (HTML5 backend)                  |
| Diagrams           | Kroki (Mermaid / Graphviz / D2 / packetdiag …) |
| Diagram server     | Docker Compose (local, private)                |

## 1. Install

### Debian/Ubuntu

```bash
# Ruby + AsciiDoc toolchain
sudo apt-get update
sudo apt-get install -y ruby-full build-essential
sudo gem install asciidoctor asciidoctor-pdf asciidoctor-diagram asciidoctor-kroki rouge

# Docker, for the local Kroki diagram server (skip if you already have Docker)
sudo apt-get install -y docker.io docker-compose-plugin
sudo usermod -aG docker "$USER"   # log out/in (or `newgrp docker`) for this to take effect
```

### Fedora

```bash
sudo dnf install -y ruby ruby-devel gcc make
sudo gem install asciidoctor asciidoctor-pdf asciidoctor-diagram asciidoctor-kroki rouge
sudo dnf install -y docker docker-compose
```

### macOS (Homebrew)

```bash
brew install ruby
gem install asciidoctor asciidoctor-pdf asciidoctor-diagram asciidoctor-kroki rouge
brew install --cask docker
```

Verify:

```bash
asciidoctor-pdf -v
```

## 2. Start the local diagram server

```bash
docker compose up -d
```

This starts Kroki on `http://localhost:8000`. `main.adoc` already points at
it via the `:kroki-server-url:` attribute.

**Don't want to install Docker right now?** Delete or comment out the
`:kroki-server-url:` line in `main.adoc` — Kroki's extension then falls back
to the public `https://kroki.io` service, so you can build immediately and
switch to local later. Only do this if the diagram content isn't sensitive.

## 3. Build

```bash
bash build.sh        # builds both PDF and HTML into output/, using the default theme
bash build.sh pdf     # PDF only
bash build.sh html    # HTML only
```

Or run the underlying commands directly:

```bash
asciidoctor-pdf -r asciidoctor-kroki -a pdf-theme=core-network-theme.yml -a pdf-themesdir=theme -a allow-uri-read -a cache-uri main.adoc -o output/core-network.pdf
asciidoctor    -r asciidoctor-kroki main.adoc -o output/core-network.html
```

`allow-uri-read` is required because diagrams are fetched as remote images
from the Kroki server; without it, `asciidoctor-pdf` silently prints the
diagram's alt text and URL instead of rendering it. `cache-uri` avoids
re-fetching unchanged diagrams on every rebuild (needs the optional
`open-uri-cached` gem — harmless if it isn't installed, just skips the
cache).

## 4. Choosing a theme

Six themes are available for both the PDF and HTML output. Pick one by
passing its name as the second argument to `build.sh`:

```bash
bash build.sh all corporate    # default: navy blue, serif body, shaded table headers
bash build.sh all slate        # blue-grey recolor of corporate
bash build.sh all forest       # dark green recolor of corporate
bash build.sh all editorial    # sans-serif, minimalist borderless tables, amber accent
bash build.sh all manuscript   # classic serif, ivory page, fully-ruled tables, burgundy accent
bash build.sh all terminal     # dark page, monospace headings, monokai code highlighting

bash build.sh pdf slate        # a single target also takes the theme argument
bash build.sh html forest
```

`corporate`, `slate`, and `forest` only change colors; layout, fonts, and
table style stay the same as the default. `editorial`, `manuscript`, and
`terminal` are style themes: each also changes the base font family
(sans-serif, serif, or monospace headings), the table structure (borderless,
fully-ruled, or row-ruled — via the `table-frame`/`table-grid`/`table-stripes`
document attributes, which `build.sh` sets per theme), and, for `terminal`,
the page background and syntax-highlighting palette (`rouge-style=monokai`).
`corporate` is used when no theme is given, so existing invocations of
`bash build.sh` are unaffected.

Note: the architecture and call-flow diagrams are pre-rendered SVGs with a
white background (`images/*.svg`, `diagrams/*.puml`), so on the `terminal`
theme's dark page they render inside a white panel. This is expected and not
a build issue.

To run the underlying commands directly with a non-default theme, override
`pdf-theme`, `docinfodir`, and (for the style themes) the table/rouge
attributes:

```bash
# PDF, "slate" theme
asciidoctor-pdf -r asciidoctor-kroki -a pdf-theme=core-network-theme-slate.yml -a pdf-themesdir=theme -a allow-uri-read -a cache-uri main.adoc -o output/core-network.pdf

# HTML, "forest" theme
asciidoctor -r asciidoctor-kroki -a data-uri -a docinfodir=theme/forest main.adoc -o output/core-network.html

# PDF, "terminal" theme (style themes also need the table/rouge attributes build.sh sets)
asciidoctor-pdf -r asciidoctor-kroki -a pdf-theme=core-network-theme-terminal.yml -a pdf-themesdir=theme -a allow-uri-read -a cache-uri -a table-frame=topbot -a table-grid=rows -a table-stripes=even -a rouge-style=monokai main.adoc -o output/core-network.pdf
```

### Adding a new theme

1. Add `theme/core-network-theme-<name>.yml` with `extends: core-network` and
   override the colors (and, for a style theme, `base.font-family`,
   `heading.font-family`, `page.background-color`, etc. — see
   `theme/core-network-theme-slate.yml` for a color-only example and
   `theme/core-network-theme-terminal.yml` for a style example). If you
   introduce a font not already in the catalog (only Noto Serif, Noto Sans,
   and M+ 1mn are bundled), add a `font.catalog` entry pointing at
   `GEM_FONTS_DIR/<file>.ttf` — see the top of
   `theme/core-network-theme-editorial.yml`.
2. Add `theme/<name>/docinfo.html`, copying `theme/docinfo.html` and
   replacing its color values (and font-family/background overrides, for a
   style theme) with the same palette (this file only affects the HTML
   backend — see `AGENTS.md` for why HTML and PDF colors are kept in two
   places). Keep the `#header > h1:first-child` and `#header .details`
   rules in sync too — the document title and byline need their own
   selector to win over asciidoctor's default stylesheet (see `AGENTS.md`).
3. Add a case for `<name>` in the `THEME` switch in `build.sh`, including
   `TABLE_FRAME`/`TABLE_GRID`/`TABLE_STRIPES`/`ROUGE_STYLE` if the theme
   changes table structure or code highlighting.
