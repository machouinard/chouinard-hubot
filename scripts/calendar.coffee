# Description:
#   Get a grid calendar
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   @10upbot calendar me (date)
#
# Author:
#   trepmal

module.exports = (robot) ->
  robot.respond /calendar me\s?(.*)?$/i, (msg) ->
    date = if msg.match[1] then msg.match[1] else ''
    msg.http("http://cal.trepmal.com/#{escape(date)}?bot")
    .get() (err,res,body) ->
      if res.statusCode == 404
        max = 0
      else
        msg.send '/quote ' + body
