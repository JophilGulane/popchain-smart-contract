# PopChain Smart Contract - Testing Guide

This guide explains how to test all functions in the PopChain smart contract.

## Prerequisites

1. **Sui CLI installed** and configured
2. **Active Sui client** with testnet access
3. **Published contract** - get your Package ID after publishing
4. **Test SUI tokens** - use `sui client faucet` if needed

## Quick Setup

```bash
# Build the contract
sui move build

# Switch to testnet
sui client switch --env testnet

# Get test tokens
sui client faucet

# Publish the contract
sui client publish --gas-budget 100000000

# Save the Package ID from the output!
```

## Testing Workflow

### Complete Testing Flow

```
1. Initialize Platform (create treasury)
2. Create User Accounts (Attendee & Organizer)
3. Deposit Funds to Accounts
4. Create Event
5. Add Attendees to Whitelist
6. Mint Certificates
7. Link Wallets
8. Transfer Certificates to Wallets
9. Withdraw Funds
```

---

## Function Testing Guide

### 1. Initialize Platform

Creates the platform treasury with fee settings.

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module popchain_admin \
  --function init_platform \
  --args 1000 5000 2000 \
  --gas-budget 100000000
```

**Arguments:**
- `1000` - Base fee (MIST)
- `5000` - Event creation fee (MIST)
- `2000` - Certificate minting fee (MIST)

**What to save:** Treasury Object ID from the output

**Verify:**
```bash
sui client object <TREASURY_ID>
```

---

### 2. Create User Account

Creates a PopChain account for attendees or organizers.

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module popchain_user \
  --function create_account \
  --args <EMAIL_HASH> <USER_TYPE> <OWNER_ADDRESS> \
  --gas-budget 100000000
```

**Arguments:**
- `<EMAIL_HASH>` - Hashed email (vector<u8>), e.g., `0x1234567890abcdef`
- `<USER_TYPE>` - `0` = Attendee, `1` = Organizer, `2` = Both
- `<OWNER_ADDRESS>` - Wallet address or `0x0000000000000000000000000000000000000000000000000000000000000000` for no wallet

**Examples:**
```bash
# Create attendee account with no wallet
sui client call \
  --package <PACKAGE_ID> \
  --module popchain_user \
  --function create_account \
  --args "0x1234567890abcdef" "0" "0x0000000000000000000000000000000000000000000000000000000000000000" \
  --gas-budget 100000000

# Create organizer account with wallet
sui client call \
  --package <PACKAGE_ID> \
  --module popchain_user \
  --function create_account \
  --args "0xabcdef1234567890" "1" "$(sui client active-address)" \
  --gas-budget 100000000
```

**What to save:** Account Object ID from the output

**Events:** `CreatedAccount` event emitted

---

### 3. Link Wallet

Links a wallet address to an existing account.

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module popchain_user \
  --function link_wallet \
  --args <ACCOUNT_ID> <WALLET_ADDRESS> \
  --gas-budget 100000000
```

**Arguments:**
- `<ACCOUNT_ID>` - The PopChainAccount object ID
- `<WALLET_ADDRESS>` - Valid wallet address (cannot be `0x0`)

**Example:**
```bash
WALLET=$(sui client active-address)

sui client call \
  --package <PACKAGE_ID> \
  --module popchain_user \
  --function link_wallet \
  --args <ACCOUNT_ID> $WALLET \
  --gas-budget 100000000
```

**Verify:**
```bash
sui client object <ACCOUNT_ID> --json | grep owner_address
```

**Events:** `WalletLinked` event emitted with old_address and new_address

**Error Cases:**
- Trying to link `0x0` → `e_invalid_address()` error

---

### 4. Deposit Funds

Deposits SUI coins to a PopChain account.

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module popchain_wallet \
  --function deposit \
  --args <ACCOUNT_ID> <COIN_OBJECT_ID> \
  --gas-budget 100000000
```

**Getting a coin:**
```bash
# Split a coin
sui client split-coin --coin-id <GAS_COIN_ID> --amounts 100000000

# Or use a gas coin
sui client gas --json | jq '.[0].gasCoinId'
```

**Verify:**
```bash
sui client object <ACCOUNT_ID> --json | jq '.data.content.fields.balance'
```

**Events:** `Deposited` event emitted

---

### 5. Create Event

