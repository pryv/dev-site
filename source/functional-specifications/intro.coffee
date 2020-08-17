
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (sectionId) ->
  return helpers.getDocId("introduction", sectionId)

module.exports = exports =
  id: "introduction"
  title: "Introduction"
  description: """
                |                          |                          |
                | ------------------------ | ------------------------ |
                | Date                     | 17th June 2020             |
                | Documents Version        | 0.2                      |
                | API-Version              | 1.5.8                   |
                
                 This document describes the functional specifications for the Pryv.io
                middleware system: the capabilities and functions that the
                system must be capable of performing.

                This document applies only to Pryv.io releases under Enterprise License.

                This document does not apply to Open Pryv.io release.
               """