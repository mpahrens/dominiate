#!/usr/bin/env coffee
#
# This is the script that you can run at the command line to see how
# strategies play against each other.

{BasicAI} = require './basicAI'
{State,tableaux} = require './gameState'
fs = require 'fs'
coffee = require 'coffee-script'

loadStrategy = (filename) ->
  ai = new BasicAI()
  console.log(filename)

  changes = eval coffee.compile(
    fs.readFileSync(filename, 'utf-8'),
    {bare: yes}
  )
  for key, value of changes
    ai[key] = value
  ai

avg = (list) ->
  sum = list.reduce (t, s) -> t + s
  sum / list.length

getReward = (s) ->
  5

discountReward = (rewards, gamma) ->
  sum = 0
  for r, i in rewards
    do (r,i) ->
      sum += r * (gamma ** i)

singleRollout = (s, h) ->
  rewards = []
  i = 0
  while i < h*s.nPlayers
    if s.phase is 'start'
      i += 1
    s.doPlay()
    rewards.push getReward(s)
  discountReward rewards

doRollouts = (st, w, h) ->
  discountedRewards = []
  tempState = null
  for sample in [0..w]
    tempState = st.copy()
    discountedRewards.push(singleRollout(tempState, h))
  # Do some stuff
  console.log "Turns Taken:"
  console.log tempState.players[0].turnsTaken
  console.log st.players[0].turnsTaken

  avg discountedRewards

updatePolicy = (avgDiscRwd) ->
  avgDiscRwd

playGame = (filenames) ->
  ais = (loadStrategy(filename) for filename in filenames)
  st = new State().setUpWithOptions(ais, {
    colonies: false
    randomizeOrder: true
    log: console.log
    require: []
  })
  until st.gameIsOver()
    if st.phase is 'start'
      results = doRollouts(st,arg_w,arg_h)
      updatePolicy(results)
      # More stuff??
    st.doPlay()
  result = ([player.ai.toString(), player.getVP(st), player.turnsTaken] for player in st.players)
  console.log(result)
  result

this.playGame = playGame
arg_w = process.argv[2]
arg_h = process.argv[3]
console.log "w: #{arg_w}  :: h: #{arg_h}"
args = process.argv[4...]
playGame(args)

exports.loadStrategy = loadStrategy
exports.playGame = playGame
