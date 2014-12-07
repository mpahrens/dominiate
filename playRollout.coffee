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

updateStrategy = (ai, player, translator = null) ->
  player.ai = translator(ai) if translator? else ai

avg = (list) ->
  sum = list.reduce ((t, s) -> t + s), 0
  sum / list.length

getMLPlayer = (s) ->
  selfs = s.players.filter (p) -> p.name[..4] isnt "Robot"
  selfs[0]

getReward = (s) ->
  self = getMLPlayer(s)
  others = s.players.filter (p) -> p isnt self
  avgMoney = avg (p.getTotalMoney() for p in others)
  avgVP = avg (p.getVP() for p in others)
  return (self.getTotalMoney() + self.getVP())/(avgMoney+avgVP)

discountReward = (rewards, gamma) ->
  sum = 0
  for r, i in rewards
    do (r,i) ->
      sum += r * (gamma ** i)
  sum

singleRollout = (s, h) ->
  rewards = []
  i = 0
  while i < h*s.nPlayers
    if s.phase is 'start'
      i += 1
    s.doPlay()
    rewards.push getReward(s)
  discountReward(rewards, 0.9)

doRollouts = (st, w, h) ->
  totalDiscountedRewards = []
  tempState = null
  for sample in [0..w]
    tempState = st.copy()
    totalDiscountedRewards.push(singleRollout(tempState, h))
  # Do some stuff
  console.log "Turns Taken:"
  console.log tempState.players[0].turnsTaken
  console.log st.players[0].turnsTaken

  avg totalDiscountedRewards

updatePolicy = (avgDiscRwd) ->
  avgDiscRwd

playGame = (filenames) ->
  ais = (loadStrategy(filename) for filename in filenames)
  st = new State().setUpWithOptions(ais, {
    colonies: false
    randomizeOrder: false
    log: console.log
    require: []
  })
  st.players[0].name = "Andrew&Matt"
  for player,i in st.players[1..]
    player.name = "Robot#{i}"
  console.log st.players
  until st.gameIsOver()
    console.log
    if st.phase is 'start'
      results = doRollouts(st,arg_w,arg_h)
      updatePolicy(results)
      # More stuff??
    st.doPlay()
  result = ([player.name, player.ai.toString(), player.getVP(st), player.turnsTaken] for player in st.players)
  console.log(result)
  console.log "player #{getMLPlayer(st).name} reward: #{getReward(st)}"
  result

this.playGame = playGame
arg_w = process.argv[2]
arg_h = process.argv[3]
console.log "w: #{arg_w}  :: h: #{arg_h}"
args = process.argv[4...]
playGame(args)

exports.loadStrategy = loadStrategy
exports.playGame = playGame
