# Pryv server API documentation

DocPad sources for the server API documentation website.

## Setting up the development environment

Read, then execute `./scripts/setup-environment-dev.sh`.


## Using DocPad

- `./scripts/docpad.sh run` runs a small server serving the generated website, keeping track of source changes (for development)
- `./scripts/docpad.sh generate` generates the website from the source into the `out` folder
- `./scripts/docpad.sh clean` cleans up the `out` folder


## Temporary: publishing to GitHub project page

The website is temporarily published on <http://pryv.github.com/api-doc/>. To update it:

1. (Make your changes in the sources)
2. Make sure DocPad's output folder (`out`) is not there (either delete it or run `./scripts/docpad.sh clean`)
3. Clone the `gh-pages` branch (GitHub project page) into `out`: `git clone -b gh-pages git@github.com:pryv/api-doc.git out`
4. Regenerate the website with DocPad (see "Using DocPad" above)
5. From the `out` folder, commit, then push the changes: `git push origin gh-pages`