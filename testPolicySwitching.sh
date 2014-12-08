#!/bin/bash
echo "w,h,# of wins out of 30" >>> testResultsSwitch.csv
for w in 1 2 3 4 5 10 25 50 100
do
  for h in 1 2 3 4 5 10 25 50 100
  do
    #echo "$w $h"
    result=$(./playPolicySwitch.coffee -w $w -h $h -o ./strategies/BigMoneyMLOpponent.coffee -i ./strategies/BigMoney.coffee -t 30 | grep "outcome: Won" | wc -l)
    echo "$w, $h, $result" >> testResultsSwitch.csv
  done
done
#./playPolicySwitch.coffee -w 10 -h 50 -o ./strategies/BigMoneyMLOpponent.coffee -i ./strategies/BigMoney.coffee -t 30 | grep "outcome: Won" | wc -l
