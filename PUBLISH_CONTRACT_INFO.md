# PopChain Smart Contract - Complete Function Testing Results

**Package ID:** `0x693e93be3f466587f4f2c01186a7d00e45fa0da7694f2eba18ab8b8447425981`  
**Network:** Sui Testnet  
**Test Date:** 2025-01-02

**Active Test Address:** `0x4db49f908f2d6ee57e1d131a3a4137885addb7b3c5ab98b8b9bb39f736828c03`

**Note:** To continue testing functions 5-11, you need testnet SUI tokens. Get them from the faucet:
https://faucet.sui.io/?address=0x4db49f908f2d6ee57e1d131a3a4137885addb7b3c5ab98b8b9bb39f736828c03

---

## Test Results Summary

| # | Function | Module | Status | Transaction | SuiScan Link |
|---|----------|--------|--------|-------------|--------------|
| 1 | init_platform | popchain_admin | ✅ Success | DFqWgA82FpoiP58YAfoHkcv2f3jVngmM7dyTg5K9DkE1 | https://suiscan.xyz/testnet/tx/DFqWgA82FpoiP58YAfoHkcv2f3jVngmM7dyTg5K9DkE1 |
| 2 | create_account (Organizer) | popchain_user | ✅ Success | 5U1ucrBMgyewt7DWWVJ1czYytKZuSBxEEFUWvYoXMc4J | https://suiscan.xyz/testnet/tx/5U1ucrBMgyewt7DWWVJ1czYytKZuSBxEEFUWvYoXMc4J |
| 3 | create_account (Attendee) | popchain_user | ✅ Success | DpJD6oGooWhc3R4hK4wzP2qdiHNe9ceE9XSeeX2BYGMD | https://suiscan.xyz/testnet/tx/DpJD6oGooWhc3R4hK4wzP2qdiHNe9ceE9XSeeX2BYGMD |
| 4 | link_wallet | popchain_user | ✅ Success | ADKwpJHYT2K2GwsLTBZLtpjg9tYBYNJ6Yisi9U57pbnF | https://suiscan.xyz/testnet/tx/ADKwpJHYT2K2GwsLTBZLtpjg9tYBYNJ6Yisi9U57pbnF |
| 5 | deposit | popchain_wallet | ✅ Success | DD2aafPd3ZHF7UQtQShoqkECnJAKhNoSwUHw3hp3euuV | https://suiscan.xyz/testnet/tx/DD2aafPd3ZHF7UQtQShoqkECnJAKhNoSwUHw3hp3euuV |
| 6 | create_event_with_default_tiers | popchain_event | ✅ Success | CzoC5X5VUqJxRZVoC3vqd4agQD1WrUmmB2P6xhcV6B7o | https://suiscan.xyz/testnet/tx/CzoC5X5VUqJxRZVoC3vqd4agQD1WrUmmB2P6xhcV6B7o |
| 7 | add_to_whitelist | popchain_event | ✅ Success | HF82pSNMJk26dVuXd97TPHnLZk92f3rA6YRR22MtcLib | https://suiscan.xyz/testnet/tx/HF82pSNMJk26dVuXd97TPHnLZk92f3rA6YRR22MtcLib |
| 8 | mint_certificate_for_attendee | popchain_event | ✅ Success | CssF5sbaVgufbPdSsRJBgGNq4z8oHsXwkE73NAveb6RF | https://suiscan.xyz/testnet/tx/CssF5sbaVgufbPdSsRJBgGNq4z8oHsXwkE73NAveb6RF |
| 9 | transfer_certificate_to_wallet | popchain_certificate | ✅ Success | 8gHiMSu2PSYdon1Sff1kksGf8KRPy2FmomutCdoP35uo | https://suiscan.xyz/testnet/tx/8gHiMSu2PSYdon1Sff1kksGf8KRPy2FmomutCdoP35uo |
| 10 | withdraw | popchain_wallet | ✅ Success | 2xAVETMd8HsJvCgomqrPhy1qUbQ2Ch5BKQ2CcW1Jrbt3 | https://suiscan.xyz/testnet/tx/2xAVETMd8HsJvCgomqrPhy1qUbQ2Ch5BKQ2CcW1Jrbt3 |
| 11 | withdraw_to_owner | popchain_admin | ✅ Success | BScVdgxKjbqnpyCQi2gg6L56iyrRi13MRWEtYVxMrm8d | https://suiscan.xyz/testnet/tx/BScVdgxKjbqnpyCQi2gg6L56iyrRi13MRWEtYVxMrm8d |

