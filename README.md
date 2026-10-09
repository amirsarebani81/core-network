# Core Network: Architecture and Signaling Procedures

A reference book on the architecture of the mobile packet core network and
the signaling procedures between its network elements, with call flow
diagrams and citations to the 3GPP Technical Specification (TS) clause that
defines each procedure.

[![Publish to GitHub Pages](https://github.com/amirsarebani81/core-network/actions/workflows/pages.yml/badge.svg)](https://github.com/amirsarebani81/core-network/actions/workflows/pages.yml)
[![License: CC BY-NC-ND 4.0](https://img.shields.io/badge/content-CC%20BY--NC--ND%204.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-nd/4.0/)
[![License: MIT](https://img.shields.io/badge/tooling-MIT-blue.svg)](LICENSES/MIT.txt)

**[Read online](https://amirsarebani81.github.io/core-network/)** ·
**[Download the PDF](https://amirsarebani81.github.io/core-network/core-network.pdf)**

## About

The book is organized in parts:

- **Part I: GPRS Core**, the General Packet Radio Service core network.
- **Part II: Evolved Packet Core (EPC)**, with Control and User Plane
  Separation (CUPS).
- **Part III: 5G Core (5GC)**, the core network of the 5G System.
- **Part IV: Policy and Charging Control**, the policy and charging
  control framework, with its principles and its realization for GPRS and
  the EPC.

For each generation, the book describes the network elements and the
interfaces between them, the protocols that carry signaling between the
network elements, and the signaling procedures that run over those
protocols. Each procedure has a call flow diagram and a step-by-step
description of its messages. Each technical claim cites the TS and clause
that defines it, so you can move directly between the book and the
specifications.

The book is written for network engineers who work with, test, or
troubleshoot mobile core networks and who also read the 3GPP specifications.

**Status:** the book is a work in progress, and chapters are added over
time. The online edition always reflects the latest version of the `main`
branch.

## Feedback and contributions

Please [open an issue](https://github.com/amirsarebani81/core-network/issues)
in any of these cases:

- You find a technical error, an incorrect citation, or a broken diagram.
  Include the section number and, where it applies, the TS clause that you
  believe is correct.
- Information is missing from a chapter.
- A procedure that the book doesn't cover yet would be useful. Name the
  procedure and, if you can, the TS clause that defines it.

Pull requests are welcome too. For a larger change, such as a new
procedure, please open an issue first so that we can agree on the scope.
Follow the writing style in [AGENTS.md](AGENTS.md), cite the TS clause for
each technical claim, and build the book with `bash build.sh` to confirm
that there are no warnings. By submitting a pull request, you agree that
your contribution is licensed under the same terms as the file that it
changes (see [License](#license)).

## Building locally

The book is written in AsciiDoc and built with Asciidoctor. The diagrams are
rendered by a local Kroki server.

```bash
docker compose up -d   # start the Kroki diagram server
bash build.sh          # build the PDF and HTML into output/
```

Then open `output/core-network.pdf` or `output/html/main.html`. See
[docs/BUILDING.md](docs/BUILDING.md) for the installation steps, the
available themes, and the publishing workflow.

## License

Copyright © 2026 Amir Hossein Sarebani.

- **Book content** (the text, figures, and diagrams in `main.adoc`,
  `chapters/`, `diagrams/`, `drawio/`, and `images/`, and the published
  HTML and PDF) is licensed under
  [CC BY-NC-ND 4.0](https://creativecommons.org/licenses/by-nc-nd/4.0/).
  You can share the book unchanged, for non-commercial purposes, if you
  credit the author. You can't distribute modified versions.
- **Build tooling** (`build.sh`, `docker-compose.yml`, `scripts/`, `theme/`,
  and `.github/`) is licensed under the [MIT License](LICENSES/MIT.txt).

See [LICENSE](LICENSE) for the details. To use the book outside these
terms, for example commercially or in a translation, contact the author.

3GPP™ is a trade mark of ETSI, registered for the benefit of its Members and
of the 3GPP Organizational Partners. The 3GPP specifications are copyright of
the 3GPP Organizational Partners. This book is an independent work and is
not affiliated with or endorsed by 3GPP or ETSI.

## Author

**Amir Hossein Sarebani** · [amirsarebani81.github.io](https://amirsarebani81.github.io/)
