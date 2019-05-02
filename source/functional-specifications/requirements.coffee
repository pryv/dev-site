
_ = require("lodash")

# For use within the data declaration here; external callers use `getDocId` (which checks validity)
_getDocId = (sectionId) ->
  return helpers.getDocId("Functional Requirements", sectionId)

module.exports = exports =
  id: "Functional Requirements"
  title: "Functional Requirements"
  description: """
                This section describes the functional requirements associated with a specific feature. Each functional requirement specifies functions that a system or component must be able to perform and that must be present for the user to be able to use the services provided by the feature.
               """
  sections: [
    id: "Overall Description"
    title: "Overall Description"
    description: """
                 Pryv.io is a middleware which aims to provide ease personal data management.
                As a middleware, Pryv.io does not provide User Interfaces (UI), nor physical storage or infrastructure.
                The system is composed of a few components being:

                1. One to several core components: responsible for the core functionalities like data storage, access control.

                2.	Two to several register component: responsible for linking a data subject’s storage to the corresponding core component responsible for the data management.

                 """
  , 
    id: "connectivity and interfaces"
    title: "Connectivity and interfaces"
    requirements: [
      id: "REQ_CON_01"
      title: "The system shall be accessible through an HTTP API",
      description: "Access to the system is done using a Web API."
    ]
  , 
     id: "data types"
     title: "Data Types"
     requirements: [
       id: "REQ_DATA_01"
       title: "The system shall provide default  data types."
       description: "Default data types are available in the system."
      ,
       id: "REQ_DATA_02"
       title: "The system shall accept custom data types."
       description: "It is possible to define custom data types."
     ]
  ]
