# PopChain Smart Contract

A decentralized event management and NFT certificate platform built on Sui blockchain.

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

**Key Features:**
- Create PopChain accounts with linked wallet addresses
- Role-based permissions (organizer, attendee, or both)
- Balance management via Coin<SUI>
- Certificate tracking

### 2. popchain_wallet.move

Handles all fund and payment operations.

**Key Functions:**
- `deposit()` - Add funds to account
- `withdraw()` - Withdraw funds from account
- `charge_platform_fee()` - Deduct fees for platform operations

### 3. popchain_event.move

Event creation and whitelist management.

**Key Features:**
- Create events with tiered certificate structures
- Add/remove attendees from whitelist
- Track event status (active/closed)
- Mint certificates to whitelisted attendees

### 4. popchain_certificate.move

NFT certificate creation with 4 default tiers.

**Default Tiers:**
1. **PopPass** - Proof of attendance
2. **PopBadge** - Activity/Side quest completion
3. **PopMedal** - Recognition/Distinction
4. **PopTrophy** - VIP/Sponsor honor

### 5. popchain_admin.move

Platform treasury and fee management.

**Key Features:**
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
init_platform(admin, base_fee, event_creation_fee, mint_fee, ctx)
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

### 5. Add to Whitelist
```move
add_to_whitelist(event, email_hash, ctx)
```

### 6. Mint Certificate
```move
mint_certificate_for_attendee(
    event,
    organizer_account,
    attendee_email_hash,
    tier_index,
    treasury,
    ctx
)
```

## Error Codes

- `ENotOrganizer` (1) - User is not an organizer
- `ENotAttendee` (2) - User is not an attendee
- `ENotWhitelisted` (3) - Email not on whitelist
- `EInsufficientFunds` (4) - Insufficient balance
- `EEventClosed` (5) - Event is closed
- `EAlreadyClaimed` (6) - Certificate already claimed
- `EUnauthorized` (7) - Unauthorized action
- `EInvalidRole` (8) - Invalid user role
- `EInvalidTier` (9) - Invalid tier index
- `ENoTiers` (10) - No tiers defined
- `EEventNotFound` (11) - Event not found
- `EAccountNotFound` (12) - Account not found
- `ETreasuryNotFound` (13) - Treasury not found

## Fee Structure

The platform charges:
- **Event Creation Fee** - Paid by organizer when creating an event
- **Certificate Minting Fee** - Paid by organizer per certificate minted
- All fees are accumulated in the PlatformTreasury

## Development

To build and test the smart contract:

```bash
cd popchain
sui move build
sui move test
```

## License

MIT

