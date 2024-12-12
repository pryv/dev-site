# Pryv API (developers) website

Source content for pryv.github.io (API reference, recommendations, guides, etc.)


## Installation

Prerequisites: [Node.js](https://nodejs.org/en/download/) 16, [just](https://github.com/casey/just#installation)

Then:
1. `just setup` to install node modules and setup `dist/` as well as repository copies of `service-core` and `test-results` (see `scripts/setup` for details)
2. `just build` for the initial compilation into `dist/`

Running `just` with no argument displays the available commands (defined in `justfile`).


## Build & publish

- `just build` generates the website from `src/` into `dist/`
- `just watch` watches `src/` and rebuilds on changes
- `just clean` cleans up `dist/` (not done by build/watch)
- `just publish` builds and publishes the website
- `just serve` to run the site locally on [https://l.rec.la:4443/](https://l.rec.la:4443/)

**Note:** data types are sourced from repo [pryv/data-types](https://github.com/pryv/data-types) on `just retrieve-types` and `just publish` into `src/event-types/_source`.

**Note:** test results are sourced from repo [pryv/dev-test-results](https://github.com/pryv/dev-test-results) on `just retrieve-tests` and `just publish` into `dependencies/test-results`.


## Don't forget

- [API version bump](/src/_reference/index.js#L11)
- [Change log](/src/change-log.md)


## OpenAPI 3.0 definitions

The sub-package in `open-api/` implements the generation of OpenAPI definitions from the source reference documentation.

### Generating definitions

```
just open-api
```

### Importing in Postman

1. Import `open-api-format/api.yaml` (with `Import as an API` and `Generate a Postman Collection` checked)
2. Set the environment variables of pryv.me : `username`, `token` and `password` correspond to the variables created for your Pryv.me account (in our example, `username` is `testuser`, the `token` is `ck3iwe3o700yf1ld3hh86rz3m` with `password` being `testuser`), and the `baseUrl` variable should be set as `https://{{token}}@{{username}}.pryv.me`.
3. Enjoy


## License

[BSD-3-Clause](https://github.com/pryv/dev-site/blob/master/LICENSE)
