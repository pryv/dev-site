const version = require('../../src/_reference/index').version;
module.exports = {
  openapi: '3.0.0',
  info: {
    description: 'Description of Pryv.io Admin API in Open API 3.0 standard format',
    version: version,
    title: 'Pryv.io Admin API',
    contact: {
      url: 'https://github.com/pryv/open-pryv.io/issues'
    },
    license: {
      name: 'MIT',
      url: 'https://opensource.org/licenses/MIT'
    }
  }
};
