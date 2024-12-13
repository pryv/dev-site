const version = require('../../src/_reference/index').version;
module.exports = {
  openapi: '3.0.0',
  info: {
    description: 'Description of Open-Pryv.io API in Open API 3.0 standard format',
    version: version,
    title: 'Open-Pryv.io API',
    contact: {
      url: 'https://github.com/pryv/open-pryv.io/issues'
    },
    license: {
      name: 'MIT',
      url: 'https://opensource.org/licenses/MIT'
    }
  }
};
