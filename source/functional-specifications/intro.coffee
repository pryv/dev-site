
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (sectionId) ->
  return helpers.getDocId("introduction", sectionId)

module.exports = exports =
  id: "introduction"
  title: "Introduction"
  description: """
                This document describes the functional specifications for the pryv.io
                middleware system: the capabilities and functions that the
                system must be capable of performing.
               """