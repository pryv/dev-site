# Open-API 3.0 export tools

## Usage

### Postman

1. Import `open-api-format/api.yaml` (with `Import as an API` and `Generate a Postman Collection` checked)
2. Set `baseUrl` into environment
3. Enjoy

## Contribute

*Prerequisites:* Yarn v1+, Node v8+

- Fetch dependencies: `yarn install`
- Transpile `../source/` into `transpiled/`: `yarn transpile`
- Export into `open-api-format/`: `yarn export`

