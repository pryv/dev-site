# add node bin script path for recipes
export PATH := "./node_modules/.bin:" + env_var('PATH')

typesBaseURL := "https://raw.github.com/pryv/data-types/master/dist/"
eventTypesURL := typesBaseURL + "event-types.json"
flatTypesURL := typesBaseURL + "flat.json"
typesSourceTarget := "./source/event-types/_source"

# Default: display available recipes
_help:
    @just --list

# –––––––––––––----------------------------------------------------------------
# Setup
# –––––––––––––----------------------------------------------------------------

# Set up the dev environment
setup:
    scripts/setup

# Install node modules afresh
install *params: clean
    npm install {{params}}

# Clean up node modules & build
clean:
    rm -rf node_modules
    rm -rf build/*

# Install node modules strictly as specified (typically for CI)
install-stable:
    npm ci

# –––––––––––––----------------------------------------------------------------
# Build & related
# –––––––––––––----------------------------------------------------------------

# Build the site from source
build:
    node build.js

# Build the site then watch and update when source files change
watch:
    node build.js watch

# Retrieves event types from their repo
retrieve-types:
    @echo ""
    @echo "Retrieving data types from {{typesBaseURL}}..."
    @echo ""
    @cd {{typesSourceTarget}} && curl -LO {{eventTypesURL}} -LO {{flatTypesURL}}

# Retrieves test results from their repo
retrieve-tests:
    @echo ""
    @echo "Retrieving test results from repo..."
    @echo ""
    @cd dependencies/test-results && git pull

# Build & publish on `pryv.github.io` (a.k.a. `api.pryv.com`)
publish: retrieve-types retrieve-tests build
    @cd build && git add . && git add -u . && git commit -m "Updated generated files" && git push

# Start a `rec.la` web server on `build/`
serve:
    node node_modules/rec-la/webserver/main.js ./build

# –––––––––––––----------------------------------------------------------------
# OpenAPI definitions
# –––––––––––––----------------------------------------------------------------

# Generate OpenAPI definitions (see `open-api/`)
open-api: _open-api-install _open-api-transpile _open-api-export

# Install module dependencies for OpenAPI definitions
_open-api-install:
    @cd open-api && npm install

# Transpile source into `open-api/transpiled/` (code) and `open-api/rendered/` (JSON)
_open-api-transpile:
    #!/usr/bin/env sh
    cd open-api
    coffee -c -o transpiled ../source/_reference
    find transpiled \( -type d -name .git -prune \) -o -type f -print0 | xargs -0 sed -i "" -e "s/\.coffee/\.js/g"
    node src/render

# Export to `open-api/open-api-format/`
_open-api-export:
    #!/usr/bin/env sh
    cd open-api
    node src/main
