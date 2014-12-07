#!/usr/bin/env coffee
#
# This is the script that you can run at the command line to see how
# strategies play against each other.

{BasicAI} = require './basicAI'
{State,tableaux} = require './gameState'
fs = require 'fs'
coffee = require 'coffee-script'
k_trials = 10

loadStrategies = ->
  filenames = fs.readdirSync("./strategies")
  filenames = filenames.filter (f) -> f.search(".coffee") > -1
  ais = []
  for filename in filenames
    ai = loadStrategy("./strategies/#{filename}")
    ais.push ai
  ais = ais.filter (a) -> a.requires.length is 0 and a.gainPriority?
  ais
loadStrategy = (filename) ->
  ai = new BasicAI()
  console.log(filename)

  changes = eval coffee.compile(
    fs.readFileSync(filename, 'utf-8'),
    {bare: yes}
  )
  for key, value of changes
    ai[key] = value
  console.log "loaded ai with method: #{ai.chooseAction}"
  ai

updateStrategy = (ai, player, translator = null) ->
  player.ai = if translator? then translator(ai) else ai

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
    return self.getVP() / avgVP
  return (self.getTotalMoney() + self.getVP())/(avgMoney+avgVP)

discountReward = (rewards, gamma) ->
  sum = 0
  for r, i in rewards
    do (r,i) ->
      sum += r * (gamma ** i)
  sum

singleRollout = (s, h) ->
  console.log "Entering Single Rollout with player ai: #{getMLPlayer(s).ai} and h: #{h}"
  rewards = []
  i = 0
  while i < h*s.nPlayers and not s.gameIsOver()
    if s.phase is 'start'
      i += 1
    s.doPlay()
    rewards.push getReward(s)
  discountReward(rewards, 0.9)

#non-changing list of strategies
aiPool = loadStrategies()

doRollouts = (st, w, h) ->
  console.log "Entering doRollouts"
  v = []
  #init value of each policy to 0
  for ai in aiPool
    console.log "init ai: #{ai.toString()}"
    v[ai] = [0,0,0] #[num visited,total value]
  tempState = null
  for sample in [0...w]
    tempState = st.copy()
    i = Math.floor(Math.random() * aiPool.length)
    getMLPlayer(tempState).ai = aiPool[i]
    v[aiPool[i]][0]+=1
    v[aiPool[i]][1]+=singleRollout(tempState, h)
    v[aiPool[i]][2] = (v[aiPool[i]][1] / v[aiPool[i]][0])
  v

updatePolicy = (st,v) ->
  console.log "Entering updatePolicy"
  player = getMLPlayer(st)
  maxAi = null
  console.log "#{key}:#{value}" for own key,value of v
  maxAi = key for own key, value of v when maxAi is null or value[2] >=v[maxAi][2]
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
  until st.gameIsOver()
    #console.log
    if st.phase is 'start'
      results = doRollouts(st,arg_w,arg_h)
      getMLPlayer(st).ai = updatePolicy(st,results)
      # More stuff??
    console.log "player ai: #{getMLPlayer(st).ai}"
    st.doPlay()
  result = ([player.name, player.ai.toString(), player.getVP(st), player.turnsTaken] for player in st.players)
  console.log(result)
  console.log "player #{getMLPlayer(st).name} reward: #{getReward(st)}"
  result

this.playGame = playGame
arg_w = 10
arg_h = 10
arg_k = 10
arg_trials = 10
arg_mode = "normal"
arg_ops = []
for arg,i in process.argv
  if arg == "-h" or arg == "--help"
    console.log "usage: ./playPolicySwitch.coffee (-w # -h # -k # -t # -m [normal|egreedy] -i <path to strategy file> -o <path to strategy file>)"
    console.log "e.g.: ./playPolicySwitch.coffee -w 10 -h 10 -k -t 20 -m normal -i ./strategies/BigMoney.coffee -o ./strategies/BigMoney.coffee"
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
    arg_ops = [process.argv[i+1]].push arg_ops
  else if arg == "-o" or arg == "-opponent"
    arg_ops.push process.argv[i+1]
while arg_ops.length < 2
  arg_ops.push "./strategies/BigMoney.coffee"


console.log "Running PolicySwitch with w: #{arg_w} samples, h: #{arg_h} horizon, k: #{arg_k} steps between each rollout, and #{arg_trials} trials in #{arg_mode} mode and with inital strategy: #{arg_ops[0]} opponents: #{arg_ops[1...]}."
playGame(arg_ops)

exports.loadStrategy = loadStrategy
exports.playGame = playGame