---

## Detailed Test Results

### 1. Initialize Platform

**Function:** `init_platform`  
**Module:** `popchain_admin`  
**Purpose:** Initialize the platform and create PlatformTreasury

**Command:**
```bash
sui client call --package <PACKAGE_ID> --module popchain_admin --function init_platform --args 1000 5000 2000 --gas-budget 100000000
```

**Parameters:**
- `base_fee`: 1000 MIST
- `event_creation_fee`: 5000 MIST
- `mint_fee`: 2000 MIST

**Result:**  
✅ Success

---

### 2. Create Organizer Account

**Function:** `create_account`  
**Module:** `popchain_user`  
**Purpose:** Create a PopChain account for an organizer

**Command:**
```bash
sui client call --package <PACKAGE_ID> --module popchain_user --function create_account --args <EMAIL_HASH> "1" <OWNER_ADDRESS> --gas-budget 100000000
```

**Parameters:**
- `email_hash`: Hashed email (vector<u8>)
- `user_type`: 1 (Organizer)
- `owner_address`: Wallet address

**Result:**  
✅ Success

---

### 3. Create Attendee Account

**Function:** `create_account`  
**Module:** `popchain_user`  
**Purpose:** Create a PopChain account for an attendee (without wallet initially)

**Command:**
```bash
sui client call --package <PACKAGE_ID> --module popchain_user --function create_account --args <EMAIL_HASH> "0" "0x0000000000000000000000000000000000000000000000000000000000000000" --gas-budget 100000000
```

**Parameters:**
- `email_hash`: Hashed email (vector<u8>)
- `user_type`: 0 (Attendee)
- `owner_address`: 0x0 (null address, no wallet linked)

**Result:**  
✅ **Success**

**Transaction Digest:** `DpJD6oGooWhc3R4hK4wzP2qdiHNe9ceE9XSeeX2BYGMD`  
**SuiScan:** https://suiscan.xyz/testnet/tx/DpJD6oGooWhc3R4hK4wzP2qdiHNe9ceE9XSeeX2BYGMD

**Created Objects:**
- Attendee Account ID: `0xa2fa642b3e39b99866553f4bc8e45f9b9290c6438ccd48deee74e4b52c7bc122`
- Owner: Shared (version 349180847)
- Owner Address: 0x0 (no wallet linked)

**Event Emitted:** `CreatedAccount`
- Owner: 0x4db49f908f2d6ee57e1d131a3a4137885addb7b3c5ab98b8b9bb39f736828c03
- Owner Address: 0x0000000000000000000000000000000000000000000000000000000000000000
- Role: 0 (Attendee)

**Gas Cost:** 3,046,680 MIST

---

### 4. Link Wallet

**Function:** `link_wallet`  
**Module:** `popchain_user`  
**Purpose:** Link a wallet address to an existing attendee account

**Command:**
```bash
sui client call --package <PACKAGE_ID> --module popchain_user --function link_wallet --args <ACCOUNT_ID> <WALLET_ADDRESS> --gas-budget 100000000
```

**Parameters:**
- `account`: PopChainAccount object ID
- `wallet_address`: Sui wallet address

**Result:**  
✅ **Success**

**Transaction Digest:** `ADKwpJHYT2K2GwsLTBZLtpjg9tYBYNJ6Yisi9U57pbnF`  
**SuiScan:** https://suiscan.xyz/testnet/tx/ADKwpJHYT2K2GwsLTBZLtpjg9tYBYNJ6Yisi9U57pbnF

**Mutated Objects:**
- Attendee Account: `0xa2fa642b3e39b99866553f4bc8e45f9b9290c6438ccd48deee74e4b52c7bc122` (version 349180848)
- owner_address updated from 0x0 to wallet address

