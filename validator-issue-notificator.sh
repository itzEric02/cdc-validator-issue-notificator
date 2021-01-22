#!/bin/bash

#v0.2
#How often you want to check (Number[Suffix] e.g. 10s for 10 seconds or 2m for 2 minutes)
TIMER=20s

#Your Notify17 API key
APIKEY=

#Change the message you get if your validator stops signing blocks
TITLE="Your validator stopped signing blocks"
CONTENT="Your validator on the CDC-Crossfire network stopped signing blocks"
SOUND="arcturus"

#Change the tendermint URL (Crossfire: https://crossfire.crypto.com/ | testnet: https://testnet-croeseid.crypto.com:26657)
TENDERMINT=https://crossfire.crypto.com/

#If you have the public key of your validator at a different location than the standard one
#[.chain-maind/config/priv_validator_key.json]
#you can change it here
PUBKEY=$(cat .chain-maind/config/priv_validator_key.json | jq -r ".pub_key.value")

#Change the length of time until a retry is performed (Number[Suffix] e.g. 10s for 10 seconds or 2m for 2 minutes)
RETRY=10s

hide_cursor() {
    tput civis
}

trap show_cursor INT TERM

hide_cursor
clear

printf "\n'validator issue notificator' by eric\n\n"

if [[ -z "$PUBKEY" ]]
then
 printf "\x1b[31mERROR: Please add your pubkey to the script\x1b[0m\n"
 exit 1
fi

if [[ -z "$APIKEY" ]]
then
 printf "\x1b[31mERROR: Please add your Notify17 API key to the script\x1b[0m\n"
 exit 1
fi

if expr length "$PUBKEY" != 44 > nul
 then
  printf "\x1b[31mERROR: Your pubkey has not the correct length\x1b[0m\n"
  exit 1
 else
  printf "\r\e[K\e[32mPubkey has the correct length\e[0m\n"
fi

if expr length "$APIKEY" != 43 >nul
 then
  printf "\x1b[31mERROR: Your API-key has not the correct length\x1b[0m\n"
  exit 1
 else
  printf "\r\e[K\e[32mAPI-key has the correct length\e[0m\n\n"
fi

printf "This script uses parts from the check-validator-up.sh by the CDC Team\n\nYour Notify17 API key is $APIKEY \nYour validator public key is $PUBKEY \nThis script will check the status of your validator every $TIMER \n\n"

while true
do

 UP=$(curl -sSL https://raw.githubusercontent.com/itzEric02/cdc-validator-issue-notificator/main/check-validator-up.sh | bash -s --  --tendermint-url $TENDERMINT --pubkey $PUBKEY)

if  [[ $UP == *"Block#"* ]]
 then
  echo $UP
elif [[ $UP == "not signing something is wrong" ]]
 then
#####################################################################################################################
#The following part confirms that it is not just one block you are not signing
#If you want a notification with just one missing block you can delete this part and the marked fi's below (line 102 and 103)
#Be warned that there could be some false alarms
  printf "\x1b[31mValidator appears to be offline - retry\x1b[0m\n"
  sleep $RETRY
  UP2=$(curl -sSL https://raw.githubusercontent.com/itzEric02/cdc-validator-issue-notificator/main/check-validator-up.sh | bash -s --  --tendermint-url $TENDERMINT --pubkey $PUBKEY)
   if  [[ $UP2 == *"Block#"* ]]
    then
     printf "\r\e[K\e[33m$UP2\e[0m\n"
    else
     printf "\x1b[31mValidator appears to be offline - retry\x1b[0m\n"
     sleep $RETRY
     UP3=$(curl -sSL https://raw.githubusercontent.com/itzEric02/cdc-validator-issue-notificator/main/check-validator-up.sh | bash -s --  --tendermint-url $TENDERMINT --pubkey $PUBKEY)
      if [[ $UP3 == *"Block#"* ]]
       then
        printf "\r\e[K\e[33m$UP3\e[0m\n"
       else
#####################################################################################################################
        echo "Your validator is not signing blocks❌"
        curl -X POST "https://hook.notify17.net/api/raw/$APIKEY" -F title="$TITLE" -F content="$CONTENT" -F sound="$SOUND"
        exit 1
      fi #<----
   fi    #<----
 else
  printf "\x1b[31mERROR: Something is wrong with the check-validator-up.sh\x1b[0m\n"
  exit 1
fi

 sleep $TIMER

done
