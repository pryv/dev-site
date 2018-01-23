# Pryv API (developers) website

Source content for api.pryv.com (API reference, recommendations, guides, etc.)


## Contribute

### Prerequisites

Node v8.3.0+, Yarn v0.21.3+

`make setup` sets up the environment.

**Note:** the setup command will install a dependency to pryv/service-core.
By default, it will target the branch defined inside the setup script.
If you want to use another branch, use `make setup core=my_branch` instead.

### Build & publish

- `make build` generates the website from the source into the `build` folder
- `make watch` watches the source folder and rebuilds on changes
- `make clean` cleans up the `build` folder (not done by build/watch)
- `make publish` builds and publishes the website
- `yarn webserver` to run the site locally on [https://l.rec.la:4443/](https://l.rec.la:4443/)

(Read `makefile` for details.)

**Note:** data types are sourced from repo [pryv/data-types](https://github.com/pryv/data-types) on `make retrieve-types` and `make publish` into `source/event-types/_source`.


### Coding conventions

See the [Pryv guidelines](http://pryv.github.io/guidelines/).


## License

[Revised BSD license](https://github.com/pryv/documents/blob/master/license-bsd-revised.md)
