# Building the book

This page covers the toolchain, the build, the themes, and the publishing
workflow. For what the book is and where to read it, see the
[README](../README.md).

## Toolchain

| Concern        | Tool                                                        |
|----------------|-------------------------------------------------------------|
| Source format  | AsciiDoc (`.adoc`)                                          |
| PDF output     | `asciidoctor-pdf` (pure Ruby, no LaTeX needed)              |
| HTML output    | `asciidoctor` + `asciidoctor-multipage` (multi-page HTML5)  |
| Diagrams       | Kroki (PlantUML, packetdiag, …) through `asciidoctor-kroki` |
| Diagram server | Kroki in Docker Compose, on `http://localhost:8000`         |
| Search         | Pagefind (optional)                                         |

## 1. Install

### Debian/Ubuntu

```bash
sudo apt-get update
sudo apt-get install -y ruby-full build-essential docker.io docker-compose-plugin
sudo gem install asciidoctor asciidoctor-pdf asciidoctor-kroki asciidoctor-multipage rouge
sudo usermod -aG docker "$USER"   # log out and in again (or run `newgrp docker`)
```

### Fedora

```bash
sudo dnf install -y ruby ruby-devel gcc make docker docker-compose
sudo gem install asciidoctor asciidoctor-pdf asciidoctor-kroki asciidoctor-multipage rouge
```

### macOS (Homebrew)

```bash
brew install ruby
brew install --cask docker
gem install asciidoctor asciidoctor-pdf asciidoctor-kroki asciidoctor-multipage rouge
```

### Optional

- `gem install open-uri-cached` lets the PDF build cache diagrams between
  runs (`cache-uri`). Without it, every build fetches them again.
- [Pagefind](https://pagefind.app/) builds the search index for the HTML
  site. `build.sh` uses a `pagefind` binary, the `pagefind` Python package
  (`pip install 'pagefind[extended]'`), or `npx`, whichever it finds first,
  and skips the search index if none of them is available.

## 2. Start the diagram server

```bash
docker compose up -d
```

This starts Kroki on `http://localhost:8000`, which `main.adoc` references
through its `:kroki-server-url:` attribute.

If you don't want to run Docker, comment out the `:kroki-server-url:` line
in `main.adoc`. The Kroki extension then uses the public `https://kroki.io`
service instead.

## 3. Build

```bash
bash build.sh               # PDF and HTML, default theme
bash build.sh pdf           # PDF only  -> output/core-network.pdf
bash build.sh html          # HTML only -> output/html/main.html
bash build.sh all slate     # any target also takes a theme name
bash build.sh --help
```

`build.sh` is the source of truth for the exact `asciidoctor` and
`asciidoctor-pdf` options. Read it rather than copying commands from
elsewhere, because the HTML build also loads
`scripts/multipage-full-toc.rb` and then runs `scripts/postprocess-html.rb`
and Pagefind. Some attributes that matter:

- `allow-uri-read` is needed because the diagrams are fetched from the
  Kroki server. Without it, `asciidoctor-pdf` prints each diagram's alt
  text and URL instead of the diagram.
- For the HTML, `data-uri` together with `allow-uri-read` embeds every
  diagram in its page. Without them, the pages link to
  `http://localhost:8000/...`, and the diagrams break on any machine that
  doesn't run Kroki.
- `multipage-level=2` splits the HTML at level-2 sections, so each
  protocol or procedure gets its own page. If you change it, keep
  `:toclevels:` in `main.adoc` at or above the new value.

The entry page of the HTML site must be named `main.html`, because
`asciidoctor-multipage` takes the name from `main.adoc` and hard-codes it.
`bash build.sh all` also copies the PDF into `output/html/`, so the "PDF"
links work locally.

## 4. Themes

| Theme        | Style                                                                 |
|--------------|-----------------------------------------------------------------------|
| `zinc`       | Default. Zinc greys, blue accent, automatic dark mode in the HTML     |
| `corporate`  | Navy blue, serif body, shaded table headers (base theme)              |
| `slate`      | Blue-grey recolor of `corporate`                                      |
| `forest`     | Dark green recolor of `corporate`                                     |
| `editorial`  | Sans-serif, borderless tables, amber accent                           |
| `manuscript` | Classic serif, ivory page, fully ruled tables, burgundy accent        |
| `terminal`   | Dark page, monospace headings, monokai code highlighting              |

Every theme extends `corporate` (`theme/core-network-theme.yml`). Each
theme has two halves: a PDF theme file, `theme/core-network-theme-<name>.yml`,
and HTML colors in `theme/<name>/docinfo.html`, which the build loads
through `docinfodir`. The style themes also set the `table-frame`,
`table-grid`, `table-stripes`, and `rouge-style` attributes in `build.sh`.

The diagrams are SVGs with a white background, so on the `terminal`
theme's dark page they appear inside a white panel. This is expected.

### Adding a theme

1. Add `theme/core-network-theme-<name>.yml` with `extends: core-network`
   and override the colors, plus the fonts and page background for a style
   theme. `theme/core-network-theme-slate.yml` shows a color-only theme, and
   `theme/core-network-theme-terminal.yml` shows a style theme. A font
   outside the bundled catalog (Noto Serif, Noto Sans, M+ 1mn) needs a
   `font.catalog` entry with a `GEM_FONTS_DIR/<file>.ttf` path, as at the
   top of `theme/core-network-theme-editorial.yml`.
2. Add `theme/<name>/docinfo.html` with the same palette. Copy an
   existing one, and symlink `docinfo-header.html` and
   `docinfo-footer.html` from `theme/`. [`AGENTS.md`](../AGENTS.md)
   explains the selectors that each `docinfo.html` must keep.
3. Add a `<name>` case to the `THEME` switch and to the help text in
   `build.sh`.

## 5. Publishing to GitHub Pages

`.github/workflows/pages.yml` builds the book on every push to `main`, or
when you run it manually from the **Actions** tab. The workflow publishes
the result to <https://amirsarebani81.github.io/core-network/>. It runs
these steps:

1. It starts Kroki as a service container on `localhost:8000`, so
   `main.adoc` works unchanged.
2. It runs `bash build.sh all "$THEME"`. `THEME` is set at the top of the
   workflow.
3. It publishes `output/html/`, with `main.html` copied to `index.html`
   and the PDF at `core-network.pdf`. The workflow fails if any page still
   references `localhost:8000` or the search index is missing.
4. If the `GOATCOUNTER_CODE` repository variable is set, it adds the
   GoatCounter analytics script to every page.

One-time setup: go to **Settings → Pages** and set **Source** to
**GitHub Actions**.