**Event Emitted:** `WalletLinked`
- Account ID: 0xa2fa642b3e39b99866553f4bc8e45f9b9290c6438ccd48deee74e4b52c7bc122
- Old Address: 0x0000000000000000000000000000000000000000000000000000000000000000
- New Address: 0x4db49f908f2d6ee57e1d131a3a4137885addb7b3c5ab98b8b9bb39f736828c03

**Gas Cost:** 1,030,248 MIST

---

### 5. Deposit Funds

**Function:** `deposit`  
**Module:** `popchain_wallet`  
**Purpose:** Deposit funds into a PopChain account

**Command:**
```bash
sui client call --package <PACKAGE_ID> --module popchain_wallet --function deposit --args <ACCOUNT_ID> <COIN_ID> --gas-budget 100000000
```

**Parameters:**
- `account`: PopChainAccount object ID (`0xd16ebb1187f4deba6f088e885e737c6e35f64c72bf7c427801f3f3855aa57599`)
- `payment`: Coin<SUI> object ID (need to split from gas balance or get from faucet)

**Result:**  
✅ **Success**

**Transaction Digest:** `DD2aafPd3ZHF7UQtQShoqkECnJAKhNoSwUHw3hp3euuV`  
**SuiScan:** https://suiscan.xyz/testnet/tx/DD2aafPd3ZHF7UQtQShoqkECnJAKhNoSwUHw3hp3euuV

**Split Transaction (pre-deposit):** `9bHXZEtr614tQqfZpjbf2JFu7C65T2Xc4gDYtxPszKiu`

**Event Expected:** `Deposited` - 50,000,000 MIST (0.05 SUI) deposited to account

---

### 6. Create Event

**Function:** `create_event_with_default_tiers`  
**Module:** `popchain_event`  
**Purpose:** Create an event with default certificate tiers

**Command:**
```bash
sui client call --package <PACKAGE_ID> --module popchain_event --function create_event_with_default_tiers --args <ACCOUNT_ID> "Event Name" "Event Description" <TREASURY_ID> --gas-budget 100000000
```

**Parameters:**
- `account`: Organizer's PopChainAccount (`0xd16ebb1187f4deba6f088e885e737c6e35f64c72bf7c427801f3f3855aa57599`)
- `name`: Event name (string) ("CompleteTestEvent-[timestamp]")
- `description`: Event description (string) ("Complete manual testing event")
- `treasury`: PlatformTreasury object ID (`0x672654edf8c115fd27b5195fa1d06a8f74112b0f57792bea500247acb349e16d`)

**Result:**  
✅ **Success**

**Transaction Digest:** `CzoC5X5VUqJxRZVoC3vqd4agQD1WrUmmB2P6xhcV6B7o`  
**SuiScan:** https://suiscan.xyz/testnet/tx/CzoC5X5VUqJxRZVoC3vqd4agQD1WrUmmB2P6xhcV6B7o

**Created Objects:**
- Event ID: `0xf6981050e7a2acd7b3922e12f9966afbd34551a72d02110bcd4bea547377d968`
- Owner: Shared object

**Event Emitted:** `EventCreated`
- Event created with 4 default tiers (PopPass, PopBadge, PopMedal, PopTrophy)

**Note:** Event creation fee deducted from organizer account balance.

---

### 7. Add to Whitelist

**Function:** `add_to_whitelist`  
**Module:** `popchain_event`  
**Purpose:** Add an attendee's email hash to event whitelist

**Command:**
```bash
sui client call --package <PACKAGE_ID> --module popchain_event --function add_to_whitelist --args <EVENT_ID> <EMAIL_HASH> --gas-budget 100000000
```

**Parameters:**
- `event`: Event object ID (`0xf6981050e7a2acd7b3922e12f9966afbd34551a72d02110bcd4bea547377d968`)
- `email_hash`: Hashed email (vector<u8>) (`0x1234567890abcdef`)

**Result:**  
✅ **Success**

**Transaction Digest:** `HF82pSNMJk26dVuXd97TPHnLZk92f3rA6YRR22MtcLib`  
**SuiScan:** https://suiscan.xyz/testnet/tx/HF82pSNMJk26dVuXd97TPHnLZk92f3rA6YRR22MtcLib

**Mutated Objects:**
- Event: `0xf6981050e7a2acd7b3922e12f9966afbd34551a72d02110bcd4bea547377d968` (whitelist updated)

