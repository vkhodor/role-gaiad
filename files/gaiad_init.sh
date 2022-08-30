#!/usr/bin/env bash

function usage() {
  echo "Usage: $0 <custom moniker> <block height> <block hash>"
  exit 1
}

if [ "$1" == "" ] || [ "$2" == "" ] || [ "$3" == "" ]; then
  usage
fi

CUSTOM_MONIKER="$1"
BLOCK_HEIGHT="$2"
BLOCK_HASH="$3"
GENESIS_FILENAME="genesis.cosmoshub-4.json"
GENESIS_URL="https://raw.githubusercontent.com/cosmos/mainnet/master/genesis/${GENESIS_FILENAME}.gz"


if [[ -d "$HOME/.gaia/config" ]]; then
  echo "Gaia is already inited."
  exit 2
fi

gaiad init $CUSTOM_MONIKER

# Prepare genesis file for cosmoshub-4
wget $GENESIS_URL
gzip -d ${GENESIS_FILENAME}.gz
mv $GENESIS_FILENAME $HOME/.gaia/config/genesis.json

cd $HOME/.gaia/config

#Set minimum gas price & peers
sed -i 's/minimum-gas-prices = ""/minimum-gas-prices = "0.001uatom"/' app.toml
sed -i 's/persistent_peers = ""/persistent_peers = "6e08b23315a9f0e1b23c7ed847934f7d6f848c8b@165.232.156.86:26656,ee27245d88c632a556cf72cc7f3587380c09b469@45.79.249.253:26656,538ebe0086f0f5e9ca922dae0462cc87e22f0a50@34.122.34.67:26656,d3209b9f88eec64f10555a11ecbf797bb0fa29f4@34.125.169.233:26656,bdc2c3d410ca7731411b7e46a252012323fbbf37@34.83.209.166:26656,585794737e6b318957088e645e17c0669f3b11fc@54.160.123.34:26656,5b4ed476e01c49b23851258d867cc0cfc0c10e58@206.189.4.227:26656"/' config.toml

# Configure State sync
sed -i 's/enable = false/enable = true/' config.toml
sed -i "s/trust_height = 0/trust_height = $BLOCK_HEIGHT/" config.toml
sed -i "s/trust_hash = \"\"/trust_hash = \"$BLOCK_HASH\"/" config.toml
sed -i 's/rpc_servers = ""/rpc_servers = "https:\/\/rpc.cosmos.network:443,https:\/\/rpc.cosmos.network:443"/' config.toml
