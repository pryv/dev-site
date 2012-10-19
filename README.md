# Pryv server API documentation

DocPad sources for the server API documentation website. **This website will ultimately become our full 'developers' website**.

## Setting up the development environment

Read, then execute `./scripts/setup-environment-dev.sh`.


## Using DocPad

- `./scripts/docpad.sh run` runs a small server serving the generated website, keeping track of source changes (for development)
- `./scripts/docpad.sh generate` generates the website from the source into the `out` folder

Note: last time I checked DocPad does not cleanup obsolete files, so in case you remove some resources please make sure you don't leave garbage in the generated site.

## Publishing

The website is published on <http://pryv.github.com>. To update it:

1. (Make your changes in the sources)
2. Make sure DocPad's output folder (`out`) is not there (either delete it or run `./scripts/docpad.sh clean`)
3. Clone the `pryv.github.com` repo into `out`: `git clone git@github.com:pryv/pryv.github.com.git out`
4. Regenerate the website with DocPad (see "Using DocPad" above)
5. From the `out` folder, commit, then push the changes: `git push origin gh-pages`