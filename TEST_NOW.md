# 🚀 Quick Test Commands

Your contract is now published! Here are copy-paste commands to test it:

## Setup

```powershell
# Save your package ID
$PACKAGE_ID = "0xe78838a1ac4fbb3fa00fd6dc9bfbbc7d3e6b6c044725e4deaafd201c98d4bb7c"

# Get your address
$MY_ADDRESS = sui client active-address
```

---

## Test 1: Initialize Platform

```powershell
sui client call `
  --package $PACKAGE_ID `
  --module popchain_admin `
  --function init_platform `
  --args 1000 5000 2000 `
  --gas-budget 100000000
```

**Save the Treasury ID** from the output!

---

## Test 2: Create User Account

```powershell
sui client call `
  --package $PACKAGE_ID `
  --module popchain_user `
  --function create_account `
  --args "0x1234567890abcdef" "1" "$MY_ADDRESS" `
  --gas-budget 100000000
```

**Save the Account ID** from the output!

---

## Test 3: Create Event

```powershell
# Replace these with IDs from tests above
$TREASURY_ID = "<YOUR_TREASURY_ID>"
$ACCOUNT_ID = "<YOUR_ACCOUNT_ID>"

sui client call `
  --package $PACKAGE_ID `
  --module popchain_event `
  --function create_event_with_default_tiers `
  --args "$ACCOUNT_ID" "My Event" "Test Description" "$TREASURY_ID" `
  --gas-budget 100000000
```

---

## View Results

```powershell
# See all your objects
sui client objects

# View a specific object
sui client object <OBJECT_ID>
```

---

## What You Should See

After each command, you'll see:
- Created objects (IDs)
- Transaction digest
- Events emitted

Copy those IDs and use them in the next commands!

---

**See PUBLISHED_CONTRACT_INFO.md for full details!**

