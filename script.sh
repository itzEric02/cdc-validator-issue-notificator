#!/bin/bash

# v0.1

BROADCAST=async
PW=

while [ true ]
do
echo $PW | ./chain-maind tx bank send Default cro17dvkvu6lw5rq4a9jq4uh8lqw7t5sxjze2qn60y 1basetcro --chain-id "crossfire" --gas 8000000 --gas-prices 0.1basetcro -y --broadcast-mode $BROADCAST
echo $PW | ./chain-maind tx bank send Default cro17dvkvu6lw5rq4a9jq4uh8lqw7t5sxjze2qn60y 2basetcro --chain-id "crossfire" --gas 8000000 --gas-prices 0.1basetcro -y --broadcast-mode $BROADCAST
echo $PW | ./chain-maind tx bank send Default cro17dvkvu6lw5rq4a9jq4uh8lqw7t5sxjze2qn60y 3basetcro --chain-id "crossfire" --gas 8000000 --gas-prices 0.1basetcro -y --broadcast-mode $BROADCAST
echo $PW | ./chain-maind tx bank send Default cro17dvkvu6lw5rq4a9jq4uh8lqw7t5sxjze2qn60y 4basetcro --chain-id "crossfire" --gas 8000000 --gas-prices 0.1basetcro -y --broadcast-mode $BROADCAST
echo $PW | ./chain-maind tx bank send Default cro17dvkvu6lw5rq4a9jq4uh8lqw7t5sxjze2qn60y 5basetcro --chain-id "crossfire" --gas 8000000 --gas-prices 0.1basetcro -y --broadcast-mode $BROADCAST
echo $PW | ./chain-maind tx bank send Default cro17dvkvu6lw5rq4a9jq4uh8lqw7t5sxjze2qn60y 6basetcro --chain-id "crossfire" --gas 8000000 --gas-prices 0.1basetcro -y --broadcast-mode $BROADCAST
echo $PW | ./chain-maind tx bank send Default cro17dvkvu6lw5rq4a9jq4uh8lqw7t5sxjze2qn60y 7basetcro --chain-id "crossfire" --gas 8000000 --gas-prices 0.1basetcro -y --broadcast-mode $BROADCAST
 sleep 3s
done
