const methodsRoot = require('../transpiled/methods');
const dataStructureRoot = require('../transpiled/data-structure');
const yaml = require('yaml');
const fs = require('fs');
const metadata = require('./metadata');
const removeNulls = require('./cleanup').removeNulls;

const OUTPUT_FILE = 'open-api-format/api.yaml';

const dataStructureMap = {};
dataStructureRoot.sections.forEach(s => {
  dataStructureMap[s.id] = s;
})

let api = metadata;
api.paths = {};


// SCHEMAS (DATA STRUCTURES)

const schemas = {};

dataStructureRoot.sections.forEach(ds => {
  const struct = {
    type: 'object',
    properties: {}
  };
  if (ds.properties != null) {
    ds.properties.forEach(p => {
      struct.properties[p.key] = {
        uniqueItems: p.unique,
        readOnly: p.readOnly,
        required: p.optional ? null : true,
        description: p.description,
        '$ref': parseDataStructName(p.type, 1) ? translateSchemaLink(parseDataStructName(p.type, 1)) : null,
      }
    });
  }
  
  schemas[ds.id] = struct;
});

api.components = {
  schemas: schemas,
};

function translateSchemaLink(type) {
  return '#/components/schemas/' + type;
}

// METHODS

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
      //api.paths[path][httpMethod].requestBody = dataStructureMap[parseDataStructName(method.params.description, 2)];
      api.paths[path][httpMethod].requestBody = {
        description: parseBy(method.params.description, ':', 0),
        required: true,
        content: {
          'application/json': {
            schema: {
              $ref: translateSchemaLink(parseDataStructName(method.params.description, 2))
            }
          }
        }
      }
    };

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

api = removeNulls(api);
writeToOutput();

// parses 
function parseDataStructName(text, endPad) {
  const token = '#data-structure-';
  let tokenLength = token.length;
  const startIndex = text.indexOf(token);
  if (startIndex < 0) return false;
  
  let schemaIndex = startIndex + tokenLength;
  const schema = text.substring(schemaIndex, text.length - endPad);
  return schema;
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

  // if array, type=array, type is extracted
  // if not array, just returns $ref
  function arrayOrNotSingle(props) {
    let schema = {};
    if (props.type.startsWith('array of')) {
      schema.type = 'array';
      schema.items = parseBy(props.type, ' ', 2, 3);
    } else {
      schema = {
        // "[stream](#data-structure-stream)"
        $ref: parseDataStructName(props.type, 1) ? translateSchemaLink(parseDataStructName(props.type, 1)) : props.type,
      };
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
