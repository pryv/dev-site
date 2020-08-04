const methodsRoot = require('../rendered/methods');
const dataStructureRoot = require('../rendered/data-structure');
const yaml = require('yaml');
const fs = require('fs');
const metadata = require('./metadata');
const metadata_open = require('./metadata_open');
const removeNulls = require('./cleanup').removeNulls;
const _ = require('lodash');

const OUTPUT_FILE = 'open-api-format/api.yaml';
const OUTPUT_FILE_PUBLIC = '../source/open-api/3.0/api.yaml';

const OUTPUT_FILE_OPEN = 'open-api-format/api_open.yaml';
const OUTPUT_FILE_PUBLIC_OPEN = '../source/open-api/3.0/api_open.yaml';

const dataStructureMap = {};
dataStructureRoot.sections.forEach(s => {
  dataStructureMap[s.id] = s;
});

let api_enterprise = metadata;
api_enterprise.paths = {};

let api_open = metadata_open;
api_open.paths = {};

// SCHEMAS (DATA STRUCTURES)
function createSchemas() {
  let schemas = {};

  dataStructureRoot.sections.forEach(ds => {
    let struct = {};
    if (ds.properties != null) {
      struct.type = 'object';
      struct.properties = {};
      ds.properties.forEach(p => {
        struct.properties[p.key] = {
          uniqueItems: p.unique,
          readOnly: p.readOnly,
          required: p.optional ? null : true,
          description: p.description,
        }
        _.merge(struct.properties[p.key], parseType(p));
      });
    }

    if (ds.id === 'identifier') {
      struct.type = 'string';
    }
    if (ds.id === 'timestamp') {
      struct.type = 'number';
    }
    if (ds.id === 'key-value') {
      struct.type = 'object';
      struct.additionalProperties = true;
    }

    schemas[ds.id] = struct;
  });
  return schemas;
}




api_enterprise.components = {
  schemas: createSchemas(),
};

api_open.components = {
  schemas: createSchemas(),
};

// Write api for Open-Pryv.io
buildApi(api_open, true);
api_open = removeNulls(api_open);
writeToOutputOpen();

// Write api for Pryv.io
buildApi(api_enterprise, false);
api_enterprise = removeNulls(api_enterprise);
writeToOutputEnterprise();

function translateSchemaLink(type) {
  return '#/components/schemas/' + type;
}

function parseType(property) {

  let typeToMerge = {};
  let struct = parseDataStructName(property.type, 1);

  // array
  if (isArray(property.type)) {
    typeToMerge = {
      type: 'array',
      items: {}
    }
    const type = parseArrayType(property.type);
    if (struct) {
      // referenced component
      typeToMerge.items.type = {
        $ref: translateSchemaLink(struct)
      };
    } else {
      // primary type
      typeToMerge.items.type = type;
    }
  } else if (isEnum(property.type)) {
    typeToMerge.schema = {
      type: 'string',
      enum: parseEnum(property.type)
    };

  } else {
    if (struct) {
      // referenced component
      typeToMerge = {
        '$ref': translateSchemaLink(struct)
      };
    } else {
      // primary type
      typeToMerge.type = property.type;
    }
  }
  return typeToMerge;
}

function isEnum(type) {
  return type.indexOf('|') >= 0;
}

function parseEnum(type) {
  const enums = type.split('|');
  return enums.map(e => {
    return e.substring(1, e.length - 1);
  });
}

function parseArrayType(type) {
  return parseBy(type, ' ', 2, 3);
}

function isArray(type) {
  return type.startsWith('array of');
}

/**
 * checks if the provided text is a data structure definition:
 * - returns false if it is not
 * - returns the data structure id if yes
 * - removes endPad letters from the end of the string. This is useful when it ends by ")"
 */
function parseDataStructName(text, endPad) {
  const token = '#data-structure-';
  let tokenLength = token.length;
  const startIndex = text.indexOf(token);
  if (startIndex < 0) return false;

  let schemaIndex = startIndex + tokenLength;
  const schema = text.substring(schemaIndex, text.length - endPad);
  return schema;
}

// METHODS

