
module.exports = (robot) ->
  robot.hear /!hank/i, (msg) ->
    range = Math.floor(Math.random() * (14 - 1) + 1)
    link  = "http://chouinard.me/images/henry/#{range}.jpg"
    msg.send link