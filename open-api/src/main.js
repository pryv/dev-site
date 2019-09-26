const methodsRoot = require('../transpiled/methods');
const yaml = require('yaml');
const fs = require('fs');

const OUTPUT_FILE = 'open-api-format/api.yaml';

const api = {
  path: {},
};

methodsRoot.sections.forEach(section => {
  section.sections.forEach(method => {
    const path = parseBy(method.http, ' ', 1);
    if (api.path[path] == null) {
      api.path[path] = {}
    }

    const httpMethod = parseBy(method.http, ' ', 0)

    api.path[path][httpMethod.toLowerCase()] = {
      description: method.description,
      parameters: [
        {
          name: 
        }
      ]
    };
  });
});

console.log(methodsRoot.sections[0].sections);

writeToOutput();

function parseBy(string, sep, pos) {
  return string.split(sep)[pos];
}



function writeToOutput() {
  fs.writeFileSync(OUTPUT_FILE, yaml.stringify(api));
}