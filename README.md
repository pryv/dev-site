# Pryv API (developers) website

Source content for api.pryv.com (API reference, recommendations, guides, etc.)


## Writing documentation <!-- TODO: probably move this to guidelines and just refer from here -->

Try to stick to the following guidelines when writing (these guidelines are meant to be updated and completed as we progress):

- **Use "you"**: We're speaking to third-party app developers, who are playing an invaluable role in building the Pryv ecosystem. Let's address them personally.
- **Use the feminine form for users and other indeterminate cases**: Our domain is masculine enough; let's help balance that whenever we can. (See [Faruk Ateş's good article on the topic](http://www.netmagazine.com/features/primer-sexism-tech-industry).)
- **Clarity comes first, but friendliness is next** (and humor is allowed): It's an API doc, but we write it for human beings; simple and unambiguous language does not prevent a friendly tone. (Your own peculiar) Humor is encouraged (maybe best in examples' data).
- **Take the diversity of third-party apps dev stacks into account**: Don't assume everyone is using Javascript; Pryv apps can be written with any dev stack.


## Building

Prerequisite: the source API server working copy must be under `../api-server`.

- `make setup` sets up the environment
- `make build` generates the website from the source into the `build` folder
- `make watch` watches the source folder and rebuilds on changes
- `make publish` builds and publishes the website

(Read the `makefile` for details.)

**Note:** data types are sourced from repo `pryv/data-types` on `make retrieve-types` and `make publish` into `source/event-types/_source`.


## License

[Revised BSD license](https://github.com/pryv/documents/blob/master/license-bsd-revised.md)
