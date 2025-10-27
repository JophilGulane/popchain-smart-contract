# Getting Test Tokens for Sui

You need test tokens (SUI) to publish your contract on testnet. Here's how:

## Step 1: Get Test Tokens

Visit this URL in your browser:

**https://faucet.sui.io/?address=0x07e8e9281692ed356d8ccb48810c7132948952fa285ec87e98f9253d6c464b79**

This will give you free test tokens on Sui testnet.

## Step 2: Verify You Got Tokens

Run this command to check:

```powershell
sui client gas
```

You should see gas coins owned by your address.

## Step 3: Publish Your Contract

Once you have tokens:

```powershell
sui client publish --gas-budget 100000000
```

## Alternative: Use a Different Address

If you want to use a different address or check which address you're using:

```powershell
# List all your addresses
sui client addresses

# See which is active
sui client active-address
```

Then use that address in the faucet URL.

---

**After getting tokens and publishing, your Package ID will be displayed!**

