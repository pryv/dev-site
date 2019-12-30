# Open-API 3.0 export tools

## Usage

### Postman

1. Import `open-api-format/api.yaml` (with `Import as an API` and `Generate a Postman Collection` checked)
2. Set the environment variables of pryv.me : `username`, `token` and `password` correspond to the variables created for your Pryv.me account (in our example, `username` is `testuser`, the `token` is `ck3iwe3o700yf1ld3hh86rz3m` with `password` being `testuser`), and the `baseUrl` variable should be set as `https://{{token}}@{{username}}.pryv.me`.
3. Enjoy

## Contribute

*Prerequisites:* Yarn v1+, Node v8+

- Fetch dependencies: `yarn install`
- Transpile `../source/` into `transpiled/` (code) and `rendered/` (JSON): `yarn transpile`
- Export into `open-api-format/`: `yarn export`

