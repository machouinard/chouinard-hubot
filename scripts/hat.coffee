# Description:
#   Anything's a Hat
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   !hat
#
# Author:
#   helenhousandi

links = [
  'https://s3.amazonaws.com/uploads.hipchat.com/52421/848041/eCGCAvRf88Bz0id/hat_hank_scuba.jpg',
  'http://chouinard.me/images/henry/9.jpg'
  ]

module.exports = (robot) ->
  robot.hear /^!hat\b/i, (msg) ->
    link = msg.random links
    msg.send link
