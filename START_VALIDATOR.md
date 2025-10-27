# Starting Sui Validator for Testing

## Quick Start

**Open a new PowerShell window** and run:

```powershell
sui-test-validator
```

Leave this running! ✅

This will:
- Start a local blockchain
- Provide free gas automatically
- Listen on http://127.0.0.1:9000

---

## Then in Your Main Terminal

Go back to your main terminal and publish:

```powershell
sui client publish --gas-budget 100000000
```

---

## What You'll See After Publishing

You'll get output like:

```
Published Objects:
  ┌──
  │ PackageID: 0x1234...
  │ ...
  │ Created: PlatformTreasury(...)
  └──
```

**Copy the Package ID!** You'll need it to test your functions.

---

## Alternative: Use Devnet (Test Network)

If you prefer using a public test network:

```powershell
# Switch to devnet
sui client switch --env devnet

# Get free tokens
sui client faucet

# Publish
sui client publish --gas-budget 100000000
```

See **HOW_TO_PUBLISH.md** for more details!

