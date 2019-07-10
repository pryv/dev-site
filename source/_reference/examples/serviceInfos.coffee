timestamp = require("unix-timestamp")

module.exports =
  infos:
    version: "0.1.0"
    register: "https://reg.pryv.li"
    access: "https://access.pryv.li/access"
    api: "https://{username}.pryv.li/"
    name: "Pryv Lab staging"
    home: "https://www.pryv.com"
    support: "https://pryv.com/helpdesk"
    terms: "https://pryv.com/pryv-lab-terms-of-use/"
    eventTypes: "https://api.pryv.com/event-types/flat.json"
    data:
      android: ""
      iOS: ""
      anyContent: "my content"
    meta: 
      apiVersion: "1.4.10-16-g39b458b"
      serverTime: timestamp.now()
      serial: "2019063001"
