map = module.exports = exports =
  "about": "/about.html"
  "appAccess": "/app-access.html"
  "appsAndServices": "/apps-and-services.html"
  "codeLibraries": "/code-libraries.html"
  "concepts": "/concepts.html"
  "home": "/dev-index.html"
  "eventTypes": "/event-typez.html"
  "reference": "/reference.html"
  "standardStructure": "/standard-structure.html"

# Every page should use this if possible for safe internal links (fallback to map above otherwise)
exports.linkTo = (pageId) ->
  return map[pageId] || throw new Error("Bad page id '#{pageId}'")
