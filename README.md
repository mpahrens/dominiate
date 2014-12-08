Comp150 AML final project
Policy switching and Policy search
Andrew Mendelsohn and Matthew Ahrens
hosted on:https://github.com/mpahrens/dominiate.git
Forked from Dominiate by Robert Speer

How to run:
- policy switching
  - usage: ./playPolicySwitch.coffee (-w # -h # -k # -t # -i [path to strategy file] -o [path to strategy file])
  - e.g.: ./playPolicySwitch.coffee -w 10 -h 10 -k -t 20 -i ./strategies/BigMoney.coffee -o ./strategies/BigMoney.coffee
- policy search
  - usage: ./playSearch.coffee [numEpisodes] [numTrials] ./strategies/SimpleMoney.coffee ./strategies/SimpleMoney.coffee

Files We made:
- playPolicySwitch.coffee
  - Complete implementation of Policy Switching
- playSearch
  - Complete implementation of Policy Search
- ./testPolicySwitch
  - runs test runs over policy switching for various w and h and stores the results in a testResultsSwitch.csv
- ./paper/*
  - final presentation paper in pdf and tex
- ./strategies/BigMoneyMLOpponent.coffee
  - BigMoney policy for the AI opponent but with a fixed set of 10 required cards to set the kingdom cards for the game

Files provided by simulator to note to note
- gameState.coffee
  - game and player state classes
- basicAI.coffee
  - the basic AI that gets methods overridden by policy
