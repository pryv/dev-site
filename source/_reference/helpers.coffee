_ = require("lodash")

# Generic function to determine the in-doc id of a given section.
exports.getDocId = () ->
  return [].slice.apply(arguments).join('-').replace('.', '-')

exports.getCurlCall = (params, http, server, hasQueryAuth) ->
  [method, path] = http.split(" ")
  if (server == null || server == undefined)
    server = "core"
  
  request = if method != "GET" then "-X #{method} " else ""
  headers = ""
  queryString = ""
  basicAuth = ""
  if (server == "core")
    if (method == "POST" && (
      path == "/auth/login" || 
      path == "/account/request-password-reset" || 
      path == "/account/reset-password" || 
      path == "/mfa/recover"
    ))
      headers = "-H 'Origin: https://sw.pryv.me' "
    else 
      if (hasQueryAuth)
        queryString = "?auth={token}"
      else
        basicAuth = "{token}@"

  processedParams = _.clone(params)
  Object.keys(params).forEach (k) ->
    newPath = path.replace("{#{k}}", params[k])
    if path != newPath
      path = newPath
      delete processedParams[k]

  data = ""
  hasData = (method == "POST" || method == "PUT")
  if hasData
    headers += "-H 'Content-Type: application/json' "
    if method == "PUT" && processedParams.update
      data += "-d '#{JSON.stringify(processedParams.update)}' "
    else
      data += "-d '#{JSON.stringify(processedParams)}' "
  else 
    Object.keys(processedParams).forEach (k) ->
      queryString += "&#{k}=#{processedParams[k]}"
  
  call = ""
  if (path == "/users")
   call = "curl -i #{request}#{headers}#{data}\"https://<span class=\"core-reg-curl\">{core-subdomain}</sapan>.pryv.me</span>#{path}#{queryString}\""
  else if (server == "core")
    call = "curl -i #{request}#{headers}#{data}\"https://#{basicAuth}<span class=\"api-curl\">{username}.pryv.me</span>#{path}#{queryString}\""
  else if (server == "register")
    call = "curl -i #{request}#{headers}#{data}\"https://<span class=\"api-reg-curl\">reg.pryv.me</span>#{path}#{queryString}\""
  else if (server == "admin")
    call = "curl -i #{request}#{headers}#{data}\"https://<span class=\"api-admin-curl\">lead.pryv.me</span>#{path}#{queryString}\""
    
  
  # use shell variable format to help with quick copy-paste
  return call.replace /({\w+?})/g, (match) ->
    "$#{match}"

exports.getWebsocketCall = (params) -> 
  return JSON.stringify(params)

exports.getBatchBlock = (methodId, params) -> 
  return JSON.stringify({method: methodId, params: params}, null, 2)

