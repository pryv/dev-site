helpers = require("../helpers")
examples = require("../examples")
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (typeId) ->
  return helpers.getDocId("data-structure", typeId)

module.exports.followedSlice =
  id: "followed-slice"
  title: "Followed slice"
  trustedOnly: true
  description: """
                 See also: [core concepts](/concepts/#followed-slices).
                 """
  properties: [
    key: "id"
    type: "[identifier](##{_getDocId("identifier")})"
    unique: true
    readOnly: true
    description: """
                   The server-assigned identifier for the followed slice.
                   """
  ,
    key: "name"
    type: "string"
    unique: true
    description: """
                   A name identifying the followed slice for the user.
                   """
  ,
    key: "url"
    type: "URL"
    description: """
                   The URL of the API endpoint of the account hosting the slice. Not modifiable after creation.
                   """
  ,
    key: "accessToken"
    type: "string"
    description: """
                   The token of the shared access itself. Not modifiable after creation.
                   """
  ]
  examples: []