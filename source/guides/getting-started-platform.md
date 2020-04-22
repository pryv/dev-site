---
id: app-guidelines
title: 'App guidelines'
template: default.jade
customer: true
withTOC: true
---


1. prepare machines

XXX

link to deployment design guide

2. obtain domain name

- ask us for XXX.pryv.io, ex.: addmin.pryv.io
or
- obtain one yourself

3. obtain license, credentials and config files

- license
- credentials to pull docker images
- config files to deploy services: https://github.com/pryv/config-template-pryv.io/tree/central/pryv.io

4. Set platform variables

- https://github.com/pryv/config-template-pryv.io/blob/central/pryv.io/single-node/config-leader/conf/platform.yml

4. obtain SSL certificate

5. link to platform installation validation

https://api.pryv.com/assets/docs/20190131-pryv.io-verification-v3.pdf

6. Setup platform health monitoring

https://api.pryv.com/assets/docs/20190201-API-healthchecks-v4.pdf

7. Fork app-web-auth3

https://github.com/pryv/app-web-auth3

8. Define your data model

https://api.pryv.com/guides/data-modelling/