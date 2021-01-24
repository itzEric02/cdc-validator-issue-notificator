#!/bin/bash

# v0.3

#################################################################
#                        User variables                         #
#################################################################

ADDRESS= # [cro1.....]
KEYNAME=Default
PASSPHRASE=
OPERATOR= # [crocncl1.....]
CHAINID=crossfire
COUNT=500 #Number of transactions till check of last transaction
SLEEP=60s #length of the sleep before the scrip tries to check if the last transaction was broadcasted (0 = disabled)
CHECKTIME=10s #time between retries for check of last transaction
SHOWTX=count #show tx-hashes in the output [true|new|count|count+new|point|false]
VARBEGIN=true #show all variables on startup
STARTCHECK=true #check all variables on startup (recommended)

#################################################################

ACCOUNTNUMBER=$(./chain-maind query account $ADDRESS | grep account_number | sed 's/"//g' | cut -c 17-)
PASSSECURE=$(echo $PASSPHRASE | cut -c 7-)
TXCOUNT=0

clear

printf "\n\e[35m'Automated transaction creator' by eric\n\e[0mbased on a script by samduckling\n\n" #(https://discord.com/channels/783264383978569728/790404424433926155/801438774000091208)

sleep 2s

if [ $VARBEGIN = true ]
then
 printf "Address: $ADDRESS\n"
 sleep .3
 printf "Keyname: $KEYNAME\n"
 sleep .3
 printf "Passphrase: *******$PASSSECURE\n"
 sleep .3
 printf "Operator address: $OPERATOR\n"
 sleep .3
 printf "ChainID: $CHAINID\n"
 sleep .3
 printf "Transaction output: $SHOWTX\n\n"
 sleep 1s
fi

if [ $STARTCHECK = true ]
then
 printf "\r\e[K\e[32mStart script startup check....\e[0m\n\n"

 if [[ -f "tx.json" ]]
 then
  printf "\r\e[K\e[32mtx.json already created\e[0m\n\n"
 else
  printf "\r\e[K\e[33mtx.json not found. Creating new.......\e[0m\n"
  ./chain-maind tx distribution set-withdraw-addr $ADDRESS --from $ADDRESS --chain-id $CHAINID --gas-prices="0.1basetcro" --gas 80000 --generate-only > tx.json
  printf "\r\e[K\e[32mNew tx.json created!\e[0m\n\n"
 fi

 if [[ -z "$KEYNAME" ]]
 then
  printf "\x1b[31mERROR: Please add your keyname to the script\x1b[0m\n"
  exit 1
 fi

 if [[ -z "$ADDRESS" ]]
 then
  printf "\x1b[31mERROR: Please add your cro address to the script\x1b[0m\n"
  exit 1
 fi

 if [[ -z "$PASSPHRASE" ]]
 then
  printf "\x1b[31mERROR: Please add your keyring passphrase to the script\x1b[0m\n"
  exit 1
 fi

 if [[ -z "$OPERATOR" ]]
 then
  printf "\x1b[31mERROR: Please add your operator address to the script\x1b[0m\n"
  exit 1
 fi

 if [[ -z "$ACCOUNTNUMBER" ]]
 then
  printf "\x1b[31mERROR: Please add your accountnumber to the script\x1b[0m\n"
  exit 1
 fi

 if [[ -z "$CHAINID" ]]
 then
  printf "\x1b[31mERROR: Please add the chainid to the script\x1b[0m\n"
  exit 1
 fi

 if expr length "$ADDRESS" != 42 > nul
  then
   printf "\x1b[31mERROR: Your cro address has not the correct length\x1b[0m\n"
   exit 1
  else
   printf "\r\e[K\e[32mCro address has the correct length\e[0m\n\n"
 fi

 if expr length "$OPERATOR" != 46 > nul
  then
   printf "\x1b[31mERROR: Your operator address has not the correct length\x1b[0m\n"
   exit 1
  else
   printf "\r\e[K\e[32mOperator address has the correct length\e[0m\n\n"
 fi

 if echo $PASSPHRASE | ./chain-maind keys list | grep -q mnemonic
  then
   printf "\r\e[K\e[32mPassphrase correct\e[0m\n\n"
  else
   printf "\x1b[31mERROR: incorrect passphrase\x1b[0m\n"
   exit 1
 fi

 if echo $PASSPHRASE | ./chain-maind keys list | grep -q $ADDRESS
  then
   printf "\r\e[K\e[32mCro address is in your key list\e[0m\n\n"
  else
   printf "\r\e[K\e[33mWARNING: Your address is not in your key list\e[0m\n"
   read -p "Are you sure that you want to proceed? (y/n)" -n 1 -r
   echo
    if [[ $REPLY =~ ^[Yy]$ ]]
     then
      printf "\r\e[K\e[32mProceeding\e[0m\n\n"
     else
      exit 1
    fi
 fi

 if (./chain-maind q staking validator $OPERATOR | grep -q moniker)
  then
   printf "\r\e[K\e[32mThere is a validator working with this address\e[0m\n\n"
  else
   printf "\x1b[31mERROR: no validator working with this address\x1b[0m\n"
   exit 1
 fi

 MONIKER=$(./chain-maind q staking validator $OPERATOR | grep moniker | cut -c 12-)

 printf "\r\e[K\e[32mYour validator's moniker is \e[36m$MONIKER\e[0m\n\n"

 printf "\r\e[K\e[32mScript startup check completed\e[0m\n\n"
