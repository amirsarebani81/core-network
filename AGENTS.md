# AGENTS.md

Instructions for AI agents working in this repository.

## What this is

A docs-as-code reference document covering the architecture and signaling
procedures of the mobile core network (EPC). Source is AsciiDoc, built into
PDF and HTML. See `README.md` for the full toolchain and install steps.

## Writing style: ASD-STE100

All prose in this documentation must follow **ASD-STE100 (Simplified
Technical English)**. This is non-negotiable for any `.adoc` content you
write or edit:

- One instruction or fact per sentence. Keep sentences short (as a guide,
  under ~20 words).
- Use active voice and the approved verb forms (e.g. "The MME sends the
  request", not "The request is sent by the MME").
- Avoid nested clauses, ambiguous pronouns, and figurative language.
- Prefer a small set of consistent, unambiguous terms over synonyms — do
  not vary vocabulary for style. If a term is defined once (e.g. "SGW-C"),
  reuse it exactly; don't switch between "SGW-C", "the control-plane SGW",
  and "the S-GW control function" for the same thing.
- Spell out an acronym on first use per chapter, then use the acronym
  consistently.
- Only use words/senses in their normal technical or dictionary meaning —
  no idioms, no "may" for possibility (use "can"), reserve "must" for
  requirements.

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

- `main.adoc` — book entry point; `include::`s each chapter.
- `chapters/epc/*.adoc` — chapter content, one topic per file.
- `images/*.svg` — rendered diagram exports referenced by `image::` macros
  (paths in `.adoc` files are resolved relative to the repo root, i.e.
  `main.adoc`'s directory — not relative to the including chapter file).
- `drawio/*.drawio` — editable source for architecture diagrams; export to
  `images/*.svg` after editing.
- `diagrams/*.puml` — PlantUML sequence diagrams, rendered via the Kroki
  service referenced in `main.adoc`'s `:kroki-server-url:` attribute.
- `theme/core-network-theme.yml` — default PDF theme (asciidoctor-pdf),
  "corporate". Five more themes each `extends: core-network` and live
  alongside it: `theme/core-network-theme-slate.yml` and
  `-forest.yml` are color-only recolors; `-editorial.yml`, `-manuscript.yml`,
  and `-terminal.yml` are style themes that also change the font family,
  page background, and table structure. Selected via
  `bash build.sh <target> <theme-name>` — see `README.md`. A theme that
  introduces a font outside the bundled catalog (Noto Serif, Noto Sans,
  M+ 1mn) must declare it under `font.catalog` with a `GEM_FONTS_DIR/*.ttf`
  path (see `core-network-theme-editorial.yml`), or asciidoctor-pdf fails
  the build with "<font> is not a known font".
- `theme/docinfo.html` — HTML head overrides (`:docinfo:`/`:docinfodir:` in
  `main.adoc`); keeps HTML colors in sync with `core-network-theme.yml`.
  Only affects the HTML backend, not the PDF. `theme/slate/`, `theme/forest/`,
  `theme/editorial/`, `theme/manuscript/`, and `theme/terminal/` each hold a
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
- `output/` — build output (gitignored).

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

This documentation describes standardized 3GPP procedures (EPC/EPS). Cite
the specific 3GPP TS number and clause when adding technical claims (e.g.
"TS 29.274 clause 7.2.1"), and cross-check node/interface/message names
against the referenced spec or existing diagrams rather than assuming.
