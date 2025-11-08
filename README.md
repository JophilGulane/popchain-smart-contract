# PopChain Smart Contract

A decentralized event management and NFT certificate platform built on Sui blockchain.

## Package Information

- **Package ID**: `0x7adb3bcd45725d722f4c621b752538758f148955b944d3011a55b42c17e7b316`
- **Network**: Sui Testnet
- **Published**: Transaction `Du1oXXxef5gR7iNGkuaex2pFU8TKSoiQRgaE8uhGGYAE`
- **SuiScan**: [View on SuiScan](https://suiscan.xyz/testnet/tx/0x7adb3bcd45725d722f4c621b752538758f148955b944d3011a55b42c17e7b316)

## Overview

PopChain enables organizers to create events, manage whitelists, and issue tiered NFT certificates to attendees. Each participant (organizer or attendee) has a PopChain account with wallet integration for payments, fees, and gas management.

## Module Architecture

```
popchain/
├── sources/
│   ├── popchain_user.move          # User accounts + roles
│   ├── popchain_event.move          # Event + whitelist management
│   ├── popchain_certificate.move    # NFT certificate logic
│   ├── popchain_wallet.move         # Fund management
│   ├── popchain_admin.move          # Platform roles & config
│   ├── popchain_utils.move          # Helper functions
│   └── popchain_errors.move         # Error codes
└── Move.toml
```

## Core Modules

### 1. popchain_user.move

Manages user accounts with role-based access (Attendee, Organizer, or Both).

Key Features:
- Create PopChain accounts with linked wallet addresses
- Role-based permissions (organizer, attendee, or both)
- Balance management via Coin<SUI>
- Certificate tracking

### 2. popchain_wallet.move

Handles all fund and payment operations.

Key Functions:
- deposit() - Add funds to account
- withdraw() - Withdraw funds from account
- charge_platform_fee() - Deduct fees for platform operations

### 3. popchain_event.move

Event creation and whitelist management.

Key Features:
- Create events with tiered certificate structures
- Add/remove attendees from whitelist
- Track event status (active/closed)
- Mint certificates to whitelisted attendees

### 4. popchain_certificate.move

NFT certificate creation with 4 default tiers.

Default Tiers:
1. PopPass - Proof of attendance
2. PopBadge - Activity/Side quest completion
3. PopMedal - Recognition/Distinction
4. PopTrophy - VIP/Sponsor honor

### 5. popchain_admin.move

Platform treasury and fee management.

Key Features:
- Initialize platform with configurable fees
- Deposit accumulated fees
- Withdraw funds to platform owner
- Manage event creation and minting fees

### 6. popchain_utils.move

Shared helper functions for hashing and validation.

### 7. popchain_errors.move

Standardized error codes for all operations.

## Usage Workflow

### 1. Initialize Platform
```move
init_platform(base_fee, event_creation_fee, mint_fee, ctx)
```

### 2. Create User Account
```move
create_account(email_hash, user_type, owner_address, ctx)
```

### 3. Deposit Funds
```move
deposit(account, payment, ctx)
```

### 4. Create Event
```move
create_event_with_default_tiers(account, name, description, treasury, ctx)
// OR
create_event(account, name, description, custom_tiers, treasury, ctx)
```

### 5. Link Wallet
```move
link_wallet(account, wallet_address, ctx)
```

### 6. Add to Whitelist
```move
add_to_whitelist(event, email_hash, ctx)
```

### 7. Mint Certificate
```move
mint_certificate_for_attendee(
    event,
    organizer_account,
    attendee_account,
    certificate_url_hash,
    tier_index,
    treasury,
    ctx
)
```

### 8. Transfer Certificate to Wallet
```move
transfer_certificate_to_wallet(account, certificate, ctx)
```

### 9. Withdraw Funds
```move
withdraw(account, amount, ctx)
```

### 10. Admin: Withdraw from Treasury
```move
withdraw_to_owner(treasury, amount, ctx)
```

## Error Codes

- ENotOrganizer (1) - User is not an organizer
- ENotAttendee (2) - User is not an attendee
- ENotWhitelisted (3) - Email not on whitelist
- EInsufficientFunds (4) - Insufficient balance
- EEventClosed (5) - Event is closed
- EAlreadyClaimed (6) - Certificate already claimed
- EUnauthorized (7) - Unauthorized action
- EInvalidRole (8) - Invalid user role
- EInvalidTier (9) - Invalid tier index
- ENoTiers (10) - No tiers defined
- EEventNotFound (11) - Event not found
- EAccountNotFound (12) - Account not found
- ETreasuryNotFound (13) - Treasury not found
- EInvalidAddress (14) - Invalid wallet address (e.g., 0x0 when not allowed)

## Fee Structure

The platform charges:
- Event Creation Fee - Paid by organizer when creating an event
- Certificate Minting Fee - Paid by organizer per certificate minted
- All fees are accumulated in the PlatformTreasury

## Development

To build the smart contract:

```bash
sui move build
```

To test the contract functions:

```bash
# See TESTING_GUIDE.md for complete testing instructions
sui client call --package 0xe465d2c1e1973e6031f40278d874572f26300ce069cecaec0d15089ec971aea6 --module <MODULE> --function <FUNCTION> --args <ARGS> --gas-budget 100000000
```

## License

MIT