fi

n=$(./chain-maind q account $ADDRESS -o json | jq -r .sequence)

while true
do
RETRY=0
 for (( i=0; i<$COUNT; ++i)); do

  echo $PASSPHRASE  | ./chain-maind tx sign tx.json --chain-id $CHAINID --from $KEYNAME --sequence "${n}" --offline -a $ACCOUNTNUMBER > sig

  TX=$(./chain-maind tx broadcast sig --chain-id $CHAINID --broadcast-mode async --log_format json | jq -r .txhash)

  TXCOUNT=$(($TXCOUNT+1))

  if [[ $SHOWTX = true ]]
  then
   echo $TX
  elif [[ $SHOWTX = point ]]
  then
   printf "."
  elif [[ $SHOWTX = count ]]
  then
  elif [[ $SHOWTX = count ]]
  then
   printf "\r\e[K\e[36m$TXCOUNT \e[0mtransactions created"
  elif [[ $SHOWTX = new ]]
  then
   printf "\r\e[K$TX"
  elif [[ $SHOWTX = count+new ]]
  then
   printf "\r\e[K\e[36m$TXCOUNT \e[0m$TX"
 fi
        ((n++))
 done

 if [[ $SLEEP != 0 ]]
  then
  printf "\n\nStarting $SLEEP sleep phase"
  sleep $SLEEP
  printf "\r\e[K\e[32mSleep phase complete\e[0m"
 fi

 printf "\nChecking last transaction.....\n"
  until (./chain-maind q tx $TX | grep -q $ADDRESS) > /dev/null 2>&1
  do
   printf "\r\e[K\e[33mWARNING: Last transaction is not signed yet \e[0m| Retry No.$RETRY....."
   sleep $CHECKTIME
   RETRY=$(($RETRY+1))
  done
 printf "\n\e[32mLast transaction was successful\n"

 if [[ $RETRY -lt 10 ]]
 then
  printf "\e[32mConfirmed after $RETRY checks\e[0m"
 else
  printf "\e[33mConfirmed after $RETRY checks\e[0m"
 fi

 echo $PASSPHRASE | ./chain-maind tx distribution withdraw-rewards $OPERATOR --from $KEYNAME --chain-id "CHAINID" --gas 800000 --gas-prices="0.1basetcro" --commission --yes > /dev/null 2>&1

 AMOUNT=$(/home/eric/chain-maind q bank balances $ADDRESS | grep amount | cut -d " " -f3|sed 's/"//g')
 CRO=$(( AMOUNT / 100000000 ))

 printf "\nBalance: $CRO tCRO\n\n"

 echo $PASSPHRASE | ./chain-maind tx staking delegate $OPERATOR "$CRO"tcro --from $KEYNAME --chain-id "$CHAINID" --gas 800000 --gas-prices="0.1basetcro" --yes > /dev/null 2>&1

done
