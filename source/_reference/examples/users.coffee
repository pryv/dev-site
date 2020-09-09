generateId = require("cuid")
register = require("./register")

module.exports =
  one:
    id: generateId()
    username: "chuangzi"
    password: "B|_|tt3rfly!"
    email: "chuangzi@dao.info"
    language: "zh"
    storageUsed:
      dbDocuments: 34831
      attachedFiles: 12
  two:
    id: generateId()
    username: "user-123-abc"
    password: "ChjUzDXwaTG2qdV"
    email: "joseph-brenner@" + register.platforms[0]
    language: "en"
    storageUsed:
      dbDocuments: 355501
      attachedFiles: 1570208
    apiEndpoint:
      pryvLab: "https://user-123-abc.pryv.me/"
      ownDomain: "https://user-123-abc.${DOMAIN}/"
      dnsLess: "https://${HOSTNAME}/user-123-abc"
  three:
    username: "user1"
    email: "red.miller@mail.ch"
    language: "en"
    invitationToken: "enjoy"
    referer: "null"
    id: generateId()
    registeredTimestamp: "1557743399558"
    server: register.servers[0]
    registeredDate: "Mon, 13 May 2019 10:29:59 GMT"
  four:
    username: "user2"
    email: "user2@gmail.com"
    language: "fr"
    invitationToken: "enjoy"
    referer: "null"
    id: generateId()
    registeredTimestamp: "1536930239805"
    server: register.servers[1]
    registeredDate: "Fri, 14 Sep 2018 13:03:59 GMT"
  five:
    username: "user-123-abc"
    password: "ChjUzDXwaTG2qdV"
    email: "joseph-brenner@" + register.platforms[0]
    language: "en"
    storageUsed:
      dbDocuments: 355501
      attachedFiles: 1570208
    apiEndpoint:
      pryvLab: "https://{user-personal-token}@user-123-abc.pryv.me/"
      ownDomain: "https://{user-personal-token}@user-123-abc.${DOMAIN}/"
      dnsLess: "https://{user-personal-token}@${HOSTNAME}/user-123-abc"
  invalid:
    username: "abc"
    email: "invalid_email"
  reserved:
    username: "pryvpryv"