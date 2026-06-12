# AGENTS.md

Welcome, agent. Fast orientation for this repo. Read this first, `README.md` for depth.

## What this repo is

`dev-site` is the **source of <https://pryv.github.io/>** — the Pryv.io developer documentation site (API reference, concepts, guides, operator resources). It is a static-site build: [Metalsmith](https://metalsmith.io) pipeline defined in `build.js`, content in `src/`, output committed to `dist/` which is a **separate git checkout of the `pryv/pryv.github.io` repository**.

The API reference itself is **data, not prose**: CoffeeScript structures under `src/_reference/*.coffee` (methods, data structures, basics) rendered through Pug layouts. Editing reference content means editing those `.coffee` files.

## Quick repo map

```
build.js                  Metalsmith pipeline (read this first)
src/
  _reference/             API reference SOURCE (CoffeeScript data) — methods.coffee,
                          data-structure.coffee, basics.coffee, admin.coffee, …
                          index.js declares the displayed API version
  _functional-specifications/, _test-results/   other generated-page sources
  _layouts/               Pug layouts
  *.md, *.pug             Pages (markdown is rendered to HTML, permalinked to /<id>/)
  llms.txt                Agent-facing index — served verbatim at /llms.txt
  llms-full.txt           Agent-facing dense API reference — served verbatim at /llms-full.txt
  customer-resources/     Operator-facing setup guides
  guides/                 Developer guides (webhooks, data modelling, …)
  event-types/_source/    Event-type JSONs retrieved from pryv/data-types (just retrieve-types)
open-api/                 OpenAPI 3.0 definitions generator (sub-package)
dist/                     Build output = clone of pryv/pryv.github.io (gh-pages style)
justfile                  All commands (run `just` to list)
```

## Commands

```bash
just setup            # npm install + clone dist/ + dependencies
just build            # src/ → dist/  (add --nolinkcheck to skip the link checker)
just watch            # rebuild on change
just serve            # local server on dist/
just publish          # retrieve-types + retrieve-tests + clean + build + commit/push dist/
just lint             # semistandard
```

`just publish` is the deployment: it commits and pushes the `dist/` checkout, which IS the live site. Never run it with a dirty or experimental build.

## File-handling rules (the non-obvious part)

- **`.md` files in `src/` are rendered** to HTML and permalinked (`/{id}/`). They do not survive as raw markdown on the site.
- **`.txt` files pass through verbatim** (`robots.txt`, `llms.txt`, `llms-full.txt`).
- The link checker (`metalsmith-plugins/linkcheck`) runs on every build unless `--nolinkcheck`; broken external links fail the build via `linkcheck-issues.json`.
- The displayed API version lives in `src/_reference/index.js` — bump it when the API reference changes.

## Agent-facing files — keep them in sync

`src/llms.txt` (index) and `src/llms-full.txt` (dense single-page reference) are the entry points AI agents fetch from <https://pryv.github.io/llms.txt> and <https://pryv.github.io/llms-full.txt>.

**Any substantive change to the API reference (`src/_reference/*.coffee`), concepts, auth flow, or event-types pointers must be mirrored in `llms-full.txt`** — and bump its `Last updated:` header line. They are hand-maintained; nothing regenerates them for you.

## Where to file issues / PRs

- All developer-experience feedback (docs, API, client library): [`pryv/open-pryv.io` GitHub Issues](https://github.com/pryv/open-pryv.io/issues) — single tracker, maintainers route internally.
- PRs here against `master`. The site goes live only when someone runs `just publish`.

## When in doubt

- `build.js` is short — read it to understand exactly what happens to a file.
- Check how an existing page of the same kind is written before adding a new one.
- The server codebase (truth for current behavior) is [`pryv/open-pryv.io`](https://github.com/pryv/open-pryv.io); where docs and server disagree, trust the server and fix the docs.
