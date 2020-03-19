# Pryv API (developers) website

Source content for api.pryv.com (API reference, recommendations, guides, etc.)


## Contribute

### Prerequisites

Node v12+, Yarn v1+

`make setup` sets up the environment.

**Note:** The setup command will install the node dependencies as well as the following external dependencies:
- pryv/service-core
- pryv/test-results

See `dev-env/setup.sh` for more details.

### Build & publish

- `make build` generates the website from the source into the `build` folder
- `make watch` watches the source folder and rebuilds on changes
- `make clean` cleans up the `build` folder (not done by build/watch)
- `make publish` builds and publishes the website
- `yarn webserver` to run the site locally on [https://l.rec.la:4443/](https://l.rec.la:4443/)

(Read `makefile` for details.)

**Note:** data types are sourced from repo [pryv/data-types](https://github.com/pryv/data-types) on `make retrieve-types` and `make publish` into `source/event-types/_source`.


**Note:** test results are sourced from repo [pryv/test-results-pryv.io](https://github.com/pryv/test-results-pryv.io) on `make retrieve-tests` and `make publish` into `source/event-types/_source`.

### Don't forget

- [API version bump](/source/_reference/index.js#L11)
- [Change log](/source/change-log.md)

### Coding conventions

See the [Pryv guidelines](http://pryv.github.io/guidelines/).


## License

[Revised BSD license](https://github.com/pryv/documents/blob/master/license-bsd-revised.md)
