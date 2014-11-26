# Description:
#   Pics of Henry
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

module.exports = (robot) ->
  robot.respond /pang$/i, (msg) ->
    msg.send "pung"