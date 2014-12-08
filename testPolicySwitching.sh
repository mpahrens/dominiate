#!/bin/bash
for w in 100
do
  for h in 100
  do
    #echo "$w $h"
    result=$(./playPolicySwitch.coffee -w $w -h $h -o ./strategies/BigMoneyMLOpponent.coffee -i ./strategies/BigMoney.coffee -t 30 | grep "outcome: Won" | wc -l)
    echo "$w, $h, $result" >> testResults.csv
  done
done
#./playPolicySwitch.coffee -w 10 -h 50 -o ./strategies/BigMoneyMLOpponent.coffee -i ./strategies/BigMoney.coffee -t 30 | grep "outcome: Won" | wc -l