Creates an event with default PopChain tiers.

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module popchain_event \
  --function create_event_with_default_tiers \
  --args <ORGANIZER_ACCOUNT_ID> "<EVENT_NAME>" "<DESCRIPTION>" <TREASURY_ID> \
  --gas-budget 100000000
```

**Arguments:**
- `<ORGANIZER_ACCOUNT_ID>` - Must be an Organizer account
- `<EVENT_NAME>` - Event name (string)
- `<DESCRIPTION>` - Event description (string)
- `<TREASURY_ID>` - PlatformTreasury object ID

**Example:**
```bash
sui client call \
  --package <PACKAGE_ID> \
  --module popchain_event \
  --function create_event_with_default_tiers \
  --args <ORGANIZER_ACCOUNT_ID> "Web3 Conference" "Amazing blockchain event" <TREASURY_ID> \
  --gas-budget 100000000
```

**What to save:** Event Object ID from the output

**Events:** `EventCreated` event emitted

**Error Cases:**
- Non-organizer account → `e_not_organizer()` error
- Insufficient funds → `e_insufficient_funds()` error

---

### 6. Add to Whitelist

Adds an attendee's email to the event whitelist.

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module popchain_event \
  --function add_to_whitelist \
  --args <EVENT_ID> <EMAIL_HASH> \
  --gas-budget 100000000
```

