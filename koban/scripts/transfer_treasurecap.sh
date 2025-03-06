#!/bin/bash

#
# Transfer a treasure cap to multisig address

# testnet
PACKAGE_ID="0xdeaf64dc3913d25cc00e3daeedc62bbc8e46ed18b4441a3490bd15cfb33f421f"
TREASURY_CAP_ID="0x5dd3ccf722ff55c0a05e6668756072a8f7b2df56f78090e879762bc4dd90e9d4"
RECIPIENT="0x639059ed8f3f7982789e47976638ba956b2060c07d9a60e8ce0e869d1983306a"
TREASURY_CAP_TYPE="0x2::coin::TreasuryCap<0xdeaf64dc3913d25cc00e3daeedc62bbc8e46ed18b4441a3490bd15cfb33f421f::koban::KOBAN>"

# mainnet test
# PACKAGE_ID="0x647e54708f9cc5adad1b2ee22ead31c47b766e7bea5b6344ec706ac3efdca21b"
# TREASURY_CAP_ID="0x5caccbe9570ec8b1b2c577daca6fd169b6f145ba802bc5e2784b989d465eb9e8"
# RECIPIENT="0x82524b1f08801ee623993543a56b95a845081472977fd1d2f39b30e095ef5d99"

sui client call --package 0x2 --module transfer --function public_transfer --gas-budget 1000000000 --type-args $TREASURY_CAP_TYPE --args $TREASURY_CAP_ID $RECIPIENT

