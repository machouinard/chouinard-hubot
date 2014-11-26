# Description:
#   Not approve
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   !disapprove
#
# Author:
#   zamoose

links = [
  'http://verynoice.com/wp-content/uploads/2010/11/voice-do-not-approve.jpg',
  'http://img.pandawhale.com/51562-Breaking-bad-upvote-gif-Zx9m.gif',
  'http://mrwgifs.com/wp-content/uploads/2013/03/Magnum-P.I.-Does-Not-Approve-Reaction-Gif.gif',
  'http://media.tumblr.com/tumblr_lm0gmqRgOR1qdlkgg.gif',
  'https://s3.amazonaws.com/uploads.hipchat.com/52421/487588/nkQX7MyS06zzWtI/upset-cosby.gif',
  'https://s3.amazonaws.com/uploads.hipchat.com/52421/487588/jOpsGDfHwfdV1F6/uh-uh-nope.gif',
  'https://i.chzbgr.com/maxW500/4088691968/hA8D516C0.jpg',
  'http://media.giphy.com/media/3yxADC4jE5W4E/giphy.gif',
  'http://www.operatorchan.org/t/src/14064641777.gif',
  'http://37.media.tumblr.com/tumblr_lngwe0VJn41qd5hy5o1_400.gif',
  'http://photo1.ask.fm/124/181/767/90003009-1r9lrpb-8fcrtjrj1mf41fp/preview/file.jpg'
  ]

module.exports = (robot) ->
  robot.hear /^!disapprove\b/i, (msg) ->
    link = msg.random links
    msg.send link
