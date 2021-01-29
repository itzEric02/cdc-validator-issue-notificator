#!/bin/bash

MONIKER=$1

if ! type "jq" > /dev/null; then
    echo please install jq
fi

if [ "$#" == 0 ]
 then
 printf "\n\e[31mERROR: Please add your moniker to command \e[0m\n"
 exit 0
fi

if [[ $MONIKER == *"crocncl1"* ]]
 then
 printf "\n@arg improved the script\n\e[31mERROR: Please add your moniker and not your operator address \e[0m\n"
 exit 0
fi

JSON=$( curl -sSL https://chain.crypto.com/explorer/crossfire/api/v1/crossfire/validators | jq --arg MONIKER "$MONIKER" '.[][] | select(.moniker==$MONIKER)' )

#Print pretty printed JSON
#echo $JSON | jq ''

ADDRESS=$( echo $JSON | jq -r '.operatorAddress'  )
TASKSETUP=$( echo $JSON | jq -r '.taskSetup'  )
TASKACTIVE=$( echo $JSON | jq -r '.taskKeepActive'  )
TASKVOTE=$( echo $JSON | jq -r '.taskProposalVote' )
TASKUPGRADE=$( echo $JSON | jq -r '.taskNetworkUpgrade' )

TOTALTX=$( echo $JSON | jq -r '.stats.totalTxSent' )
TX1=$( echo $JSON | jq -r '.stats.txSentPhase1' )
TX2=$( echo $JSON | jq -r '.stats.txSentPhase2' )
TX3=$( echo $JSON | jq -r '.stats.txSentPhase3' )

CP1n2=$(echo $JSON | jq -r '.stats.commitCountPhase1n2' )
CP2=$(echo $JSON | jq -r '.stats.commitCountPhase2' )
CP3=$(echo $JSON | jq -r '.stats.commitCountPhase3' )

P1BK=$(echo $JSON | jq -r '.stats.phase1BlockCount' )
P2BK=$(echo $JSON | jq -r '.stats.phase2BlockCount' )
P3BK=$(echo $JSON | jq -r '.stats.phase3BlockCount' )

RANK1=$(echo $JSON | jq -r '.rankPhase1n2CommitmentRank' )
RANK2=$(echo $JSON | jq -r '.rankPhase3CommitmentRank' )
RANK3=$(echo $JSON | jq -r '.rankTxSentRank' )

UP2=$(echo $CP2 / $P2BK | bc -l | cut -c 2-3)

printf "\nThese informations are from the official crossfire leaderboard"
printf "\n\e[33mThey may include some lag\e[0m\n"

printf "\nYour moniker is $MONIKER \nYour operator address is $ADDRESS\n\n"
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
printf "\nNormal Phase Commit Rank:$RANK1 \n"
printf "Attack Phase Commit Rank:$RANK2 \n"
printf "Transaction Rank:$RANK3 \n"

printf "\nTotal Transactions Sent: $TOTALTX\e[0m\n\n"
if (($UP2 > 50))
 then
 printf "Uptime in Phase 2:\e[32m $UP2%%\e[0m\n\n"
else
 printf "Uptime in Phase 2:\e[31m $UP2%%\e[0m\n\n"
fi

exit 0
