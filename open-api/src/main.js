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

    const httpMethod = parseBy(method.http, ' ', 0).toLowerCase();

    api.path[path][httpMethod] = {
      description: method.description,
      operationId: method.id,
      parameters: [], 
      responses: [], //to be defined
      tags: [], //optional
      requestBody: [] //to be defined
    };

    function isGetOrDelete(verb) {
      return verb == 'get' || verb == 'delete';
    }
    function isPostorPut(verb){
      return verb == 'post' || verb == 'put';
    }
    function hasParams(method) {
      return method.params != null && method.params.properties != null;
    }

    // handle body params
    if (hasParams(method) && isPostorPut(httpMethod)) {
      const bodyParamsRaw = extractQueryParams(method.params.properties);
      bodyParamsRaw
      api.path[path][httpMethod].parameters = api.path[path][httpMethod].parameters.concat(queryParamsRaw);
    }

    // handle query params
    if (hasParams(method) && isGetOrDelete(httpMethod)) {
      const queryParamsRaw = extractQueryParams(method.params.properties);
      api.path[path][httpMethod].parameters = api.path[path][httpMethod].parameters.concat(queryParamsRaw);
    }
    

    // handle path params
    const pathParamsRaw = extractPathParams(path)
    const pathParams = [];
    pathParamsRaw.forEach(p => {
      pathParams.push({
        name: p,

      })
    })
    api.path[path][httpMethod].parameters = api.path[path][httpMethod].parameters.concat(pathParams);
    


  });
});

console.log(methodsRoot.sections[0].sections);

writeToOutput();

function parseBy(string, sep, pos) {
  return string.split(sep)[pos];
}

function extractQueryParams(properties) {
  const params = [];
  properties.forEach(p => {
    params.push({
      name: p.key, // key.forEach ?
      description: p.description,
      required: ! p.optional,
      in: 'query',
      // schema: p.type ?
    })
  });
  return params;
}

function extractPathParams(path) {
  // /events/{id}
  const params = [];
  let indexStart;
  let indexEnd = 0;
  while (path.indexOf('{', indexEnd) > -1) {
    indexStart = path.indexOf('{', indexEnd);
    indexEnd = path.indexOf('}', indexStart);
    params.push(path.substring(indexStart+1, indexEnd));
  }
  return params;
}

// function extractRequestBody(path){
//  if (hasParams(method) && isPostorPut(httpMethod)) 

//}

function extractResponses(path){
  const responses = [];
  responses.push({
   'methods.result.http' :  //
    headers = properties.forEach(p => {
      params.push({
        //p.key: 
          //description: p.description,
          //schema: p.type,
        });
      }),
    });
  return responses;
}

function writeToOutput() {
  fs.writeFileSync(OUTPUT_FILE, yaml.stringify(api));
}

