
#!/bin/sh

ADDRESS= #[cro1....]
KEYNAME=Default
PASSPHRASE=
OPERATOR= #[crocncl1....]
CHAINID=crossfire

echo $PASSPHRASE | ./chain-maind tx distribution withdraw-rewards $OPERATOR --from $KEYNAME --chain-id "CHAINID" --gas 800000 --gas-prices="0.1basetcro" --commission --yes


AMOUNT=$(/home/eric/chain-maind q bank balances $ADDRESS | grep amount | cut -d " " -f3|sed 's/"//g')
CRO=$(( AMOUNT / 100000000 ))
printf "Balance: $CRO tCRO"
echo $AMOUNT

echo $PASSPHRASE | ./chain-maind tx staking delegate $OPERATOR "$CRO"tcro --from $KEYNAME --chain-id "$CHAINID" --gas 800000 --gas-prices="0.1basetcro" --yes
