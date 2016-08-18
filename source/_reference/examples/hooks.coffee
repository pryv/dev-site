timestamp = require("unix-timestamp")
generateId = require("cuid")
accesses = require("./accesses")
streams = require("./streams")

module.exports =
  process:
    name: 'p1'
    code: 'this.batch = [{ method: \'event.get\', params: {limit: 1}}]'

