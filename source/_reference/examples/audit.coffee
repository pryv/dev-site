generateId = require("cuid")

accessId = generateId();

module.exports =
  auth: generateId(),
  log1:
    id: generateId(),
    streamId: "#accessId/"+accessId,
    type: "audit/core",
    time: 1561988300,
    content:
      forwardedFor: "172.18.0.7",
      action: "GET /events",
      username: "testuser2",
      query: "streamId=diary",
      accessId: accessId,
      status: 403,
      message: "Access session has expired.",
      errorId: "forbidden",
  log2:
    id: generateId(),
    streamId: "#accessId/"+accessId,
    type: "audit/core",
    time: 1561988900,
    content:
      forwardedFor: "172.18.0.7",
      action: "GET /events",
      username: "testuser2",
      query: "streamId=diary",
      accessId: accessId,
      status: 403,
      message: "Access session has expired.",
      errorId: "forbidden",
  log3:
    id: generateId(),
    streamId: "#accessId/"+accessId,
    type: "audit/core",
    time: 1561989200,
    content:
      forwardedFor: "172.18.0.7",
      action: "GET /events",
      username: "testuser2",
      query: "streamId=work",
      accessId: accessId,
      status: 403,
      message: "Access session has expired.",
      errorId: "forbidden",
