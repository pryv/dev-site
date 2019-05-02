
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (sectionId) ->
  return helpers.getDocId("terms", sectionId)

module.exports = exports =
  id: "terms"
  title: "Terms and acryonyms"
  intro: "Youpla boum"
  sections: []
  properties: [
    key: "Access"
    description: """
                  a set of access permissions; the access is identified... .
                  """
  ,
    key: "Access Token"
    description: """
                  a string...
                  """
  ]
