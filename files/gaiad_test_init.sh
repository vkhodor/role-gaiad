#!/bin/bash -i

function usage() {
  echo "Usage: $0 <custom moniker> <block height> <block hash>"
  exit 1
}

if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ]; then
  usage
fi

NODE_MONIKER="$1"
TRUST_HEIGHT="$2"
TRUST_HASH="$3"


##### CONFIGURATION ###

export GENESIS_ZIPPED_URL=https://github.com/hyphacoop/testnets/raw/add-theta-testnet/v7-theta/public-testnet/genesis.json.gz
export NODE_HOME=$HOME/.gaia
export CHAIN_ID=theta-testnet-001
export BINARY=gaiad
export SEEDS="639d50339d7045436c756a042906b9a69970913f@seed-01.theta-testnet.polypore.xyz:26656,3e506472683ceb7ed75c1578d092c79785c27857@seed-02.theta-testnet.polypore.xyz:26656"

##### OPTIONAL STATE SYNC CONFIGURATION ###

export STATE_SYNC=true # if you set this to true, please have TRUST HEIGHT and TRUST HASH and RPC configured
export SYNC_RPC="rpc.sentry-01.theta-testnet.polypore.xyz:26657,rpc.sentry-02.theta-testnet.polypore.xyz:26657"

##############

cd /home/gaia/
echo "getting genesis file"
wget $GENESIS_ZIPPED_URL
gunzip genesis.json.gz

echo "configuring chain..."
$BINARY config chain-id $CHAIN_ID --home $NODE_HOME
$BINARY config keyring-backend test --home $NODE_HOME
$BINARY config broadcast-mode block --home $NODE_HOME
$BINARY init $NODE_MONIKER --home $NODE_HOME --chain-id=$CHAIN_ID

if $STATE_SYNC; then
    echo "enabling state sync..."
    sed -i -e '/enable =/ s/= .*/= true/' $NODE_HOME/config/config.toml
    sed -i -e "/trust_height =/ s/= .*/= $TRUST_HEIGHT/" $NODE_HOME/config/config.toml
    sed -i -e "/trust_hash =/ s/= .*/= \"$TRUST_HASH\"/" $NODE_HOME/config/config.toml
    sed -i -e "/rpc_servers =/ s/= .*/= \"$SYNC_RPC\"/" $NODE_HOME/config/config.toml
else
    echo "disabling state sync..."
fi

echo "copying over genesis file..."
cp genesis.json $NODE_HOME/config/genesis.json


#echo "sudo journalctl -fu $NODE_MONIKER.service"
#echo "***********************"