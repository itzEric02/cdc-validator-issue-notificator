#!/bin/bash

ADDRESS=cro17dvkvu6lw5rq4a9jq4uh8lqw7t5sxjze2qn60y # [cro1.....]
KEYNAME=Default
PASSPHRASE=11092002eri.
ACCOUNTNUMBER=37
CHAINID=crossfire

clear

printf "\n'Automated transaction creator' by eric\nbased on a script by samduckling\n\n" #(https://discord.com/channels/783264383978569728/790404424433926155/801438774000091208)

sleep 2s

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


printf "\r\e[K\e[32mScript startup check completed\e[0m\n\n"


n=$(./chain-maind q account $ADDRESS -o json | jq -r .sequence)

while true
do

  echo $PASSPHRASE  | ./chain-maind tx sign tx.json --chain-id $CHAINID --from $KEYNAME --sequence "${n}" --offline -a $ACCOUNTNUMBER > sig

TX=$(./chain-maind tx broadcast sig --chain-id $CHAINID --broadcast-mode async --log_format json | jq -r .txhash)

echo $TX
        ((n++))
done

