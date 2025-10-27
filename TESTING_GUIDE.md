# PopChain Smart Contract Testing Guide

## 🚀 Quick Start

### 1. Build Your Contract
```bash
sui move build
```

Your contract is already built! ✅ (I can see the build output)

### 2. Start Local Sui Network (if not running)
```bash
# Start a local validator
sui-test-validator

# This starts a local blockchain node at:
# - JSON-RPC: http://127.0.0.1:9000
# - WebSocket RPC: ws://127.0.0.1:9000
# - Fullnode RPC: http://127.0.0.1:9000
```

### 3. Deploy Your Contract
```bash
# Deploy to local network
sui client publish --gas-budget 100000000 --json

# Or set active environment
sui client active-address
sui client publish --gas-budget 100000000
```

After deployment, you'll get a **Package ID** - save this for testing!

## 📝 Testing Your Contract Functions

### Workflow Overview

```
1. Initialize Platform (create treasury)
2. Create User Account
3. Deposit Funds
4. Create Event
5. Add to Whitelist
6. Mint Certificate
7. Withdraw Funds
```

### Step-by-Step Testing Commands

#### 1. Initialize Platform
```bash
sui client call \
  --package <YOUR_PACKAGE_ID> \
  --module popchain_admin \
  --function init_platform \
  --args 1000 5000 2000 \
  --gas-budget 100000000

# Args: base_fee event_creation_fee mint_fee
# Returns: PlatformTreasury object (save the object ID!)
```

#### 2. Create User Account
```bash
# First, hash your email (optional, you can use a test hash)
sui client call \
  --package <YOUR_PACKAGE_ID> \
  --module popchain_user \
  --function create_account \
  --args "<email_hash_hex>" "1" "<your_wallet_address>" \
  --gas-budget 100000000

# Args: email_hash user_type owner_address
# user_type: 0=Attendee, 1=Organizer, 2=Both
```

#### 3. Deposit Funds to Account
```bash
# First, get some SUI coins
sui client gas --json

# Then deposit (you'll need a Coin<SUI>)
sui client call \
  --package <YOUR_PACKAGE_ID> \
  --module popchain_wallet \
  --function deposit \
  --args "<account_object_id>" "<coin_object_id>" \
  --gas-budget 100000000
```

#### 4. Create Event with Default Tiers
```bash
sui client call \
  --package <YOUR_PACKAGE_ID> \
  --module popchain_event \
  --function create_event_with_default_tiers \
  --args "<account_object_id>" "My Event" "Description here" "<treasury_object_id>" \
  --gas-budget 100000000
```

#### 5. Add to Whitelist
```bash
# Get the event object ID from step 4
sui client call \
  --package <YOUR_PACKAGE_ID> \
  --module popchain_event \
  --function add_to_whitelist \
  --args "<event_object_id>" "<email_hash_hex>" \
  --gas-budget 100000000
```

#### 6. Mint Certificate
```bash
sui client call \
  --package <YOUR_PACKAGE_ID> \
  --module popchain_event \
  --function mint_certificate_for_attendee \
  --args "<event_object_id>" "<account_object_id>" "<email_hash>" "0" "<treasury_object_id>" \
  --gas-budget 100000000
```

## 🧪 Complete Test Script Example

Save this as `test-popchain.sh`:

```bash
#!/bin/bash

# Replace with your actual package ID after deployment
PACKAGE_ID="0x..."

echo "🧪 Testing PopChain Smart Contract"

# Initialize Platform
echo "1️⃣ Initializing platform..."
sui client call --package $PACKAGE_ID --module popchain_admin --function init_platform \
  --args 1000 5000 2000 --gas-budget 100000000

# Create Organizer Account
echo "2️⃣ Creating organizer account..."
EMAIL_HASH="0x1234567890abcdef" # Replace with actual hash
sui client call --package $PACKAGE_ID --module popchain_user --function create_account \
  --args $EMAIL_HASH "1" "0x$(sui client active-address | head -n 1)" --gas-budget 100000000

echo "✅ Test complete!"
```

Make it executable:
```bash
chmod +x test-popchain.sh
./test-popchain.sh
```

## 🔍 Query and Inspect Objects

### List Your Objects
```bash
sui client objects
```

### Get Object Details
```bash
sui client object <OBJECT_ID>
```

### View Package Info
```bash
sui client object <PACKAGE_ID>
```

## 📊 Monitor Events

After calling functions, check events:
```bash
sui client transaction <TRANSACTION_DIGEST>
```

Look for events like:
- `CreatedAccount`
- `PlatformInitialized`
- `Deposited`
- `EventCreated`
- `CertificateMinted`

## 🎯 Quick Testing Tips

1. **Get Active Address**: `sui client active-address`
2. **Get Gas**: `sui client gas`
3. **Get Object by ID**: `sui client object <ID>`
4. **View Package**: `sui client object <PACKAGE_ID>`

## 🔐 Setting Up Test Environment

```bash
# Set active address
sui client switch --address <WALLET_ADDRESS>

# Get gas for testing
sui client gas --json

# View all addresses
sui client addresses
```

## 📚 Next Steps

1. **Deploy to Devnet**: Change to devnet environment
   ```bash
   sui client env
   sui client switch --env devnet
   ```

2. **Deploy to Mainnet**: Change to mainnet (USE CAUTION!)
   ```bash
   sui client switch --env mainnet
   ```

3. **Create Integration Tests**: Write Move unit tests in `tests/` directory

