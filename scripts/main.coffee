# Description:
#   Example scripts for you to examine and try out.
#
# Notes:
#   They are commented out by default, because most of them are pretty silly and
#   wouldn't be useful and amusing enough for day to day huboting.
#   Uncomment the ones you want to try and experiment with.
#
#   These are from the scripting documentation: https://github.com/github/hubot/blob/master/docs/scripting.md

cron = require('cron').CronJob
Backlog = require "./backlog"
backlog = new Backlog()
request = require "request"

module.exports = (robot) ->
  backlogApiKey = process.env.BACKLOG_API_KEY
  backlogProjectId = process.env.BACKLOG_PROJECT_ID
  backlogSubDomain = process.env.BACKLOG_SUB_DOMAIN
  backlogApiDomain = "https://#{backlogSubDomain}.backlog.jp"
  backlogDomain = "https://#{backlogSubDomain}.backlog.jp"

  robot.hear /hello/i, (msg) ->
    name = msg.message.user.name
    msg.send "hello! #{name}"

  robot.respond /担当者$/, (msg) ->
    backlog.getUsers()
    .then (messages) ->
      msg.send messages.join("\n")

  robot.respond /(.+)の課題$/, (msg) ->
    name = msg.match[1]
    backlog.getUser(name)
    .then (result) ->
      backlog.getIssues("statusId": ["1", "2", "3"], "assigneeId": [result])
      .then (messages) ->
        msg.send messages.join("\n")

  robot.respond /『(.*)』を登録$/, (msg) ->
    title = msg.match[1]
    url = "#{backlogApiDomain}/api/v2/issues?apiKey=#{backlogApiKey}"
    data = JSON.stringify {
      projectId: backlogProjectId,
      summary: title,
      issueTypeId: "1",
      priorityId: "3"
    }
    request = msg.http(url)
      .header('Content-Type', 'application/json')
      .post(data)
    request (err, res, body) ->
      json = JSON.parse body
      issueKey = json.issueKey
      link = "  #{backlogDomain}/view/#{issueKey}"
      msg.send "登録しました。\n#{link}"

  robot.respond /課題を確認$/, (msg) ->
    backlog.getIssues("statusId": ["1", "2", "3"])
    .then (messages) ->
      msg.send messages.join("\n")

  new cron '0 0 10 * * 1-5', () =>
    backlog.getIssues("statusId": ["1", "2", "3"])
    .then (messages) ->
      robot.send {room: "#general"}, messages.join("\n")
  , null, true, "Asia/Tokyo"

  # robot.hear /badger/i, (res) ->
  #   res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"
  #
  # robot.respond /open the (.*) doors/i, (res) ->
  #   doorType = res.match[1]
  #   if doorType is "pod bay"
  #     res.reply "I'm afraid I can't let you do that."
  #   else
  #     res.reply "Opening #{doorType} doors"
  #
  # robot.hear /I like pie/i, (res) ->
  #   res.emote "makes a freshly baked pie"
  #
  # lulz = ['lol', 'rofl', 'lmao']
  #
  # robot.respond /lulz/i, (res) ->
  #   res.send res.random lulz
  #
  # robot.topic (res) ->
  #   res.send "#{res.message.text}? That's a Paddlin'"
  #
  #
  # enterReplies = ['Hi', 'Target Acquired', 'Firing', 'Hello friend.', 'Gotcha', 'I see you']
  # leaveReplies = ['Are you still there?', 'Target lost', 'Searching']
  #
  # robot.enter (res) ->
  #   res.send res.random enterReplies
  # robot.leave (res) ->
  #   res.send res.random leaveReplies
  #
  # answer = process.env.HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING
  #
  # robot.respond /what is the answer to the ultimate question of life/, (res) ->
  #   unless answer?
  #     res.send "Missing HUBOT_ANSWER_TO_THE_ULTIMATE_QUESTION_OF_LIFE_THE_UNIVERSE_AND_EVERYTHING in environment: please set and try again"
  #     return
  #   res.send "#{answer}, but what is the question?"
  #
  # robot.respond /you are a little slow/, (res) ->
  #   setTimeout () ->
  #     res.send "Who you calling 'slow'?"
  #   , 60 * 1000
  #
  # annoyIntervalId = null
  #
  # robot.respond /annoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #     return
  #
  #   res.send "Hey, want to hear the most annoying sound in the world?"
  #   annoyIntervalId = setInterval () ->
  #     res.send "AAAAAAAAAAAEEEEEEEEEEEEEEEEEEEEEEEEIIIIIIIIHHHHHHHHHH"
  #   , 1000
  #
  # robot.respond /unannoy me/, (res) ->
  #   if annoyIntervalId
  #     res.send "GUYS, GUYS, GUYS!"
  #     clearInterval(annoyIntervalId)
  #     annoyIntervalId = null
  #   else
  #     res.send "Not annoying you right now, am I?"
  #
  #
  # robot.router.post '/hubot/chatsecrets/:room', (req, res) ->
  #   room   = req.params.room
  #   data   = JSON.parse req.body.payload
  #   secret = data.secret
  #
  #   robot.messageRoom room, "I have a secret: #{secret}"
  #
  #   res.send 'OK'
  #
  # robot.error (err, res) ->
  #   robot.logger.error "DOES NOT COMPUTE"
  #
  #   if res?
  #     res.reply "DOES NOT COMPUTE"
  #
  # robot.respond /have a soda/i, (res) ->
  #   # Get number of sodas had (coerced to a number).
  #   sodasHad = robot.brain.get('totalSodas') * 1 or 0
  #
  #   if sodasHad > 4
  #     res.reply "I'm too fizzy.."
  #
  #   else
  #     res.reply 'Sure!'
  #
  #     robot.brain.set 'totalSodas', sodasHad+1
  #
  # robot.respond /sleep it off/i, (res) ->
  #   robot.brain.set 'totalSodas', 0
  #   res.reply 'zzzzz'
