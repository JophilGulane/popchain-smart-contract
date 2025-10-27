# How to Publish Your PopChain Contract

You've created an address! Now you need gas to publish. Choose one option:

## Option 1: Publish to Local Network (Recommended for Testing)

### Step 1: Start Local Validator
Open a **new terminal window** and run:
```powershell
sui-test-validator
```

Keep this running! It provides:
- Local blockchain
- Automatic gas faucet
- RPC endpoint at http://127.0.0.1:9000

### Step 2: In Your Main Terminal, Publish
```powershell
sui client publish --gas-budget 100000000
```

## Option 2: Publish to Devnet (Public Test Network)

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

## Option 3: Publish to Testnet

```powershell
sui client switch --env testnet
sui client faucet
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

**Save the Package ID!** You'll need it to call functions.

---

## Quick Test After Publishing

Replace `YOUR_PACKAGE_ID` with the actual ID:

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
# ...
```

See **QUICK_START.md** for complete testing guide.

