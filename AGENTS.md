# AGENTS.md

Instructions for AI agents working in this repository.

## What this is

A docs-as-code reference document covering the architecture and signaling
procedures of the mobile core network (EPC). Source is AsciiDoc, built into
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

This documentation describes standardized 3GPP procedures (EPC/EPS). Cite
the specific 3GPP TS number and clause when adding technical claims (e.g.
"TS 29.274 clause 7.2.1"), and cross-check node/interface/message names
against the referenced spec or existing diagrams rather than assuming.
