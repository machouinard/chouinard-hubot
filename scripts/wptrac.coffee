# Description:
#   WordPress Trac interaction script
#
# Dependencies:
#   "xml2js": "0.1.14"
#
# Configuration:
#   HUBOT_WPTRAC_URL: https://core.trac.wordpress.org
#   HUBOT_WPTRAC_USER:
#   HUBOT_WPTRAC_PASSWORD:
#
# Optional Configuration:
#   HUBOT_WPTRAC_JSONRPC: "true" to use the Trac http://trac-hacks.org/wiki/XmlRpcPlugin.
#                       Requires jsonrpc to be enabled in the plugin. Default to "true".
#   HUBOT_WPTRAC_SCRAPE: "true" to use HTTP scraping to pull information from Trac.
#                      Defaults to "true".
#   HUBOT_WPTRAC_LINKDELAY: number of seconds to not show a link for again after it's been
#                         mentioned once. This helps to cut down on noise from the bot.
#                         Defaults to 30.
#   HUBOT_WPTRAC_IGNOREUSERS: Comma-seperated list of users to ignore "hearing" issues from.
#                           This works well with other bots or API calls that post to the room.
#                           Example: "Subversion,TeamCity,John Doe"
# Commands:
#   #123 - Show details about a Trac ticket
#   r123 - Show details about a commit
#
# Notes:
#   Tickets pull from jsonrpc (if enabled), then scraping (if enabled), and otherwise just put a link
#   Revisions pull from scraping (if enabled), and otherwise just post a link. (There are no xmlrpc methods
#   for changeset data).
#
# Author:
#   adamsilverstein, original trac code by gregmac

process.env.HUBOT_WPTRAC_URL = 'https://core.trac.wordpress.org'

# keeps track of recently displayed issues, to prevent spamming
class RecentIssues
  constructor: (@maxage) ->
    @issues = []

  cleanup: ->
    for issue,time of @issues
      age = Math.round(((new Date()).getTime() - time) / 1000)
      if age > @maxage
        #console.log 'removing old issue', issue
        delete @issues[issue]
    return

  contains: (issue) ->
    @cleanup()
    @issues[issue]?

  add: (issue,time) ->
    time = time || (new Date()).getTime()
    @issues[issue] = time

module.exports = (robot) ->
  # if trac json-rpc is available to use for retreiving tickets (faster)
  useJsonrpc = false

  # if screen scraping can be used for tickets/changesets. If both jsonrpc and scrape are off, only a link gets posted
  useScrape = false;

  # how long (seconds) to wait between repeating the same link
  linkdelay = process.env.HUBOT_WPTRAC_LINKDELAY || 30

  # array of users that are ignored
  ignoredusers = (process.env.HUBOT_WPTRAC_IGNOREUSERS.split(',') if process.env.HUBOT_WPTRAC_IGNOREUSERS?) || []

  recentlinks = new RecentIssues linkdelay

  # fetch ticket information using scraping or jsonrpc
  fetchTicket = (msg) ->
    if (ignoredusers.some (user) -> user == msg.message.user.name)
      console.log 'ignoring user due to blacklist:', msg.message.user.name
      return

    if ( -1 != msg.message.text.indexOf( '&#' ) )
      console.log 'skipping match with `&#`, likely unicode'
      return

    for matched in msg.match
      ticket = (matched.match /\d{3}\d+/)[0]
      linkid = msg.message.user.room+'#'+ticket
      if !recentlinks.contains linkid
        recentlinks.add linkid
        console.log 'trac ticket link', ticket
        msg.http("#{process.env.HUBOT_WPTRAC_URL}/ticket/#{ticket}")
           .get() (err, res, body) ->
             try
                type = body.split( '<span class="trac-type">' )[1].split( '</span>' )[0].replace(/<(?:.|\n)*?>/gm, '').trim()
                status = body.split( '<span class="trac-status">' )[1].split( '</span>' )[0].replace(/<(?:.|\n)*?>/gm, '').   trim()
                scrapedtitle = body.split('<title>')[1].split('</title>')[0].replace('– WordPress Trac', '').trim()
                msg.send "Trac \##{ticket}: #{process.env.HUBOT_WPTRAC_URL}/ticket/#{ticket}"
                msg.send scrapedtitle + " -- " + type + " / " + status
             catch error
                console.log 'Unable to retrieve ticket'

  # listen for ticket numbers
  robot.hear /([^\w]|^)\#(\d+)(?=[^\w]|$)/ig, fetchTicket

  # listen for ticket links
  ticketUrl = new RegExp("#{process.env.HUBOT_WPTRAC_URL}/ticket/([0-9]+)", 'ig')
  robot.hear ticketUrl, fetchTicket

  # listen for changesets
  handleChangeset = (msg) ->
    if (ignoredusers.some (user) -> user == msg.message.user.name)
      console.log 'ignoring user due to blacklist:', msg.message.user.name
      return

    for matched in msg.match
      revision = (matched.match /\d+/)[0]

      linkid = msg.message.user.room+'r'+revision
      if !recentlinks.contains linkid
        recentlinks.add linkid
        console.log 'trac changset link', revision
        msg.http("#{process.env.HUBOT_WPTRAC_URL}/changeset/#{revision}")
           .get() (err, res, body) ->
              try
                 revisioninfo = body.split( '<dd class="message searchable">' )[1].split('</dd>')[0].replace(/<(?:.|\n)*?>/gm, '').replace('<p>', '').replace('</p>', '').replace('<br>', '').trim()
                 msg.send "Trac r#{revision}: #{process.env.HUBOT_WPTRAC_URL}/changeset/#{revision}"
                 msg.send revisioninfo
              catch error
                 console.log 'Unable to retrieve changeset'

  # trigger on "r123"
  robot.hear /([^\w]|^)trac r(\d+)(?=[^\w]|$)/ig, handleChangeset