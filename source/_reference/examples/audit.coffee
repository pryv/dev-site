generateId = require("cuid")

accessId = generateId();
requestId = generateId();

module.exports =
  record: [
    type: "audit/core",
    time: 1561988300,
    content: [
      forwarded_for: "172.18.0.7:40150",
      action: "GET /events",
      username: "testuser2",
      query: "fromTime=-1000000000,toTime=10000000000,limit=100,modifiedSince=-100000000,state=all",
      request_id: requestId,
      iso_date: "2019-07-01T13:38:20",
      authorization_hash: "$rscrypt$0$DwgB$0000000000000$/smSx0lnK4B+NC9fGEaHina9pmYObdi0P+DscXO8kic=$",
      access_id: accessId,
      status: 200,
      message: "Request was successful."
    ]
  ]
