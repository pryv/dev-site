generateId = require("cuid")
register = require("./register")

module.exports =
  one:
    id: generateId()
    username: "chuangzi"
    password: "B|_|tt3rfly!"
    email: "chuangzi@dao.info"
    language: "zh"
  two:
    id: generateId()
    username: "jerome"
    password: "ChjUzDXwaTG2qdV"
    email: "jerome@" + register.platforms[0]
    language: "en"
  three:
    username: "user1"
    email: "user1@gmail.com"
    language: "en"
    invitationToken: "enjoy"
    referer: "null"
    id: generateId()
    registeredTimestamp: "1557743399558"
    server: register.platforms[0]
    errors: []
    registeredDate: "Mon, 13 May 2019 10:29:59 GMT"
  four:
    username: "user2"
    email: "user2@gmail.com"
    language: "fr"
    invitationToken: "enjoy"
    referer: "null"
    id: generateId()
    registeredTimestamp: "1536930239805"
    server: register.platforms[1]
    errors: []
    registeredDate: "Fri, 14 Sep 2018 13:03:59 GMT"