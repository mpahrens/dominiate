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

discountReward = (rewards, gamma) ->
  sum = 0
  for r, i in rewards:
    sum += r * (gamma ** i)

singleRollout = (s, h) ->
  rewards = []
  for i in [0..h]
    s.doPlay()
    rewards.push getReward(s)
  discountReward rewards

doRollouts = (st, w, h) ->
  discountedRewards = []
  for sample in [0..w]
    tempState = st.copy()
    discountedRewards.push (singleRollout tempState)
  # Do some stuff
  avg discountedRewards

playGame = (filenames) ->
  ais = (loadStrategy(filename) for filename in filenames)
  st = new State().setUpWithOptions(ais, {
    colonies: false
    randomizeOrder: true
    log: console.log
    require: []
  })
  until st.gameIsOver()
    if st.phase is 'start':
      results = doRollouts(st)
      updatePolicy(results)
      # More stuff??
    st.doPlay()
  result = ([player.ai.toString(), player.getVP(st), player.turnsTaken] for player in st.players)
  console.log(result)
  result

this.playGame = playGame
args = process.argv[2...]
playGame(args)

exports.loadStrategy = loadStrategy
exports.playGame = playGame
