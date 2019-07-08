generateId = require("cuid")

accessId = generateId();
requestId = generateId();

module.exports =
  record: [
    id: requestId,
    streamId: "#accessId/"+accessId,
    type: "audit/core",
    time: 1561988300,
    content: [
      forwarded_for: "172.18.0.7",
      action: "GET /events",
      username: "testuser2",
      query: "streamId=diary",
      access_id: accessId,
      status: 403,
      message: "Access session has expired.",
      error_id: "forbidden",
    ]
  ]
