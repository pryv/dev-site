generateId = require("cuid")

accessId = generateId();

module.exports =
  auth: generateId(),
  record1:
    id: generateId(),
    streamId: "#accessId/"+accessId,
    type: "audit/core",
    time: 1561988300,
    content:
      forwarded_for: "172.18.0.7",
      action: "GET /events",
      username: "testuser2",
      query: "streamId=diary",
      access_id: accessId,
      status: 403,
      message: "Access session has expired.",
      error_id: "forbidden",
  record2:
    id: generateId(),
    streamId: "#accessId/"+accessId,
    type: "audit/core",
    time: 1561988900,
    content:
      forwarded_for: "172.18.0.7",
      action: "GET /events",
      username: "testuser2",
      query: "streamId=diary",
      access_id: accessId,
      status: 403,
      message: "Access session has expired.",
      error_id: "forbidden",
  record3:
    id: generateId(),
    streamId: "#accessId/"+accessId,
    type: "audit/core",
    time: 1561989200,
    content:
      forwarded_for: "172.18.0.7",
      action: "GET /events",
      username: "testuser2",
      query: "streamId=work",
      access_id: accessId,
      status: 403,
      message: "Access session has expired.",
      error_id: "forbidden",
