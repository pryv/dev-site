const datastructure = require('../transpiled/data-structure');
const methods = require('../transpiled/methods');
const fs = require('fs');

fs.writeFileSync(__dirname + '/../rendered/data-structure.json', JSON.stringify(datastructure, null, 2));
fs.writeFileSync(__dirname + '/../rendered/methods.json', JSON.stringify(methods, null, 2));
