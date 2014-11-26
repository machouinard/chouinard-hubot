# Description:
#   Generates memes via the Imgflip Meme Generator API
#
# Dependencies:
#   None
#
# Configuration:
#   IMGFLIP_API_USERNAME [optional, overrides default imgflip_hubot account]
#   IMGFLIP_API_PASSWORD [optional, overrides default imgflip_hubot account]
#
# Commands:
#   bob One does not simply <text> - Lord of the Rings Boromir
#   bob I don't always <text> but when i do <text> - The Most Interesting man in the World
#   bob aliens <text> - Ancient Aliens History Channel Guy
#   bob grumpy cat <text> - Grumpy Cat with text on the bottom
#   bob <text>, <text> everywhere - X, X Everywhere (Buzz and Woody from Toy Story)
#   bob Not sure if <text> or <text> - Futurama Fry
#   bob Y U NO <text> - Y U NO Guy
#   bob Brace yourselves <text> - Brace Yourselves X is Coming (Imminent Ned, Game of Thrones)
#   bob <text> all the <text> - X all the Y
#   bob <text> that would be great - Bill Lumbergh from Office Space
#   bob <text> too damn <text> - The rent is too damn high
#   bob Yo dawg <text> so <text> - Yo Dawg Heard You (Xzibit)
#   bob <text> you're gonna have a bad time - Super Cool Ski Instructor from South Park
#   bob Am I the only one around here <text> - The Big Lebowski
#   bob What if I told you <text> - Matrix Morpheus
#   bob <text> ain't nobody got time for that
#   bob <text> I guarantee it - George Zimmer
#   bob <text> and it's gone - South Park Banker Guy
#   bob <text> nobody bats an eye <text> everyone loses their minds - Heath Ledger Joker
#   bob back in my day <text> - Grumpy old man
#   bob <text> but that's none of my business - But That's None of My Business
#   bob do you want to <text> because that's how you <text> - Archer
#   bob <text> and at this point I'm afraid to ask - Andy Dwyer
#   bob <text> you da real MVP
#
# Author:
#   dylanwenzlau, stevegrunwell


inspect = require('util').inspect

module.exports = (robot) ->
  unless robot.brain.data.imgflip_memes?
    robot.brain.data.imgflip_memes = [
      {
        regex: /(one does not simply) (.*)/i,
        template_id: 61579
      },
      {
        regex: /(i don'?t always .*) (but when i do,? .*)/i,
        template_id: 61532
      },
      {
        regex: /aliens ()(.*)/i,
        template_id: 101470
      },
      {
        regex: /grumpy cat ()(.*)/i,
        template_id: 405658
      },
      {
        regex: /(.*),? (\1 everywhere)/i,
        template_id: 347390
      },
      {
        regex: /(not sure if .*) (or .*)/i,
        template_id: 61520
      },
      {
        regex: /(y u no) (.+)/i,
        template_id: 61527
      },
      {
        regex: /(brace yoursel[^\s]+) (.*)/i,
        template_id: 61546
      },
      {
        regex: /(.*) (all the .*)/i,
        template_id: 61533
      },
      {
        regex: /(.*) (that would be great|that'?d be great)/i,
        template_id: 563423
      },
      {
        regex: /(.*) (\w+\stoo damn .*)/i,
        template_id: 61580
      },
      {
        regex: /(yo dawg .*) (so .*)/i,
        template_id: 101716
      },
      {
        regex: /(.*) (.* gonna have a bad time)/i,
        template_id: 100951
      },
      {
        regex: /(am i the only one around here) (.*)/i,
        template_id: 259680
      },
      {
        regex: /(what if i told you) (.*)/i,
        template_id: 100947
      },
      {
        regex: /(.*) (ain'?t nobody got time for? that)/i,
        template_id: 442575
      },
      {
        regex: /(.*) (i guarantee it)/i,
        template_id: 10672255
      },
      {
        regex: /(.*) (a+n+d+ it'?s gone)/i,
        template_id: 766986
      },
      {
        regex: /(.* bats an eye) (.* loses their minds?)/i,
        template_id: 1790995
      },
      {
        regex: /(back in my day) (.*)/i,
        template_id: 718432
      },
      {
        regex: /(.*) (but that'?s none of my business)/i,
        template_id: 16464531
      },
      {
        regex: /(do you want to .*) (because that'?s how you .*)/i,
        template_id: 10628640
      },
      {
        regex: /(.*) (and at this point i'?m afraid to ask)/i,
        template_id: 22590034
      },
      {
        regex: /(.*) (you (?:da|the) real mvp)/i,
        template_id: 15878567
      }
    ]

  for meme in robot.brain.data.imgflip_memes
    setupResponder robot, meme

setupResponder = (robot, meme) ->
  robot.respond meme.regex, (msg) ->
    generateMeme msg, meme.template_id, msg.match[1], msg.match[2]

generateMeme = (msg, template_id, text0, text1) ->
  username = process.env.IMGFLIP_API_USERNAME
  password = process.env.IMGFLIP_API_PASSWORD

  if (username or password) and not (username and password)
    msg.reply 'To use your own Imgflip account, you need to specify username and password!'
    return

  if not username
    username = 'imgflip_hubot'
    password = 'imgflip_hubot'

  msg.http('https://api.imgflip.com/caption_image')
  .query
      template_id: template_id,
      username: username,
      password: password,
      text0: text0,
      text1: text1
  .post() (error, res, body) ->
    if error
      msg.reply "I got an error when talking to imgflip:", inspect(error)
      return

    result = JSON.parse(body)
    success = result.success
    errorMessage = result.error_message

    if not success
      msg.reply "Imgflip API request failed: #{errorMessage}"
      return

    msg.send result.data.url