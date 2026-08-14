set -euo pipefail
cd "$(dirname "$0")"

TARGET="${1:-all}"
mkdir -p output

build_pdf() {
  echo "==> Building PDF..."
  asciidoctor-pdf \
    -r asciidoctor-kroki \
    -a pdf-theme=core-network-theme.yml \
    -a pdf-themesdir=theme \
    -a allow-uri-read \
    -a cache-uri \
    main.adoc -o output/core-network.pdf
  echo "==> PDF written to output/core-network.pdf"
}

build_html() {
  echo "==> Building HTML..."
  asciidoctor \
    -r asciidoctor-kroki \
    -a data-uri \
    main.adoc -o output/core-network.html
  echo "==> HTML written to output/core-network.html"
}

case "$TARGET" in
  pdf) build_pdf ;;
  html) build_html ;;
  all) build_pdf; build_html ;;
  *) echo "Unknown target: $TARGET (use pdf, html, or all)"; exit 1 ;;
esac
