# 🚀 PopChain Quick Start Guide

## Prerequisites

- [x] Sui CLI installed (✅ you have it: `sui 1.59.0`)
- [ ] Node.js installed (optional, for TS test script)
- [ ] Basic understanding of Sui Move

## Step 1: Initialize Sui Client

```bash
# Create a new Sui address for testing
sui client new-address ed25519

# Or if you already have addresses, check them:
sui client addresses
```

## Step 2: Start Local Validator

Start a local Sui network for testing:

```bash
# Start local validator
sui-test-validator

# Keep this running in a separate terminal!
# It will provide:
# - Local blockchain
# - Test faucet
# - RPC endpoint at http://127.0.0.1:9000
```

## Step 3: Build Your Contract

```bash
# Already built! ✅ Check build directory
sui move build

# Should see: "Successfully verified modules"
```

## Step 4: Publish to Local Network

```bash
# Publish your contract
sui client publish --gas-budget 100000000

# You'll get output like:
# Package ID: 0x123abc...
# Created: { ... }
# Changed: { ... }

# Save the Package ID for testing!
```

## Step 5: Test Your Functions

### Initialize Platform

```bash
# Get your package ID from step 4
export PACKAGE_ID="0xYOUR_PACKAGE_ID"

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

**Save the Treasury Object ID** from the output!

### Create a User Account

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

**Save the Account Object ID** from the output!

### Create Event

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

**Save the Event Object ID** from the output!

### Add to Whitelist

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

### Mint Certificate

```bash
# Mint a certificate for the whitelisted attendee
sui client call \
  --package $PACKAGE_ID \
  --module popchain_event \
  --function mint_certificate_for_attendee \
  --args $EVENT_ID $ACCOUNT_ID "0xabcdef1234567890" "0" $TREASURY_ID \
  --gas-budget 100000000

# Args: event account email_hash tier_index treasury
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

Save these as `test-all.sh`:

```bash
#!/bin/bash

# Set your package ID after publishing
export PACKAGE_ID="<YOUR_PACKAGE_ID>"

echo "🧪 Testing PopChain Complete Workflow"
echo "====================================="

# 1. Initialize
echo "1️⃣ Initializing platform..."
sui client call --package $PACKAGE_ID --module popchain_admin --function init_platform \
  --args 1000 5000 2000 --gas-budget 100000000

echo "📋 Check output for TREASURY_ID and save it!"
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
- Verify local validator is running

## Next Steps

1. ✅ Build contract
2. ⬜ Deploy to local network
3. ⬜ Test initialization
4. ⬜ Test user creation
5. ⬜ Test event creation
6. ⬜ Test certificate minting
7. ⬜ Deploy to devnet
8. ⬜ Deploy to mainnet (final step)

For detailed function documentation, see: **TESTING_GUIDE.md**

