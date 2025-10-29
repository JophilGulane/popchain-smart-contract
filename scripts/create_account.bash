export ACTIVE_ADDRESS=$(sui client active-address)
export PACKAGE_ID=0xb110d5c44ff27551915e5a9287df8b61cf77ce92d4fa75ba21b58845fd111b76

# Create an organizer account
sui client call \
  --package $PACKAGE_ID \
  --module popchain_user \
  --function create_account \
  --args "bacaltosbaryshnikov@gmail.com" "2" $ACTIVE_ADDRESS \
  --gas-budget 100000000