{BasicAI} = require './basicAI'
{State,tableaux} = require './gameState'

swap = (l, a, b) ->
  [l[a], l[b]] = [l[b], l[a]]

rand = (min, max) ->
  range = Math.random() * (max - min) + min
  Math.round range

mutatePolicy = (ai, st) ->
  new_ai = ai.copy()
  new_ai.gainPriority = mutateGainPriority(ai.gainPriority, st)
  new_ai

mutateGainPriority = (oldGP, state) ->
  len = oldGP(state, state.players[0]).length
  i = rand(1, len-2)
  upDown = rand(0, 1)
  (st, my) ->
    list = oldGP(st, my)
    if upDown
      swap(list, i, i-1)
    else
      swap(list, i, i+1)
    list

this.mutatePolicy = mutatePolicy
