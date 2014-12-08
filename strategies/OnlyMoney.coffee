# This is an implementation of the pure Big Money strategy, updated
# based on WanderingWinder's forum posts:
# http://forum.dominionstrategy.com/index.php?topic=625
{
  name: 'Only Money'
  requires: []
  gainPriority: (state, my) ->
    [
      "Gold"
      "Silver"
      "Copper" if state.gainsToEndGame() <= 2
    ]

}
