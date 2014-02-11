# Generic function to determine the in-doc id of a given section.
exports.getDocId = () ->
  return [].slice.apply(arguments).join('-').replace('.', '-')

exports.changeTrackingProperties = (typeName) ->
  return [
    key: "created"
    type: "[timestamp](#data-structure-timestamp)"
    readOnly: true
    description: "The time the #{typeName} was created."
  ,
    key: "createdBy"
    type: "[identity](#data-structure-identity)"
    readOnly: true
    description: "The id of the access used to create the #{typeName}."
  ,
    key: "modified"
    type: "[timestamp](#data-structure-timestamp)"
    readOnly: true
    description: "The time the #{typeName} was last modified."
  ,
    key: "modifiedBy"
    type: "[identity](#data-structure-identity)"
    readOnly: true
    description: "The id of the last access used to modify the #{typeName}."
  ]
