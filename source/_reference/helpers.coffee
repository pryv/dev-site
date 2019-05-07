_ = require("lodash")

# Generic function to determine the in-doc id of a given section.
exports.getDocId = () ->
  return [].slice.apply(arguments).join('-').replace('.', '-')

exports.getCurlCall = (params, http, server) ->
  [method, path] = http.split(" ")
  if (server == null || server == undefined)
    server = "core"
  
  request = if method != "GET" then "-X #{method} " else ""

  headers = ""
  queryString = ""
  if (server == "core")
    if (method == "POST" && (path == "/auth/login" || path == "/account/request-password-reset" || path == "/account/reset-password"))
      headers = "-H 'Origin: https://sw.pryv.me' "
    else
      queryString = "?auth={token}"

  processedParams = _.clone(params)
  Object.keys(params).forEach (k) ->
    newPath = path.replace("{#{k}}", params[k])
    if path != newPath
      path = newPath
      delete processedParams[k]

  hasData = (method == "POST" || method == "PUT")
  if hasData
    headers += "-H 'Content-Type: application/json' "
  
  data = ""
  if not hasData
    Object.keys(processedParams).forEach (k) ->
      queryString += "&#{k}=#{processedParams[k]}"
  else if method == "PUT" && processedParams.update
    data += "-d '#{JSON.stringify(processedParams.update)}' "
  else
    data += "-d '#{JSON.stringify(processedParams)}' "
  
  call = ""
  if (server == "core")
    call = "curl -i #{request}#{headers}#{data}https://{username}.pryv.me#{path}#{queryString}"
  else if (server == "register")
    call = "curl -i #{request}#{headers}#{data}https://reg.pryv.me#{path}#{queryString}"
    
  
  # use shell variable format to help with quick copy-paste
  return call.replace /({\w+?})/g, (match) ->
    "$#{match}"

exports.getWebsocketCall = (params) -> 
  return JSON.stringify(params)

