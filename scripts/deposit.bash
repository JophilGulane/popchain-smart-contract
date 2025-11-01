export PACKAGE_ID=0xb110d5c44ff27551915e5a9287df8b61cf77ce92d4fa75ba21b58845fd111b76

sui client split-coin --coin-id 0x3221f132465adcd34b8e989741dec71865cc5d229fb85ca0d745cf70f93bd0aa --amounts 100000000

Deposit to account
sui client call \
  --package $PACKAGE_ID \
  --module popchain_wallet \
  --function deposit \
  --args 0x7e79984ffc01047ea4d86ce971b8d3cada2ea7c052940df4b2c2d0a4b09d67a9 0x3221f132465adcd34b8e989741dec71865cc5d229fb85ca0d745cf70f93bd0aa \
  --gas-budget 100000000


