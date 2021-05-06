const version = require('../../source/_reference/index').version;
module.exports = {
  openapi: '3.0.0',
  info: {
    description: 'Description of Pryv.io System API in Open API 3.0 standard format',
    version: version,
    title: 'Pryv.io System API',
    contact: {
      email: 'support@pryv.com'
    },
    license: {
      name: 'MIT',
      url: 'https://opensource.org/licenses/MIT'
    }
  }
};