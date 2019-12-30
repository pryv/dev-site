---
id: open-api-3
title: 'Open API 3.0'
template: default.jade
customer: true
withTOC: true
---

# Definition file

Here is the Pryv.io API in Open API 3.0 format: [api.yaml](/open-api/3.0/api.yaml)

## Usage

### Postman

1. Import `open-api-format/api.yaml` (with `Import as an API` and `Generate a Postman Collection` checked)
2. Set the environment variables of pryv.me : `username`, `token` and `password` correspond to the variables created for your Pryv.me account (in our example, `username` is `testuser`, the `token` is `ck3iwe3o700yf1ld3hh86rz3m` with `password` being `testuser`), and the `baseUrl` variable should be set as `https://{{token}}@{{username}}.pryv.me`.
3. Enjoy