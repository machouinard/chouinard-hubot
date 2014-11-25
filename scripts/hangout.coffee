# Description:
#   Dear Google: Please don't ever make this stop working.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   @bob hangout me
#
# Author:
#   helen

module.exports = (robot) ->
  robot.respond /hangout me$/i, (msg) ->
    output = ""
    output += Math.random().toString(36).substr(2) while output.length < 8
    output.substr 0, 8
    msg.send "@" + msg.message.user.mention_name + " https://plus.google.com/hangouts/_/chouinard.me/" + output