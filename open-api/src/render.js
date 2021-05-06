const datastructure = require('../transpiled/data-structure');
const methods = require('../transpiled/methods');
const admin = require('../transpiled/admin');
const system = require('../transpiled/system');
const fs = require('fs');

fs.writeFileSync(__dirname + '/../rendered/data-structure.json', JSON.stringify(datastructure, null, 2));
fs.writeFileSync(__dirname + '/../rendered/methods.json', JSON.stringify(methods, null, 2));
fs.writeFileSync(__dirname + '/../rendered/admin.json', JSON.stringify(admin, null, 2));
fs.writeFileSync(__dirname + '/../rendered/system.json', JSON.stringify(system, null, 2));
