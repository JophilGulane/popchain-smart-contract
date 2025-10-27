module popchain::popchain_utils;

use std::hash;
use std::string;
use std::vector;

/// Hash an email using Keccak256
public fun hash_email(email: string::String): vector<u8> {
    let bytes = string::bytes(&email);
    hash::sha3_256(*bytes)
}

/// Get current timestamp (Unix seconds)
public fun now(ctx: &sui::tx_context::TxContext): u64 {
    sui::tx_context::epoch_timestamp_ms(ctx)
}

/// Simple boolean require with error code
public fun require(condition: bool, code: u64) {
    assert!(condition, code);
}

