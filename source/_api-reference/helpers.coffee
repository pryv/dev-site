_ = require("lodash")

# Generic function to determine the in-doc id of a given section.
exports.getDocId = () ->
  return [].slice.apply(arguments).join('-').replace('.', '-')

exports.getCurlCall = (params, http) ->
  [method, path] = http.split(" ")

  request = if method != "GET" then "-X #{method} " else ""

  processedParams = _.clone(params)
  Object.keys(params).forEach (k) ->
    newPath = path.replace("{#{k}}", params[k])
    if path != newPath
      path = newPath
      delete processedParams[k]

  queryString = "?auth={access-token}"
  data = ""
  if method == "GET"
    Object.keys(processedParams).forEach (k) ->
      queryString += "&#{k}=#{processedParams[k]}"
  else if method == "PUT" && processedParams.update
    data = "-d '#{JSON.stringify(processedParams.update)}' "
  else
    data = "-d '#{JSON.stringify(processedParams)}' "

  return "curl -i #{request}#{data}https://{username}.pryv.io#{path}#{queryString}"
