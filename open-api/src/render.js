const datastructure = require('../transpiled/data-structure');
const methods = require('../transpiled/methods');
const admin = require('../transpiled/admin');
const system = require('../transpiled/system');
const fs = require('fs');
const path = require('path');

fs.writeFileSync(renderedPath('data-structure.json'), JSON.stringify(datastructure, null, 2));
fs.writeFileSync(renderedPath('methods.json'), JSON.stringify(methods, null, 2));
fs.writeFileSync(renderedPath('admin.json'), JSON.stringify(admin, null, 2));
fs.writeFileSync(renderedPath('system.json'), JSON.stringify(system, null, 2));

function renderedPath (fileName) {
  return path.join(__dirname, '../rendered', fileName);
}
