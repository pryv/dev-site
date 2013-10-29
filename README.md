# Pryv API (developers) website

API reference, recommendations, guides, etc.


## Temporary note

There's a mess of files that are only there for our temporary teaser page (current `index.html`). This will be cleaned up when the full site gets ready for prime time.


## Writing documentation

Try to stick to the following guidelines when writing (these guidelines are meant to be updated and completed as we progress):

- **Use "you"**: We're speaking to third-party app developers, who are playing an invaluable role in building the Pryv ecosystem. Let's address them personally.
- **Use the feminine form for users and other indeterminate cases**: Our domain is masculine enough; let's help balance that whenever we can. (See [Faruk Ateş's good article on the topic](http://www.netmagazine.com/features/primer-sexism-tech-industry).)
- **Clarity comes first, but friendliness is next** (and humor is allowed): It's an API doc, but we write it for human beings; simple and unambiguous language does not prevent a friendly tone. (Your own peculiar) Humor is encouraged (maybe best in examples' data).
- **Take the diversity of third-party apps dev stacks into account**: Don't assume everyone is using Javascript; Pryv apps can be written with any dev stack.


## Development

- `make setup` sets up the environment; relies on [nvm](https://github.com/creationix/nvm)
- `make server` runs a small server serving the generated website during development development
- `make compile` generates the website from the source into the `build` folder
- `make publish` compiles the website (see `compile` target above) and publishes it to the repo's `gh-pages` branch
- `scripts/update-api-version.bash` automatically updates the API version from a nearby `api-server` repo (assuming `../api-server/package.json` to exist from the present repo's root)

(Read the `makefile` for details.)

**Note:** data types are sourced from repo `pryv/data-types` on `make compile` (or run `make retrieve-types` to execute that specific step) to files in `source/event-types` (git-ignored).


## License

[Revised BSD license](https://github.com/pryv/documents/blob/master/license-bsd-revised.md)
