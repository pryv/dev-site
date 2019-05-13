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