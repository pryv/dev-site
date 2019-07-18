generateId = require("cuid")

accessId = generateId();

module.exports =
  auth: generateId(),
  log1:
    id: generateId(),
    type: "audit/core",
    time: 1561988300,
    forwardedFor: "172.18.0.7",
    action: "GET /events",
    query: "streamId=diary",
    accessId: accessId,
    status: 403,
    errorMessage: "Access session has expired.",
    errorId: "forbidden",
  log2:
    id: generateId(),
    type: "audit/core",
    time: 1561988900,
    forwardedFor: "172.18.0.7",
    action: "GET /events",
    query: "streamId=diary",
    accessId: accessId,
    status: 403,
    errorMessage: "Access session has expired.",
    errorId: "forbidden",
  log3:
    id: generateId(),
    type: "audit/core",
    time: 1561989200,
    forwardedFor: "172.18.0.7",
    action: "GET /events",
    query: "streamId=work",
    accessId: accessId,
    status: 403,
    errorMessage: "Access session has expired.",
    errorId: "forbidden",
