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
bash build.sh        # builds both PDF and HTML into output/
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
