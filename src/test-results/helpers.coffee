_ = require("lodash")

# Generic function to determine the in-doc id of a given section.
exports.getDocId = () ->
  return [].slice.apply(arguments).join('-').replace('.', '-')


exports.ucFirst = (str) ->
  return str.charAt(0).toUpperCase() + str.slice(1);




