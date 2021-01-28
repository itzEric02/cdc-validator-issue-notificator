#!/bin/bash

OPA=$1

OUTPUT=$(curl -sSL https://chain.crypto.com/explorer/crossfire/api/v1/crossfire/validators | jq | grep $OPA --after-context=26)

MONIKER=$(printf "$OUTPUT" | grep "moniker" | cut -c 19- | sed 's/"//g' | sed 's/,//g')
TASKSETUP=$( printf "$OUTPUT" | grep "taskSetup" | cut -c 20- | sed 's/"//g' | sed 's/,//g')
TASKACTIVE=$( printf "$OUTPUT" | grep "taskKeepActive" | cut -c 25- | sed 's/"//g' | sed 's/,//g')
TASKVOTE=$( printf "$OUTPUT" | grep "taskProposalVote" | cut -c 27- | sed 's/"//g' | sed 's/,//g')
TASKUPGRADE=$( printf "$OUTPUT" | grep "taskNetworkUpgrade" | cut -c 29- | sed 's/"//g' | sed 's/,//g')

TOTALTX=$(printf "$OUTPUT" | grep "totalTxSent" | cut -c 23- | sed 's/"//g' | sed 's/,//g')
TX1=$(printf "$OUTPUT" | grep "txSentPhase1" | cut -c 24- | sed 's/"//g' | sed 's/,//g')
TX2=$(printf "$OUTPUT" | grep "txSentPhase2" | cut -c 24- | sed 's/"//g' | sed 's/,//g')
TX3=$(printf "$OUTPUT" | grep "txSentPhase3" | cut -c 24- | sed 's/"//g' | sed 's/,//g')

CP1n2=$(printf "$OUTPUT" | grep "commitCountPhase1n2" | cut -c 31- | sed 's/"//g' | sed 's/,//g')
CP2=$(printf "$OUTPUT" | grep "commitCountPhase2" | cut -c 29- | sed 's/"//g' | sed 's/,//g')
CP3=$(printf "$OUTPUT" | grep "commitCountPhase3" | cut -c 29- | sed 's/"//g' | sed 's/,//g')

P1BK=$(printf "$OUTPUT" | grep "phase1BlockCount" | cut -c 28- | sed 's/"//g' | sed 's/,//g')
P2BK=$(printf "$OUTPUT" | grep "phase2BlockCount" | cut -c 28- | sed 's/"//g' | sed 's/,//g')
P3BK=$(printf "$OUTPUT" | grep "phase3BlockCount" | cut -c 28- | sed 's/"//g' | sed 's/,//g')

UP2=$(echo $CP2 / $P2BK | bc -l | cut -c 2-3)

printf "\nYour moniker is $MONIKER\n\n"
if [[ $TASKSETUP = "Completed" ]]
 then
 printf "Task 1:\e[32m Completed\e[0m\n"
 else
 printf "Task 1:\e[31m Incomplete\e[0m\n"
fi
if [[ $TASKACTIVE = "Completed" ]]
 then
 printf "Task 2:\e[32m Completed\e[0m\n"
 else
 printf "Task 2:\e[31m Incomplete\e[0m\n"
fi
if [[ $TASKVOTE = "Completed" ]]
 then
 printf "Task 3:\e[32m Completed\e[0m\n"
 else
 printf "Task 3:\e[31m Incomplete\e[0m\n"
fi
if [[ $TASKUPGRADE = "Completed" ]]
 then
 printf "Task 4:\e[32m Completed\e[0m\n"
 else
 printf "Task 4:\e[31m Incomplete\e[0m\n"
fi
printf "\nTotal transactions sent: $TOTALTX\e[0m\n\n"
if (($UP2 > 50))
 then
 printf "Uptime in phase 2:\e[32m $UP2%%\e[0m\n\n"
else
 printf "Uptime in phase 2:\e[31m $UP2%%\e[0m\n\n"
fi

exit 0
