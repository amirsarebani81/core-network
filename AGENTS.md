# AGENTS.md

Instructions for AI agents working in this repository.

## What this is

A docs-as-code reference document covering the architecture and signaling
procedures of the mobile core network (GPRS and EPC). Source is AsciiDoc, built into
PDF and HTML. See `README.md` for the full toolchain and install steps.

## Writing style

All prose in this documentation follows the register of the **IBM Style
Guide** (*Developing Quality Technical Information*), together with the
drafting conventions of **3GPP TR 21.801** wherever the text restates a
specification. The reader is a network engineer who also reads 3GPP specs,
so match that register: precise and formal, but not clipped.

These rules apply to any `.adoc` content you write or edit:

- Vary sentence length to fit the logic of the sentence. Aim for an average
  of roughly 20 to 25 words, and let a sentence carry a subordinate clause
  when the relationship between two facts is itself part of the point.
  Don't split one idea across a run of short declarative sentences, and
  don't write a sentence so long that the reader loses the subject.
- Use active voice by default (e.g. "The MME sends the request", not "The
  request is sent by the MME"). Passive voice is fine where the actor is
  genuinely unknown or irrelevant.
- Prefer a small set of consistent, unambiguous terms over synonyms — do
  not vary vocabulary for style. If a term is defined once (e.g. "SGW-C"),
  reuse it exactly; don't switch between "SGW-C", "the control-plane SGW",
  and "the S-GW control function" for the same thing.
- Spell out an acronym on first use per chapter, then use the acronym
  consistently.
- Keep pronouns unambiguous. Where "it" or "this" could point at more than
  one node, message, or information element, repeat the noun instead.
- No idioms, no figurative language, no humour.
- Reserve the normative keywords "shall", "must", "should", and "may" for
  restating a requirement or a recommendation that a specification actually
  makes, and cite the clause when you do. This book is descriptive, so use
  "can" for a capability and "usually" or "typically" for common practice.

When editing existing prose, bring the surrounding text into compliance
rather than only patching the new sentence.

## Keeping documentation up to date

Treat the documentation as living, not archival:

- When a diagram (`drawio/*.drawio`, `diagrams/*.puml`) changes, update the
  prose that describes it in the same change — node lists, interface
  tables, and step-by-step procedure descriptions must match the figure
  exactly. Don't leave a figure and its description out of sync.
- When you add or rename a network element, interface, or message in one
  place (a diagram, a table, a procedure step), grep the rest of the repo
  for the old name/value and update every reference.
- Prefer verifying facts against the figures/specs already in this repo
  (e.g. read the `.drawio`/`.puml` source, not just the rendered image)
  over restating something from memory — see the note on 3GPP references
  below.
- If a change makes an existing TODO or open question obsolete, remove it
  instead of leaving it stale.

## Repository layout

- `main.adoc` — book entry point; a `= Part` heading per book part (currently
  Part I: GPRS Core, Part II: EPC), each `include::`ing that part's chapters.
- `chapters/epc/*.adoc`, `chapters/gprs/*.adoc` — chapter content, one topic
  per file, grouped by book part.
- `images/*.svg` — rendered diagram exports referenced by `image::` macros
  (paths in `.adoc` files are resolved relative to the repo root, i.e.
  `main.adoc`'s directory — not relative to the including chapter file).
- `drawio/core-network.drawio` — editable source for architecture diagrams,
  one page per diagram (e.g. the `epc-architecture` and `gprs-architecture`
  pages); export a page to `images/*.svg` after editing it, e.g.
  `drawio -x -p <page-number> -f svg --svg-theme light -e -b 5 -o
  images/<name>.svg drawio/core-network.drawio` (the `drawio` CLI needs a
  display; the sandboxed Electron GPU warning it prints on startup is
  harmless).
- `diagrams/*.puml` — PlantUML sequence diagrams, rendered via the Kroki
  service referenced in `main.adoc`'s `:kroki-server-url:` attribute.
- `theme/core-network-theme.yml` — base PDF theme (asciidoctor-pdf),
  "corporate". Six more themes each `extends: core-network` and live
  alongside it: `theme/core-network-theme-slate.yml` and
  `-forest.yml` are color-only recolors; `-editorial.yml`, `-manuscript.yml`,
  `-terminal.yml`, and `-zinc.yml` are style themes that also change the font family,
  page background, and table structure. Selected via
  `bash build.sh <target> <theme-name>` — see `README.md`. `zinc` is the
  default: `build.sh`, the Pages workflow, and the `:pdf-theme:` and
  `:docinfodir:` attributes in `main.adoc` all use it. A theme that
  introduces a font outside the bundled catalog (Noto Serif, Noto Sans,
  M+ 1mn) must declare it under `font.catalog` with a `GEM_FONTS_DIR/*.ttf`
  path (see `core-network-theme-editorial.yml`), or asciidoctor-pdf fails
  the build with "<font> is not a known font".
- `theme/docinfo.html` — HTML head overrides for the `corporate` theme
  (loaded through `:docinfo:` and the `docinfodir` that `build.sh` passes);
  keeps HTML colors in sync with `core-network-theme.yml`.
  Only affects the HTML backend, not the PDF. `theme/slate/`, `theme/forest/`,
  `theme/editorial/`, `theme/manuscript/`, `theme/terminal/`, and
  `theme/zinc/` each hold a
  `docinfo.html` counterpart to one PDF theme above; keep every pair's
  colors (and, for the style themes, fonts/backgrounds) in sync when editing
  a theme. Two selectors in every one of these files need to stay
  independent of the shared heading-color rule:
  `#header > h1:first-child` (the document title) and `#header .details`
  (the byline/version line) both live inside asciidoctor's default
  stylesheet with higher CSS specificity than a plain `h1`/`a` selector, so
  without an explicit override for them the title and byline silently keep
  asciidoctor's default near-black color instead of the theme's — invisible
  on a light page, but a real contrast bug on `terminal`'s dark page.
  Each of these `docinfo.html` files also defines the `--cn-*` CSS custom
  properties (accent, top-bar, border, footer colors) on `:root`.
- `theme/docinfo-header.html` and `theme/docinfo-footer.html` — the
  theme-independent HTML site layout (fixed top bar with the search and
  PDF links, title shown only on the landing page, text-width cap,
  landing-page table of contents, previous/next cards, click-to-enlarge
  diagrams that scroll sideways on phones, highlighted current TOC entry,
  search dialog, print stylesheet, mobile TOC drawer). Each
  `theme/<name>/` directory symlinks both files rather than copying them,
  so edit layout once here and put colors only in the per-theme
  `docinfo.html` via the `--cn-*` variables. The landing-page abstract in
  `main.adoc` sits inside `ifdef::backend-multipage_html5[]`, so it is
  HTML-only; `bash build.sh all` copies the PDF into `output/html/` so the
  "PDF" links work locally.
  The `corporate` theme's `theme/docinfo.html` also carries a
  `prefers-color-scheme: dark` palette; when you change a corporate color,
  check whether its dark-mode counterpart needs the same change. The `zinc`
  theme mirrors the palette of the author's home page
  (`amirsarebani81.github.io`, `index.html`) and also has a dark palette;
  its `theme/zinc/docinfo.html` defines the colors once as `--z-*`
  variables and only redefines those variables for dark mode, so keep new
  rules on the variables rather than on literal colors.
- `scripts/multipage-full-toc.rb` — loaded by `build.sh` after
  `asciidoctor-multipage`; overrides its TOC so that the landing page
  (`main.html`) gets the full outline instead of the chapter titles only.
  Other pages keep the pruned TOC for their own branch.
- `scripts/postprocess-html.rb` — runs after the HTML build: per-page
  `<title>`, Open Graph tags, the favicon MIME type, the full table of
  contents in the body of `main.html` (`.cn-book-toc`, which replaces the
  chapter list, and the sidebar is removed from that page), the numbered
  sub-page list on each chapter page (`.cn-pagelist`), and the
  `data-pagefind-*` attributes for search. `build.sh` then builds the
  Pagefind search index into `output/html/pagefind/` (skipped with a
  message if Pagefind is not installed) and copies `theme/favicon.svg`.
- Packet-format diagrams (`packetdiag::`) carry `role=packet-diagram`,
  which scales them up to the text width in the HTML only; keep the role
  on any new packet diagram.
- `output/` — build output (gitignored). `bash build.sh html` writes a
  multi-page site to `output/html/` (via `asciidoctor-multipage`, split at
  level-2 sections) — open `output/html/main.html`, not a single file.
- `.github/workflows/pages.yml` — builds the book on every push to `main`
  and publishes it to GitHub Pages (the `output/html/` site, with
  `main.html` also copied to `index.html`, plus the PDF). The HTML must
  stay self-contained: `build.sh` passes `-a data-uri -a allow-uri-read`
  so Kroki diagrams are embedded rather than linked to `localhost:8000`,
  and the workflow fails if any page still references `localhost:8000`.
  If the `GOATCOUNTER_CODE` repository variable is set, the workflow
  inserts the GoatCounter analytics script before `</body>` in every
  published page. Keep analytics out of `theme/docinfo-*.html`, so that
  forks and local builds don't report page views.

## Build

```bash
bash build.sh        # PDF + HTML into output/
bash build.sh pdf
bash build.sh html
```

The Kroki diagram server must be running for PlantUML diagrams to render:
`docker compose up -d`. After editing any `.adoc` file, rebuild and confirm
there are no warnings (missing images, broken xrefs) before considering the
change done.

## Technical accuracy

This documentation describes standardized 3GPP procedures (GPRS and EPC/EPS). Cite
the specific 3GPP TS number and clause when adding technical claims (e.g.
"TS 29.274 clause 7.2.1"), and cross-check node/interface/message names
against the referenced spec or existing diagrams rather than assuming.
