# Pryv API (developers) website

Source content for api.pryv.com (API reference, recommendations, guides, etc.)


## Contribute

### Prerequisites

Node v0.10+.

`make setup` sets up the environment.


### Build & publish

Prerequisite: the source API server working copy must be under `../api-server`.

- `make build` generates the website from the source into the `build` folder
- `make watch` watches the source folder and rebuilds on changes
- `make clean` cleans up the `build` folder (not done by build/watch)
- `make publish` builds and publishes the website

(Read `makefile` for details.)

**Note:** data types are sourced from repo `pryv/data-types` on `make retrieve-types` and `make publish` into `source/event-types/_source`.


### Coding conventions

See the [Pryv guidelines](http://pryv.github.io/guidelines/).


## License

[Revised BSD license](https://github.com/pryv/documents/blob/master/license-bsd-revised.md)
