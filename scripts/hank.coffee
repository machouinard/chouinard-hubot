# Description:
#   Images of Henry
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   !hank
#
# Author:
#   machouinard


module()exports = (robot) ->
  robot.hear /^!hank\b/i, (msg) ->
    num = Math.random() * (14 - 1) + 1
    link = "http://chouinard.me/images/henry/#{num}!.jpg"
    msg.send link