function toBeSkipped(methodId) {
  switch (methodId) {
    case 'mfa.login':
    case 'hfs.create':
    case 'hfs.update':
    case 'hfs.delete':
      return true;
      break;
    default:
      return false;
  }
}

function buildApi(api, isOpen) {
  methodsRoot.sections.forEach(section => {
    if (section.entrepriseOnly && isOpen) {
      return;
    }
    function helper(method) {
      const path = parseBy(method.http, ' ', 1);
      if (api.paths[path] == null) {
        api.paths[path] = {};
      }

      const httpMethod = parseBy(method.http, ' ', 0).toLowerCase();

      if (toBeSkipped(method.id)) {
        return;
      }

      api.paths[path][httpMethod] = {
        description: method.description,
        operationId: method.id,
        parameters: [],
        responses: [],
      };

      function isGetOrDelete(verb) {
        return verb == 'get' || verb == 'delete';
      }
      function isPostorPut(verb) {
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
          method.result = [method.result];
        }
        api.paths[path][httpMethod].responses = extractResult(method)
      }
      // handle responses - errors
      if (hasError(method)) {
        api.paths[path][httpMethod].responses = api.paths[path][httpMethod].responses.concat(extractError(method))
      }
      // make responses unique per HTTP status (currently overwriting previous responses)
      api.paths[path][httpMethod].responses = responsesPerStatus(api.paths[path][httpMethod].responses);


      // special cases
      switch (path) {
        case '/auth/login':
          api.paths[path][httpMethod].parameters.push({
            in: 'header',
            name: 'Origin',
            schema: {
              type: 'string',
              format: 'uri'
            },
            required: true
          });
          const props = api.paths[path][httpMethod].requestBody.content[
            'application/json'
          ].schema.properties;
          break;
      }
    }
    if (!section.sections) {
      helper(section)
    }
    else {
      section.sections.forEach(method => {
        helper(method);
      });
    }

  });
}


function responsesPerStatus(responses) {
  const objectResponses = {};
  let status;
  responses.forEach(r => {
    status = Object.keys(r)[0];
    objectResponses[status] = r[status];
  })
  return objectResponses;
}

function extractError(method) {

  const errors = method.errors;
  const responses = [];
  if (!errors) return responses;

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
      schemaItems.push(arrayOrNotSingle(p.type));
    });
    return schemaItems;
  }
}

// if array, type=array, type is extracted
// if not array, just returns $ref
function arrayOrNotSingle(type) {
  let schema = {};
  if (type.startsWith('array of')) {
    schema.type = 'array';
    schema.items = parseBy(type, ' ', 2, 3);
  } else {
    if (parseDataStructName(type, 1)) {
      schema['$ref'] = parseDataStructName(type, 1) ? translateSchemaLink(parseDataStructName(type, 1)) : type
    } else {
      schema.type = type;
    }
  }
  return schema;
}

function parseBy(string, sep, pos, end) {
  if (end) {
    return string.split(sep).splice(pos, end + 1).join(' ');
  }
  return string.split(sep)[pos];
}

function extractQueryParams(properties) {
  const params = [];
  properties.forEach(p => {
    if (p.key === 'id') return;

    params.push({
      name: p.key,
      description: p.description,
      required: !p.optional,
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
    if (param.http != null &&
      param.http.text &&
      param.http.text === 'set in request path') {
      return;
    }
    if (param.key === 'update') {
      return;
    }
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
    params.push(path.substring(indexStart + 1, indexEnd));
  }
  return params;
}

function extractResponses(path) {
  const responses = [];
  responses.push({
    'methods.result.http':  //
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

function writeToOutputEnterprise() {
  fs.writeFileSync(OUTPUT_FILE, yaml.stringify(api_enterprise));
  fs.writeFileSync(OUTPUT_FILE_PUBLIC, yaml.stringify(api_enterprise));
}

function writeToOutputOpen() {
  fs.writeFileSync(OUTPUT_FILE_OPEN, yaml.stringify(api_open));
  fs.writeFileSync(OUTPUT_FILE_PUBLIC_OPEN, yaml.stringify(api_open));
}