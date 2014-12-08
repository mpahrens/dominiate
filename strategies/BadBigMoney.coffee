# This is a bad implementation of the pure Big Money strategy
{
  name: 'Bad Big Money'
  author: 'Andrew'
  requires: []
  gainPriority: (state, my) -> [
    "Estate" if state.gainsToEndGame() <= 2
    "Silver"
    "Duchy" if state.gainsToEndGame() <= 4
    "Province" if my.getTotalMoney() > 18
    "Gold"
    ]
}

