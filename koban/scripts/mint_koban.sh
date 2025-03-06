#!/bin/bash

#
# Mints a Koban coin.

# testnet
PACKAGE_ID="0x7b148e0fd4170eea84566ae1fb720a6ced17abbba4283e20f7fdad9cc8342760"
TREASURY_CAP_ID="0x1e6c500036778bb8d1be63c1515542f2a026a0768c668174fe85d144586f51b6"
RECIPIENT="0x17f32f59ffc95c7fe70c3eabe91ff0b2c810a7b72f8e087a31f694e9d9683f0b"

# mainnet test
# PACKAGE_ID="0x0c4eab8ea6d55cab1a63c2fbdc9070b3c6c37253f0ee1b9dfbe8abab344f779c"
# TREASURY_CAP_ID="0x7af3ebdd88888f93ec39530b4e26928db49fdddebde589feabd3ac6c3286f692"
# RECIPIENT="0x550068faedf9b090a6ab5370908e47ef346f3929ed1bf7c64bf16be48d2a3bbd"

sui client call --package $PACKAGE_ID --module koban --function mint --gas-budget 1000000000 --args $TREASURY_CAP_ID 1000000000000 $RECIPIENT


