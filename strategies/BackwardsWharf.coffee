# Play Big Money including Banks, except buy Wharf with every $5 buy.
{
  name: 'BankWharf'
  author: 'Geronimoo' #tweaked by Jorbles
  requires: ['Bank', 'Wharf']
  gainPriority: (state, my) -> [
    "Copper"
    "Silver"
    "Wharf"
    "Gold"
    "Bank"
    "Platinum"
    "Estate"
    "Duchy"
    "Province"
    "Colony"
  ]
}
