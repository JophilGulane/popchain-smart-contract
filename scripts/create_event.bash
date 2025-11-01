export TREASURY_ID=0x1395372a14688b592a909ad70b6bc0117e98c772e15f1095d12c2b31ddbc4ae2
export ACCOUNT_ID=0x7e79984ffc01047ea4d86ce971b8d3cada2ea7c052940df4b2c2d0a4b09d67a9
export PACKAGE_ID=0xb110d5c44ff27551915e5a9287df8b61cf77ce92d4fa75ba21b58845fd111b76

# Create event with default tiers
sui client call \
  --package $PACKAGE_ID \
  --module popchain_event \
  --function create_event_with_default_tiers \
  --args $ACCOUNT_ID "First PopChain Event!" "First ever amazing PopChain event!" $TREASURY_ID \
  --gas-budget 100000000