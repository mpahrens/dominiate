#!/bin/bash
for k in 0 1 2 3 4 5 6 7 8 9 10
do
    #echo "$w $h"
    result=$(./playPolicySwitch.coffee -w 4 -h 50 -k $k -o ./strategies/BigMoneyMLOpponent.coffee -i ./strategies/BigMoney.coffee -t 30 | grep "outcome: Won" | wc -l)
    echo "$k, $result" >> testResults_k.csv
done
#./playPolicySwitch.coffee -w 10 -h 50 -o ./strategies/BigMoneyMLOpponent.coffee -i ./strategies/BigMoney.coffee -t 30 | grep "outcome: Won" | wc -l
