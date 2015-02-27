# Description:
#   TriNet says: don't make jokes.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   !hrviolation > @jess
#   !hrviolation @jess
#
# Author:
#   helenhousandi

class HRViolation

  constructor: (@robot) ->
    @cache = {}

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.hrviolation
        @cache = @robot.brain.data.hrviolation

  kill: (thing) ->
    delete @cache[thing]
    @robot.brain.data.hrviolation = @cache

  increment: (thing) ->
    @cache[thing] ?= 0
    @cache[thing] += 1
    @robot.brain.data.hrviolation = @cache

  get: (thing) ->
    k = if @cache[thing] then @cache[thing] else 0
    return k

  sort: ->
    s = []
    for key, val of @cache
      s.push({ name: key, hrviolation: val })
    s.sort (a, b) -> b.hrviolation - a.hrviolation

  worst: (n = 5) ->
    sorted = @sort()
    sorted.slice(0, n)

  list: ->
    sorted = @sort()
    sorted.reverse()

module.exports = (robot) ->
  hrv = new HRViolation robot

  robot.hear /\!?hrviolation >? (@\S+)/i, (msg) ->
    subject = msg.match[1].toLowerCase()
    hrv.increment subject
    msg.send "#{subject}: HR VIOLATION REPORTED (You have #{hrv.get(subject)} reported violations)"

  robot.respond /\!?hrviolation empty ?(\S+[^-\s])$/i, (msg) ->
    subject = msg.match[1].toLowerCase()
    hrv.kill subject
    msg.send "#{subject} has been absolved of HR violations."

  robot.respond /\!?hrviolation worst?$/i, (msg) ->
    verbiage = ["Worst Offenders"]
    for item, rank in hrv.worst()
      verbiage.push "#{rank + 1}. #{item.name}: #{item.hrviolation}"
    msg.send verbiage.join("\n")

  robot.respond /\!?hrviolation list$/i, (msg) ->
    verbiage = ["Reported HR Violators"]
    for item, rank in hrv.list()
      verbiage.push "#{item.name}: #{item.hrviolation}"
    msg.send verbiage.join("\n")

  robot.respond /\!?hrviolation (\S+[^-\s])$/i, (msg) ->
    match = msg.match[1].toLowerCase()
    if match != "best" && match != "worst"
      msg.send "\"#{match}\" has #{hrv.get(match)} reported violations."