**Event Expected:** `AddedToWhitelist`

---

### 8. Mint Certificate

**Function:** `mint_certificate_for_attendee`  
**Module:** `popchain_event`  
**Purpose:** Mint an NFT certificate to a whitelisted attendee

**Command:**
```bash
sui client call --package <PACKAGE_ID> --module popchain_event --function mint_certificate_for_attendee --args <EVENT_ID> <ORGANIZER_ACCOUNT_ID> <ATTENDEE_ACCOUNT_ID> <CERTIFICATE_URL_HASH> <TIER_INDEX> <TREASURY_ID> --gas-budget 100000000
```

**Parameters:**
- `event`: Event object ID (`0xf6981050e7a2acd7b3922e12f9966afbd34551a72d02110bcd4bea547377d968`)
- `organizer_account`: Organizer's PopChainAccount (`0xd16ebb1187f4deba6f088e885e737c6e35f64c72bf7c427801f3f3855aa57599`)
- `attendee_account`: Attendee's PopChainAccount (`0xa2fa642b3e39b99866553f4bc8e45f9b9290c6438ccd48deee74e4b52c7bc122`)
- `certificate_url_hash`: Certificate metadata URL hash (`0x00`)
- `tier_index`: Tier index (`0` = PopPass)
- `treasury`: PlatformTreasury object ID (`0x672654edf8c115fd27b5195fa1d06a8f74112b0f57792bea500247acb349e16d`)

**Result:**  
✅ **Success**

**Transaction Digest:** `CssF5sbaVgufbPdSsRJBgGNq4z8oHsXwkE73NAveb6RF`  
**SuiScan:** https://suiscan.xyz/testnet/tx/CssF5sbaVgufbPdSsRJBgGNq4z8oHsXwkE73NAveb6RF

**Created Objects:**
- Certificate NFT transferred to attendee's wallet (since wallet is linked)
- Certificate ID: `0x492ec3739735486f6853d5bd040a27f166386b3ac98a02f6640b39e3ec1c6a85`

**Events Emitted:**
- `CertificateMinted` - Certificate minted
- `CertificateMintedToAttendee` - Certificate assigned to attendee

**Note:** Certificate was minted after wallet linking, so it went directly to the wallet address.

---

### 9. Transfer Certificate to Wallet

**Function:** `transfer_certificate_to_wallet`  
**Module:** `popchain_certificate`  
**Purpose:** Transfer a certificate NFT to the attendee's linked wallet

**Command:**
```bash
sui client call --package <PACKAGE_ID> --module popchain_certificate --function transfer_certificate_to_wallet --args <ACCOUNT_ID> <CERTIFICATE_ID> --gas-budget 100000000
```

**Parameters:**
- `account`: Attendee's PopChainAccount
- `certificate`: CertificateNFT object ID

**Note:** Requires certificate to be owned by caller and linked wallet.

**Result:**  
✅ **Success**

**Transaction Digest:** `8gHiMSu2PSYdon1Sff1kksGf8KRPy2FmomutCdoP35uo`  
**SuiScan:** https://suiscan.xyz/testnet/tx/8gHiMSu2PSYdon1Sff1kksGf8KRPy2FmomutCdoP35uo

**Mutated Objects:**
- Certificate: `0x492ec3739735486f6853d5bd040a27f166386b3ac98a02f6640b39e3ec1c6a85` (transferred to wallet)
- Account: `0xa2fa642b3e39b99866553f4bc8e45f9b9290c6438ccd48deee74e4b52c7bc122` (version updated)

**Event Emitted:** `CertificateTransferredToWallet`
- Account ID: 0xa2fa642b3e39b99866553f4bc8e45f9b9290c6438ccd48deee74e4b52c7bc122
- Certificate ID: 0x492ec3739735486f6853d5bd040a27f166386b3ac98a02f6640b39e3ec1c6a85
- Wallet Address: 0x4db49f908f2d6ee57e1d131a3a4137885addb7b3c5ab98b8b9bb39f736828c03

**Gas Cost:** 1,071,060 MIST

**Note:** Certificate was already in wallet (minted after linking), but transfer function successfully executed and verified the transfer.

