1. Find BLOCK_HEIGHT and BLOCK_HASH at [here](https://www.mintscan.io/cosmos/blocks).
2. Init node: ./gaiad_init.sh <custom moniker>
3. Start gaiad service: `systemctl start gaiad`
4. Check log `journalctl -fu gaiad`
5. Enable service: `systemctl enable gaiad`