**Arguments:**
- `<EVENT_ID>` - Event object ID
- `<EMAIL_HASH>` - Hashed email (must match attendee's account email hash)

**Events:** `AddedToWhitelist` event emitted

**Error Cases:**
- Unauthorized (not organizer) → `e_unauthorized()` error

---

### 7. Mint Certificate

Mints a certificate NFT to an attendee's account.

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module popchain_event \
  --function mint_certificate_for_attendee \
  --args <EVENT_ID> <ORGANIZER_ACCOUNT_ID> <ATTENDEE_ACCOUNT_ID> <CERTIFICATE_URL_HASH> <TIER_INDEX> <TREASURY_ID> \
  --gas-budget 100000000
```

**Arguments:**
- `<EVENT_ID>` - Event object ID
- `<ORGANIZER_ACCOUNT_ID>` - Organizer's PopChainAccount
- `<ATTENDEE_ACCOUNT_ID>` - Attendee's PopChainAccount
- `<CERTIFICATE_URL_HASH>` - Hash of certificate metadata URL (vector<u8>), e.g., `0x00`
- `<TIER_INDEX>` - Tier index (0 = PopPass, 1 = PopBadge, 2 = PopMedal, 3 = PopTrophy)
- `<TREASURY_ID>` - PlatformTreasury object ID

**Behavior:**
- If attendee has linked wallet: Certificate goes directly to wallet
- If attendee has no wallet (`owner_address = 0x0`): Certificate transferred to `0x0` (cannot be retrieved)

**What to save:** Certificate Object ID from the output

**Events:** 
- `CertificateMinted` event emitted
- `CertificateMintedToAttendee` event emitted

**Error Cases:**
- Event closed → `e_event_closed()` error
- Not whitelisted → `e_not_whitelisted()` error
- Invalid tier → `e_invalid_tier()` error
- Insufficient funds → `e_insufficient_funds()` error

---

### 8. Transfer Certificate to Wallet

Transfers a certificate NFT from the account to the attendee's linked wallet.

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module popchain_certificate \
  --function transfer_certificate_to_wallet \
  --args <ACCOUNT_ID> <CERTIFICATE_OBJECT_ID> \
  --gas-budget 100000000
```

**Arguments:**
- `<ACCOUNT_ID>` - Attendee's PopChainAccount (must have linked wallet)
- `<CERTIFICATE_OBJECT_ID>` - The CertificateNFT object (must be accessible to caller)

**Requirements:**
- Account must have linked wallet (`owner_address != 0x0`)
- Certificate must be in account's certificates vector
- Caller must have access to the certificate object

**Events:** `CertificateTransferredToWallet` event emitted

**Error Cases:**
- No wallet linked → `e_invalid_address()` error
- Certificate not in account → `e_unauthorized()` error

**Note:** Certificates minted to `0x0` (before wallet linking) cannot be retrieved in Sui and cannot be transferred.

---

### 9. Withdraw Funds

Withdraws funds from a PopChain account to the wallet.

```bash
sui client call \
  --package <PACKAGE_ID> \
  --module popchain_wallet \
  --function withdraw \
  --args <ACCOUNT_ID> <AMOUNT> \
  --gas-budget 100000000
```

**Arguments:**
- `<ACCOUNT_ID>` - PopChainAccount object ID
- `<AMOUNT>` - Amount in MIST to withdraw

**Requirements:**
- Caller must be the account owner (`tx_context::sender() == owner_address`)
- Account must have sufficient balance

**Events:** `Withdrawn` event emitted

**Error Cases:**
- Unauthorized (not owner) → `e_unauthorized()` error
- Insufficient funds → `e_insufficient_funds()` error

---

## Querying and Verification

### Check Object Details

```bash
# Get object details
sui client object <OBJECT_ID>

# Get object details as JSON
sui client object <OBJECT_ID> --json

# Get specific fields
sui client object <OBJECT_ID> --json | jq '.data.content.fields'
```

### List Your Objects

```bash
# List all objects owned by active address
sui client objects

# List objects for specific address
sui client objects <ADDRESS>
```

### View Transaction Details

```bash
# Get transaction details
sui client transaction <TRANSACTION_DIGEST>

# Get transaction details as JSON
sui client transaction <TRANSACTION_DIGEST> --json

# View events
sui client transaction <TRANSACTION_DIGEST> --json | jq '.events'
```

### View Package Information

```bash
sui client object <PACKAGE_ID>
```

---

## Event Types

Monitor these events after transactions:

- `CreatedAccount` - Account created
- `WalletLinked` - Wallet linked to account
- `Deposited` - Funds deposited to account
- `Withdrawn` - Funds withdrawn from account
- `PlatformInitialized` - Platform treasury created
- `EventCreated` - Event created
- `AddedToWhitelist` - Attendee added to whitelist
- `RemovedFromWhitelist` - Attendee removed from whitelist
- `EventClosed` - Event closed
- `CertificateMinted` - Certificate NFT minted
- `CertificateMintedToAttendee` - Certificate minted to attendee
- `CertificateTransferredToWallet` - Certificate transferred to wallet

---

## Common Testing Scenarios

### Scenario 1: Complete Flow - Attendee with Wallet

```bash
# 1. Initialize platform
# 2. Create attendee account WITH wallet
# 3. Create organizer account
# 4. Create event
# 5. Add to whitelist
# 6. Mint certificate → goes directly to wallet
```

### Scenario 2: Attendee Without Wallet (Link Later)

```bash
# 1. Create attendee account WITHOUT wallet (use 0x0)
# 2. Create event and mint certificate (certificate goes to 0x0)
# 3. Link wallet later
# 4. Note: Certificate at 0x0 cannot be retrieved
# 5. Mint NEW certificate after linking → goes to wallet
```

### Scenario 3: Link Wallet Then Mint

```bash
# 1. Create account with 0x0
# 2. Link wallet
# 3. Create event and mint certificate → goes directly to wallet
```

---

## Troubleshooting

### Error: "Package ID not found"
- **Solution**: Make sure you've published the contract and are using the correct Package ID

### Error: "Insufficient funds"
- **Solution**: Deposit funds to the account or get more gas tokens: `sui client faucet`

### Error: "Unauthorized"
- **Solution**: Verify you're using the correct account and have proper permissions

### Error: "Invalid address" (when linking wallet)
- **Solution**: Cannot link `0x0`. Use a valid wallet address.

### Error: "Certificate not found"
- **Solution**: Certificates minted to `0x0` cannot be retrieved. Mint new certificates after linking wallet.

### Error: "Expected X args, found Y"
- **Solution**: Check argument count and types match the function signature

---

## Tips

1. **Save all Object IDs** from transaction outputs
2. **Use `--json` flag** for easier parsing of outputs
3. **Check events** to verify function execution
4. **Test error cases** to ensure proper validation
5. **Start with small amounts** when testing financial operations
6. **Use testnet** before deploying to mainnet

---

## Quick Reference

### Get Active Address
```bash
sui client active-address
```

### Get Gas/Coins
```bash
sui client gas
sui client faucet
```

### Split Coin
```bash
sui client split-coin --coin-id <COIN_ID> --amounts 100000000
```

### Switch Networks
```bash
sui client switch --env testnet
sui client switch --env devnet
sui client switch --env mainnet
```

---

## Next Steps

1. Test all functions individually
2. Test complete workflows
3. Test error cases and edge cases
4. Monitor gas costs
5. Deploy to mainnet when ready
