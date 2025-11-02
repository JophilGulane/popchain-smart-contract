module popchain::popchain_errors;

/// Error codes for PopChain operations

const ENotOrganizer: u64 = 1;
const ENotAttendee: u64 = 2;
const ENotWhitelisted: u64 = 3;
const EInsufficientFunds: u64 = 4;
const EEventClosed: u64 = 5;
const EAlreadyClaimed: u64 = 6;
const EUnauthorized: u64 = 7;
const EInvalidRole: u64 = 8;
const EInvalidTier: u64 = 9;
const ENoTiers: u64 = 10;
const EEventNotFound: u64 = 11;
const EAccountNotFound: u64 = 12;
const ETreasuryNotFound: u64 = 13;
const EInvalidAddress: u64 = 14;

// ============ Public Getters ============

public fun e_not_organizer(): u64 { ENotOrganizer }
public fun e_not_attendee(): u64 { ENotAttendee }
public fun e_not_whitelisted(): u64 { ENotWhitelisted }
public fun e_insufficient_funds(): u64 { EInsufficientFunds }
public fun e_event_closed(): u64 { EEventClosed }
public fun e_already_claimed(): u64 { EAlreadyClaimed }
public fun e_unauthorized(): u64 { EUnauthorized }
public fun e_invalid_role(): u64 { EInvalidRole }
public fun e_invalid_tier(): u64 { EInvalidTier }
public fun e_no_tiers(): u64 { ENoTiers }
public fun e_event_not_found(): u64 { EEventNotFound }
public fun e_account_not_found(): u64 { EAccountNotFound }
public fun e_treasury_not_found(): u64 { ETreasuryNotFound }
public fun e_invalid_address(): u64 { EInvalidAddress }

