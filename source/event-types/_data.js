module.exports = {
  flat: {
    layout: '_flat-layout',
    sourceData: require('./hierarchical.json'),
    _: require('lodash')
  },
  index: require('../_meta/pages')['event-types']
};
