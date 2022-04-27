
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (sectionId) ->
  return helpers.getDocId("terms", sectionId)

module.exports = exports =
  id: "terms"
  title: "Terms and acryonyms"
  sections: []
  properties: [
    key: "Access"
    description: """
                  A set of permissions relative to a user account resources. The access is identified 
                  by an Access Id and presented to the API as an Access token.  
                  See [Accesses concept](/concepts/#accesses).
                  """
  ,
    key: "Access Token"
    description: """
                  A string of characters used for transacation that require Authorization. An acces token
                  is linked to one Access Token, the content of a token must remain a secret and is set along with each request. Access Tokens are the primary identifier for the AUTHOR of an API call.
                  """
  , 
    key: "Data Subject"
    description: """
                  As part of personal data reglementations and policies such as GDPR or HIPAA, refers to any individual who can be identified directly or indirectly by a subset of data, either identifier or factors specific to a person’s identity. By extension, the person whose data is collected, held or processed.  

                  On Pryv.io, each individual's data is held on a per Data Subject **User Account**. Data Subject is also refered as **User**.
                  """
    

  ]
