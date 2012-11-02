# Pryv server API documentation

DocPad sources for the server API documentation website. **This website will ultimately become our full 'developers' website**.


## Writing documentation

Try to stick to the following guidelines when writing (these guidelines are meant to be updated and completed as we progress):

- **Use "you"**: We're speaking to third-party app developers, who are playing an invaluable role in building the Pryv ecosystem. Let's address them personally.
- **Clarity comes first, but friendliness is next** (and humor is allowed): It's an API doc, but we write it for human beings; simple and unambiguous language does not prevent a friendly tone. (Your own peculiar) Humor is encouraged (maybe best in examples' data).
- **Take the diversity of third-party apps dev stacks into account**: Don't assume everyone is using Javascript; Pryv apps can be written with any dev stack.


## Setting up the development environment

Read, then execute `./scripts/setup-environment-dev.sh`.


## Generating the static website files with DocPad

- `./scripts/docpad.sh run` runs a small server serving the generated website, keeping the `out` folder up-to-date as source changes (for development)
- `./scripts/docpad.sh generate` just generates the website from the source into the `out` folder

Note: last time I checked DocPad does not cleanup obsolete files, so in case you remove some resources please make sure you don't leave garbage in the generated site.


## Publishing

The website is published with GitHub pages on <http://pryv.github.com>. To update it, after making sure your changes in the sources are committed and the generated website files are up-to-date (see the instructions on generating the files with DocPad above), simply:

1. Go to the `out` folder (which is a working copy of our 'pryv.github.com' repo)
2. Commit the changes to the generated files
3. Push (to 'master': `git push`)