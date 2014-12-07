#!/usr/bin/env coffee
#
# This is the script that you can run at the command line to see how
# strategies play against each other.

{BasicAI} = require './basicAI'
{State,tableaux} = require './gameState'
{mutatePolicy} = require './modStrategy'
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
  player.ai = if translator? then translator(ai) else ai

avg = (list) ->
  sum = list.reduce ((t, s) -> t + s), 0
  sum / list.length

setMLPlayer = (st, ai) ->
  for player,i in st.players
    if player.ai is ai
      player.name = "mlPlayer"
    else
      player.name = "Robot#{i}"

getMLPlayer = (s) ->
  selfs = s.players.filter (p) -> p.name is "mlPlayer"
  selfs[0]

getReward = (s) ->
  self = getMLPlayer(s)
  others = s.players.filter (p) -> p isnt self
  avgMoney = avg (p.getTotalMoney() for p in others)
  avgVP = avg (p.getVP() for p in others)
  if s.gameIsOver()
    return self.getVP() / avgVP
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

printPolicy = (ai, st) ->
  console.log 

mutatePolicy = (oldAi) ->
  oldAi

playGameFromState = (st) ->
  console.log "Played game"
  until st.gameIsOver()
    st.doPlay()
  result = ([player.name, player.ai.toString(), player.getVP(st), player.turnsTaken] for player in st.players)
  console.log(result)
  console.log "player #{getMLPlayer(st).name} reward: #{getReward(st)}"
  result

runTrial = (base_st, width) ->
  wins = 0
  for w in [0...width]
    console.log "Trial: #{w}"
    st = base_st.copy()
    mlPlayer = getMLPlayer(st)
    playGameFromState st
    if mlPlayer in st.getWinners()
      wins += 1
  winRate_new = wins / width


runExperiment = (filenames, episodes, width) ->
  ais = (loadStrategy(filename) for filename in filenames)

  base_st = new State().setUpWithOptions(ais, {
    colonies: false
    randomizeOrder: false
    log: console.log
    require: []
  })

  setMLPlayer(base_st, ais[0])
  mlPlayer = getMLPlayer(base_st)

  pi_old = mlPlayer.ai
  winRate_old = runTrial(base_st, width)

  for ep in [0...episodes]
    console.log "EPISODE: #{ep}"
    pi_new = mutatePolicy(pi_old, base_st)
    mlPlayer.ai = pi_new
    winRate_new = runTrial(base_st, width)
    if winRate_new > winRate_old
      pi_old = pi_new
      winRate_old = winRate_new

  pi_final = pi_new

  # until base_st.gameIsOver()
    # base_st.doPlay()

  console.log pi_final.gainPriority(base_st, mlPlayer)
  # console.log pi_final

arg_e = process.argv[2]
arg_w = process.argv[3]
console.log "episodes: #{arg_e}  :: w: #{arg_w}"
files = process.argv[4...]
runExperiment(files, arg_e, arg_w)
# playGame(args)

exports.loadStrategy = loadStrategy
exports.playGameFromState = playGameFromState

this.playGameFromState = playGameFromState
