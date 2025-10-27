# How to Publish Your PopChain Contract

Choose a network option:

## Option 1: Publish to Testnet (Recommended)

### Step 1: Switch to Testnet
```powershell
sui client switch --env testnet
```

### Step 2: Request Test Tokens
```powershell
sui client faucet
```

### Step 3: Publish
```powershell
sui client publish --gas-budget 100000000
```

---

## Option 2: Publish to Devnet (Alternative Test Network)

### Step 1: Switch to Devnet
```powershell
sui client switch --env devnet
```

### Step 2: Request Test Tokens
```powershell
sui client faucet
```

### Step 3: Publish
```powershell
sui client publish --gas-budget 100000000
```

---

## After Publishing

You'll get output like:
```
Published Objects:
  ┌──
  │ PackageID: 0x123...
  │ ...
  │ Created: PlatformTreasury(...)
  └──
```

Save the Package ID! You'll need it to call functions.

---

## Quick Test After Publishing

Replace YOUR_PACKAGE_ID with the actual ID:

```powershell
# Get the package ID from publish output
$PACKAGE_ID = "0xYOUR_PACKAGE_ID"

# Initialize platform
sui client call `
  --package $PACKAGE_ID `
  --module popchain_admin `
  --function init_platform `
  --args 1000 5000 2000 `
  --gas-budget 100000000

# Save the Treasury ID from output, then create a user account
```

See QUICK_START.md for complete testing guide.
