set -euo pipefail
cd "$(dirname "$0")"

print_help() {
  cat <<'EOF'
Usage: build.sh [TARGET] [THEME]

Build the Core Network documentation into output/.

TARGET (default: all)
  pdf     Build the PDF only
  html    Build the HTML only
  all     Build both PDF and HTML

THEME (default: corporate)
  corporate    Navy blue, serif body, shaded table headers (default)
  slate        Blue-grey recolor of corporate
  forest       Dark green recolor of corporate
  editorial    Sans-serif, minimalist borderless tables, amber accent
  manuscript   Classic serif, ivory page, fully-ruled tables, burgundy accent
  terminal     Dark page, monospace headings, monokai code highlighting

Options:
  -h, --help   Show this help message and exit

Examples:
  build.sh                   # PDF + HTML, corporate theme
  build.sh pdf                # PDF only, corporate theme
  build.sh all slate          # PDF + HTML, slate theme
  build.sh html forest        # HTML only, forest theme
  build.sh all editorial      # PDF + HTML, editorial theme
  build.sh pdf terminal       # PDF only, terminal theme
EOF
}

case "${1:-}" in
  -h|--help)
    print_help
    exit 0
    ;;
esac

TARGET="${1:-all}"
THEME="${2:-corporate}"
mkdir -p output

TABLE_FRAME=""
TABLE_GRID=""
TABLE_STRIPES=""
ROUGE_STYLE=""

case "$THEME" in
  corporate)
    PDF_THEME="core-network-theme.yml"
    DOCINFODIR="theme"
    ;;
  slate)
    PDF_THEME="core-network-theme-slate.yml"
    DOCINFODIR="theme/slate"
    ;;
  forest)
    PDF_THEME="core-network-theme-forest.yml"
    DOCINFODIR="theme/forest"
    ;;
  editorial)
    PDF_THEME="core-network-theme-editorial.yml"
    DOCINFODIR="theme/editorial"
    TABLE_FRAME="topbot"
    TABLE_GRID="none"
    TABLE_STRIPES="none"
    ;;
  manuscript)
    PDF_THEME="core-network-theme-manuscript.yml"
    DOCINFODIR="theme/manuscript"
    TABLE_FRAME="all"
    TABLE_GRID="all"
    TABLE_STRIPES="none"
    ;;
  terminal)
    PDF_THEME="core-network-theme-terminal.yml"
    DOCINFODIR="theme/terminal"
    TABLE_FRAME="topbot"
    TABLE_GRID="rows"
    TABLE_STRIPES="even"
    ROUGE_STYLE="monokai"
    ;;
  *)
    echo "Unknown theme: $THEME (use corporate, slate, forest, editorial, manuscript, or terminal)"
    exit 1
    ;;
esac

EXTRA_ATTRS=()
[ -n "$TABLE_FRAME" ] && EXTRA_ATTRS+=(-a "table-frame=$TABLE_FRAME")
[ -n "$TABLE_GRID" ] && EXTRA_ATTRS+=(-a "table-grid=$TABLE_GRID")
[ -n "$TABLE_STRIPES" ] && EXTRA_ATTRS+=(-a "table-stripes=$TABLE_STRIPES")
[ -n "$ROUGE_STYLE" ] && EXTRA_ATTRS+=(-a "rouge-style=$ROUGE_STYLE")

build_pdf() {
  echo "==> Building PDF (theme: $THEME)..."
  asciidoctor-pdf \
    -r asciidoctor-kroki \
    -a pdf-theme="$PDF_THEME" \
    -a pdf-themesdir=theme \
    -a allow-uri-read \
    -a cache-uri \
    "${EXTRA_ATTRS[@]}" \
    main.adoc -o output/core-network.pdf
  echo "==> PDF written to output/core-network.pdf"
}

build_html() {
  echo "==> Building HTML (theme: $THEME)..."
  asciidoctor \
    -r asciidoctor-kroki \
    -a data-uri \
    -a docinfodir="$DOCINFODIR" \
    "${EXTRA_ATTRS[@]}" \
    main.adoc -o output/core-network.html
  echo "==> HTML written to output/core-network.html"
}

case "$TARGET" in
  pdf) build_pdf ;;
  html) build_html ;;
  all) build_pdf; build_html ;;
  *) echo "Unknown target: $TARGET (use pdf, html, or all)"; exit 1 ;;
esac
