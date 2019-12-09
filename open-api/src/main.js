const methodsRoot = require('../transpiled/methods');
const dataStructureRoot = require('../transpiled/data-structure');
const yaml = require('yaml');
const fs = require('fs');

const OUTPUT_FILE = 'open-api-format/api.yaml';

const dataStructureMap = {};
dataStructureRoot.sections.forEach(s => {
  dataStructureMap[s.id] = s;
})


const api = {
  paths: {},
};

methodsRoot.sections.forEach(section => {
  section.sections.forEach(method => {
    const path = parseBy(method.http, ' ', 1);
    if (api.paths[path] == null) {
      api.paths[path] = {};
    }

    const httpMethod = parseBy(method.http, ' ', 0).toLowerCase();

    api.paths[path][httpMethod] = {
      description: method.description,
      operationId: method.id,
      parameters: [], 
      responses: [],
    };

    // good response

    // erronous response

    function isGetOrDelete(verb) {
      return verb == 'get' || verb == 'delete';
    }
    function isPostorPut(verb){
      return verb == 'post' || verb == 'put';
    }
    function hasParams(method) {
      return method.params != null && method.params.properties != null;
    }
    function hasSchemaParams(method) {
      return method.params != null && method.params.description != null;
    }
    function hasResult(method) {
      return method.result != null;
    }
    function hasError(method) {
      return method.errors != null;
    }
    // handle body params
    if (hasParams(method) && isPostorPut(httpMethod)) {
      api.paths[path][httpMethod].requestBody = extractBodyParams(method.params.properties);
    }
    if (hasSchemaParams(method)) {
      api.paths[path][httpMethod].requestBody = buildSchemaParams(method.params.description);
    }

    // handle query params
    if (hasParams(method) && isGetOrDelete(httpMethod)) {
      const queryParamsRaw = extractQueryParams(method.params.properties);
      api.paths[path][httpMethod].parameters = api.paths[path][httpMethod].parameters.concat(queryParamsRaw);
    }
    
    // handle path params
    const pathParamsRaw = extractPathParams(path)
    const pathParams = [];
    pathParamsRaw.forEach(p => {
      pathParams.push({
        name: p,
      })
    })
  
    api.paths[path][httpMethod].parameters = api.paths[path][httpMethod].parameters.concat(pathParams);
    
    // handle responses - result
    if (hasResult(method)) {
      if (!Array.isArray(method.result)) {
        method.result = [ method.result ];
      }
      api.paths[path][httpMethod].responses = extractResult(method)
    }
    // handle responses - errors
    if (hasError(method)) {
      api.paths[path][httpMethod].responses = api.paths[path][httpMethod].responses.concat(extractError(method))
    }

  });
});

//console.log(methodsRoot.sections[0].sections);

writeToOutput();

// The new event's data: see [Event](#data-structure-event)
function buildSchemaParams(description) {
  const token = '#data-structure-';
  let tokenLength = token.length;
  let index = description.indexOf(token) + tokenLength;
  const schema = description.substring(index, description.length - 2);
  return dataStructureMap[schema];
}

function extractError(method) {
  
  const errors = method.errors;
  const responses = [];
  if (! errors) return responses;
  
  errors.forEach(e => {
    const response = {}
    response[e.http] = {
      description: e.key
    };
    responses.push(response);
  });
  return responses;
}

function extractResult(method) {

  const result = method.result
  const responses = [];
  result.forEach(r => {
    const status = parseBy(r.http, ' ', 0);
    const response = {}
    response[status] = {};

    if (r.description) {
      response[status].description = parseBy(r.http, ' ', 1);
    }
    if (r.properties) {
      response[status].content = {
        'application/json': {
          schema: arrayOrNot(r.properties)
        }
      }
    }
    responses.push(response);
  });
  
  return responses;

  function arrayOrNot(props) {
    const schemaItems = [];
    props.forEach(p => {
      schemaItems.push(arrayOrNotSingle(p));
    });
    return schemaItems;
  }

  function arrayOrNotSingle(props) {
    let schema = {};
    if (props.type.startsWith('array of')) {
      schema.type = 'array';
      schema.items = parseBy(props.type, ' ', 2, 3);
    } else {
      schema = {
        '$ref': props.type
      }
    }
    return schema;
  }
  
}


function parseBy(string, sep, pos, end) {
  if (end) {
    return string.split(sep).splice(pos, end+1).join(' ');
  }
  return string.split(sep)[pos];
}

function extractQueryParams(properties) {
  const params = [];
  properties.forEach(p => {
    params.push({
      name: p.key, 
      description: p.description,
      required: ! p.optional,
      in: 'query',
    })
  });
  return params;
}


function extractBodyParams(params) {
  const requestBody = {
    content: {
      'application/json': {
        schema: {
          type: 'object',
          properties: {}
        }
      }
    }
  };
  params.forEach(param => {
    requestBody.content['application/json'].schema.properties[param.key] = {
      description: param.description,
      type: param.type
    };
  });
  return requestBody;
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