---

### 10. Withdraw Funds

**Function:** `withdraw`  
**Module:** `popchain_wallet`  
**Purpose:** Withdraw funds from PopChain account to wallet

**Command:**
```bash
sui client call --package <PACKAGE_ID> --module popchain_wallet --function withdraw --args <ACCOUNT_ID> <AMOUNT> --gas-budget 100000000
```

**Parameters:**
- `account`: PopChainAccount object ID (`0xd16ebb1187f4deba6f088e885e737c6e35f64c72bf7c427801f3f3855aa57599`)
- `amount`: Amount to withdraw in MIST (`10000000` = 0.01 SUI)

**Result:**  
✅ **Success**

**Transaction Digest:** `2xAVETMd8HsJvCgomqrPhy1qUbQ2Ch5BKQ2CcW1Jrbt3`  
**SuiScan:** https://suiscan.xyz/testnet/tx/2xAVETMd8HsJvCgomqrPhy1qUbQ2Ch5BKQ2CcW1Jrbt3

**Mutated Objects:**
- Organizer Account: Balance reduced by withdrawal amount
- Coin transferred to wallet owner

**Event Emitted:** `Withdrawn`
- Owner: 0x4db49f908f2d6ee57e1d131a3a4137885addb7b3c5ab98b8b9bb39f736828c03
- Amount: 10,000,000 MIST (0.01 SUI)

---

### 11. Admin: Withdraw from Treasury

**Function:** `withdraw_to_owner`  
**Module:** `popchain_admin`  
**Purpose:** Admin function to withdraw accumulated fees from treasury to owner

**Command:**
```bash
sui client call --package <PACKAGE_ID> --module popchain_admin --function withdraw_to_owner --args <TREASURY_ID> <AMOUNT> --gas-budget 100000000
```

**Parameters:**
- `treasury`: PlatformTreasury object ID (`0x672654edf8c115fd27b5195fa1d06a8f74112b0f57792bea500247acb349e16d`)
- `amount`: Amount to withdraw in MIST (`1000` MIST)

**Note:** Only treasury owner can call this function.

**Result:**  
✅ **Success**

**Transaction Digest:** `BScVdgxKjbqnpyCQi2gg6L56iyrRi13MRWEtYVxMrm8d`  
**SuiScan:** https://suiscan.xyz/testnet/tx/BScVdgxKjbqnpyCQi2gg6L56iyrRi13MRWEtYVxMrm8d

**Mutated Objects:**
- PlatformTreasury: Balance reduced by withdrawal amount
- Coin transferred to treasury owner

**Event Emitted:** `FundsWithdrawn`
- Amount: 1000 MIST
- Remaining balance: (treasury balance after withdrawal)

---

## Created Objects Reference

**PlatformTreasury ID:**  
`0x672654edf8c115fd27b5195fa1d06a8f74112b0f57792bea500247acb349e16d`

**Organizer Account ID:**  
`0xd16ebb1187f4deba6f088e885e737c6e35f64c72bf7c427801f3f3855aa57599`

**Attendee Account ID:**  
`0xa2fa642b3e39b99866553f4bc8e45f9b9290c6438ccd48deee74e4b52c7bc122`

**Event ID:**  
`0xf6981050e7a2acd7b3922e12f9966afbd34551a72d02110bcd4bea547377d968`

**Certificate ID:**  
(To be filled after test 8)

---

## Events Emitted

All functions emit events that can be viewed on SuiScan:
- `PlatformInitialized` - Platform setup
- `CreatedAccount` - Account creation
- `WalletLinked` - Wallet linking
- `Deposited` - Fund deposit
- `EventCreated` - Event creation
- `AddedToWhitelist` - Whitelist addition
- `CertificateMinted` - Certificate minting
- `CertificateTransferredToWallet` - Certificate transfer
- `Withdrawn` - Fund withdrawal
- `FundsWithdrawn` - Treasury withdrawal

---

## Notes

- All transactions are on Sui Testnet
- View transactions on SuiScan: https://suiscan.xyz/testnet/tx/<TRANSACTION_DIGEST>
- Gas budget used: 100000000 MIST per transaction
- Test conducted manually without automation scripts

