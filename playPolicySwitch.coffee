#!/usr/bin/env coffee
#
# This is the script that you can run at the command line to see how
# strategies play against each other.
#Matthew Ahrens : adapted from play.coffee by Robert Speer
{BasicAI} = require './basicAI'
{State,tableaux} = require './gameState'
fs = require 'fs'
coffee = require 'coffee-script'

loadStrategies = (arg_policies)->
  filenames = fs.readdirSync("./strategies")
  filenames = if arg_policies.length == 0 then filenames.filter (f) -> f.search(".coffee") > -1 else arg_policies
  ais = []
  for filename in filenames
    ai = loadStrategy("./strategies/#{filename}")
    ais.push ai
  for ai in ais
    ai = ai.copy
  ais
loadStrategy = (filename) ->
  ai = new BasicAI()
  #console.log(filename)

  changes = eval coffee.compile(
    fs.readFileSync(filename, 'utf-8'),
    {bare: yes}
  )
  for key, value of changes
    ai[key] = value
  #console.log "loaded ai with method: #{ai.chooseAction}"
  ai

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
  if s.gameIsOver()
    for p in others
      if p.getVP() > self.getVP()
        return -1000
    return 1000
  #return self.getVP() / avgVP
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
  while i < h*s.nPlayers and not s.gameIsOver()
    if s.phase is 'start'
      i += 1
    s.doPlay()
    rewards.push getReward(s)
  discountReward(rewards, 0.9)

doRollouts = (st, w, h) ->
  console.log "Entering doRollouts"
  ais = aiPool.filter (a) -> #(a.requires.filter (c) -> st.supply.hasOwnProperty(c)).length == a.requires.length and a.gainPriority?
    for card in a.requires
      if st.supply[card] is undefined
        return false
    return true

  v = []
  #init value of each policy to 0
  for ai in ais
    v[ai] = [0,0,0] #[num visited,total value]
  tempState = null
  for sample in [0...w]
    tempState = st.copy()
    i = Math.floor(Math.random() * ais.length)
    getMLPlayer(tempState).ai = ais[i]
    v[ais[i]][0]+=1
    v[ais[i]][1]+=singleRollout(tempState, h)
    v[ais[i]][2] = (v[ais[i]][1] / v[ais[i]][0])
  v

updatePolicy = (st,v) ->
  console.log "Entering updatePolicy"
  player = getMLPlayer(st)
  maxAi = player.ai.toString()
  console.log "V:#{key}:#{value}" for own key,value of v
  maxAi = key for own key, value of v when value[2] >=v[maxAi][2]
  maxAiRet = a for a in aiPool when maxAi is a.toString()
  maxAiRet

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
  #console.log st.players
  k_temp = 0
  until st.gameIsOver()
    #console.log
    if st.phase is 'start' and st.current is getMLPlayer(st)
      console.log "player ai: #{getMLPlayer(st).ai}"
      results = doRollouts(st,arg_w,arg_h)
      if k_temp % arg_k == 0
        getMLPlayer(st).ai = updatePolicy(st,results)
      k_temp+=1
    st.doPlay()
  result = ([player.name, player.ai.toString(), player.getVP(st), player.turnsTaken] for player in st.players)
  console.log(result)
  console.log "player #{getMLPlayer(st).name} outcome: #{if getReward(st) is 1000 then "Won" else "Lost"} reward:#{getReward(st)}"
  result

this.playGame = playGame
arg_w = 10
arg_h = 10
arg_k = 1
arg_trials = 1
arg_mode = "normal"
arg_ops = []
arg_policies = []
for arg,i in process.argv
  if arg == "--help"
    console.log "usage: ./playPolicySwitch.coffee (-w # -h # -k # -t # -i <path to strategy file> -o <path to strategy file>)"
    console.log "e.g.: ./playPolicySwitch.coffee -w 10 -h 10 -k -t 20 -i ./strategies/BigMoney.coffee -o ./strategies/BigMoney.coffee"
    process.exit 0
  if arg == "-w"
    arg_w = process.argv[i+1]
  else if arg == "-h"
    arg_h = process.argv[i+1]
  else if arg == "-k"
    arg_k = process.argv[i+1]
  else if arg == "-t" or arg == "-trials"
    arg_trials = process.argv[i+1]
  else if arg == "-m" or arg == "-mode"
    arg_mode = process.argv[i+1]
  else if arg == "-i"
    arg_ops_temp = [process.argv[i+1]]
    arg_ops_temp.push a for a in arg_ops
    arg_ops = arg_ops_temp
  else if arg == "-o" or arg == "-opponent"
    arg_ops.push process.argv[i+1]
  else if arg == "-p" #restrict policy switch only to the following policies
    n = process.argv[i+1]
    arg_policies = process.argv[i+2...i+2+n]
    #console.log arg_policies
while arg_ops.length < 2
  arg_ops.push "./strategies/BigMoney.coffee"

#non-changing list of strategies
aiPool = loadStrategies(arg_policies)

console.log "Running PolicySwitch with w: #{arg_w} samples, h: #{arg_h} horizon, k: #{arg_k} steps between each rollout, and #{arg_trials} trials in #{arg_mode} mode and with inital strategy: #{arg_ops[0]} opponents: #{arg_ops[1...]}."
for [0...arg_trials]
  playGame(arg_ops)

exports.loadStrategy = loadStrategy
exports.playGame = playGame
