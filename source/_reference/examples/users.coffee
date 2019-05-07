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
    username: "morgespatient"
    password: "o1i23oin1o2i3n"
    email: "morgespatient@" + register.platforms[0]
    language: "en"