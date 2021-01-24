For the automatic-transaction.sh

It does what it says: creates transactions \
After a certain amount of transactions it confirmes, that the last transaction was broadcasted. \
It also withdraws and re-delegates rewards from your validator. \

Download the script, change the variables and run it. \

The options for the SHOWTX variable are: \
true       | show every tx-hash \
new        | show just the newest tx-hash \
count      | show the amount of txs created since the start of the script \
count+new  | show the amount of txs created since the start of the script ans the newest tx-hash \
point      | show a point for every tx created \
false------| show nothing \
