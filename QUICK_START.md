# PopChain Quick Start Guide

## Prerequisites

- Sui CLI installed
- Active Sui client
- Testnet access

## Step 1: Build Your Contract

```bash
# Build the Move package
sui move build
```

You should see: "Successfully verified modules"

## Step 2: Publish Your Contract to Testnet

```bash
# Switch to testnet
sui client switch --env testnet

# Get test tokens
sui client faucet

# Publish your contract
sui client publish --gas-budget 100000000

# Save the Package ID from the output!
```

## Step 3: Initialize Platform

```bash
# Set your package ID
export PACKAGE_ID="0xe78838a1ac4fbb3fa00fd6dc9bfbbc7d3e6b6c044725e4deaafd201c98d4bb7c"

# Initialize the PopChain platform
sui client call \
  --package $PACKAGE_ID \
  --module popchain_admin \
  --function init_platform \
  --args 1000 5000 2000 \
  --gas-budget 100000000

# This creates a PlatformTreasury with:
# - Base fee: 1000
# - Event creation fee: 5000
# - Mint fee: 2000
```

Save the Treasury Object ID from the output.

## Step 4: Create a User Account

```bash
# Get your active address
export ACTIVE_ADDRESS=$(sui client active-address)

# Create an organizer account
sui client call \
  --package $PACKAGE_ID \
  --module popchain_user \
  --function create_account \
  --args "0x1234567890abcdef" "1" $ACTIVE_ADDRESS \
  --gas-budget 100000000

# Args: email_hash user_type owner_address
# user_type: 0=Attendee, 1=Organizer, 2=Both
```

Save the Account Object ID from the output.

## Step 5: Deposit Funds to Account

```bash
# First, get a coin object
sui client gas

# Split a coin for deposit
sui client split-coin --coin-id <COIN_ID> --amounts 100000000

# Deposit to account
sui client call \
  --package $PACKAGE_ID \
  --module popchain_wallet \
  --function deposit \
  --args "<ACCOUNT_ID>" "<COIN_ID>" \
  --gas-budget 100000000
```

## Step 6: Create an Event

```bash
export TREASURY_ID="<your_treasury_object_id>"
export ACCOUNT_ID="<your_account_object_id>"

# Create event with default tiers
sui client call \
  --package $PACKAGE_ID \
  --module popchain_event \
  --function create_event_with_default_tiers \
  --args $ACCOUNT_ID "My First Event" "An amazing PopChain event!" $TREASURY_ID \
  --gas-budget 100000000
```

Save the Event Object ID from the output.

## Step 7: Add to Whitelist

```bash
export EVENT_ID="<your_event_object_id>"

# Add email hash to whitelist
sui client call \
  --package $PACKAGE_ID \
  --module popchain_event \
  --function add_to_whitelist \
  --args $EVENT_ID "0xabcdef1234567890" \
  --gas-budget 100000000
```

## Step 8: Mint Certificate

```bash
# Mint a certificate for the whitelisted attendee
sui client call \
  --package $PACKAGE_ID \
  --module popchain_event \
  --function mint_certificate_for_attendee \
  --args $EVENT_ID $ORGANIZER_ACCOUNT_ID $ATTENDEE_ACCOUNT_ID $CERT_URL "0" $TREASURY_ID \
  --gas-budget 100000000

# Args: event organizer_account attendee_account certificate_url tier_index treasury
# tier_index: 0-3 (PopPass, PopBadge, PopMedal, PopTrophy)
```

## View Your Objects

```bash
# List all your objects
sui client objects

# Get details of a specific object
sui client object <OBJECT_ID>

# View transaction history
sui client transactions
```

## View Events

```bash
# Get transaction details with events
sui client transaction <TRANSACTION_DIGEST> --json
```

## Complete Testing Workflow

Save these as test-all.sh:

```bash
#!/bin/bash

# Set your package ID after publishing
export PACKAGE_ID="<YOUR_PACKAGE_ID>"

echo "Testing PopChain Complete Workflow"
echo "==================================="

# 1. Initialize
echo "1. Initializing platform..."
sui client call --package $PACKAGE_ID --module popchain_admin --function init_platform \
  --args 1000 5000 2000 --gas-budget 100000000

echo "Check output for TREASURY_ID and save it!"

# 2. Create account
echo "2. Creating organizer account..."
EMAIL_HASH="0x1234567890abcdef"
sui client call --package $PACKAGE_ID --module popchain_user --function create_account \
  --args $EMAIL_HASH "1" "$(sui client active-address | head -n 1)" --gas-budget 100000000

echo "Test complete!"
```

## Troubleshooting

### "No gas objects"
```bash
# Request test tokens from faucet
sui client faucet
```

### "Config file doesn't exist"
```bash
# Initialize client
sui client new-address ed25519
```

### "Package not found"
- Make sure you copied the correct Package ID from publishing step
- Verify testnet connection is working

## Next Steps

1. Build contract
2. Deploy to testnet
3. Test initialization
4. Test user creation
5. Test event creation
6. Test certificate minting
7. Deploy to mainnet (final step)

For detailed function documentation, see: TESTING_GUIDE.md
