module popchain::popchain_event;

use sui::table::{Self, Table};
use sui::object::{Self, ID, UID};
use sui::url::{Self, Url, new_unsafe_from_bytes};
use sui::event;
use std::string;
use sui::transfer;
use std::vector;
use sui::tx_context::{TxContext, Self};
use popchain::popchain_user::{Self, PopChainAccount, is_organizer};
use popchain::popchain_wallet;
use popchain::popchain_certificate::{Self, Tier};
use popchain::popchain_admin::{Self, get_event_creation_fee, PlatformTreasury};
use popchain::popchain_errors;

/// Event structure
public struct Event has key {
    id: UID,
    name: string::String,
    description: string::String,
    organizer: address,
    organizer_account: ID,
    tiers: vector<Tier>,
    whitelist: Table<vector<u8>, bool>,
    active: bool,
}

// ============ Event Creation ============

/// Create a new event with default tiers
/// Only organizers can create events
public entry fun create_event_with_default_tiers(
    account: &mut PopChainAccount,
    name: string::String,
    description: string::String,
    treasury: &mut PlatformTreasury,
    ctx: &mut TxContext
) {
    let default_tiers = popchain_certificate::default_popchain_tiers(ctx);
    create_event(account, name, description, default_tiers, treasury, ctx);
}

/// Create a new event with custom tiers
public fun create_event(
    account: &mut PopChainAccount,
    name: string::String,
    description: string::String,
    tiers: vector<Tier>,
    treasury: &mut PlatformTreasury,
    ctx: &mut TxContext
) {
    // Verify user is an organizer
    assert!(is_organizer(account), popchain_errors::e_not_organizer());
    assert!(vector::length(&tiers) > 0, popchain_errors::e_no_tiers());
    
    // Charge platform fee
    let fee = get_event_creation_fee(treasury);
    let fee_coin = popchain_wallet::charge_platform_fee(account, fee, ctx);
    popchain_admin::deposit_fees(treasury, fee_coin, ctx);
    
    let organizer = popchain_user::get_owner(account);
    let event = Event {
        id: object::new(ctx),
        name,
        description,
        organizer,
        organizer_account: object::id(account),
        tiers,
        whitelist: table::new(ctx),
        active: true,
    };
    
    let event_id = object::id(&event);
    transfer::share_object(event);
    
    event::emit(EventCreated {
        event_id,
        organizer,
    });
}

/// Add email to event whitelist
public entry fun add_to_whitelist(
    event: &mut Event,
    email_hash: vector<u8>,
    ctx: &mut TxContext
) {
    let sender = tx_context::sender(ctx);
    assert!(sender == event.organizer, popchain_errors::e_unauthorized());
    
    table::add(&mut event.whitelist, email_hash, true);
    
    event::emit(AddedToWhitelist {
        event_id: object::id(event),
        email_hash,
    });
}

/// Remove email from whitelist
public entry fun remove_from_whitelist(
    event: &mut Event,
    email_hash: vector<u8>,
    ctx: &mut TxContext
) {
    let sender = tx_context::sender(ctx);
    assert!(sender == event.organizer, popchain_errors::e_unauthorized());
    
    table::remove(&mut event.whitelist, email_hash);
    
    event::emit(RemovedFromWhitelist {
        event_id: object::id(event),
        email_hash,
    });
}

/// Check if email is whitelisted
public fun is_whitelisted(event: &Event, email_hash: vector<u8>): bool {
    if (!table::contains(&event.whitelist, email_hash)) {
        return false
    };
    table::borrow(&event.whitelist, email_hash) == true
}

/// Close an event
public entry fun close_event(
    event: &mut Event,
    ctx: &mut TxContext
) {
    let sender = tx_context::sender(ctx);
    assert!(sender == event.organizer, popchain_errors::e_unauthorized());
    
    event.active = false;
    
    event::emit(EventClosed {
        event_id: object::id(event),
    });
}

/// Mint certificate for attendee
public entry fun mint_certificate_for_attendee(
    event: &mut Event,
    organizer_account: &mut PopChainAccount,
    attendee_account: &mut PopChainAccount,
    certificate_url_hash: vector<u8>,
    tier_index: u64,
    treasury: &mut PlatformTreasury,
    ctx: &mut TxContext
) {
    // Verify event is active
    assert!(event.active, popchain_errors::e_event_closed());
    
    // Verify organizer
    let sender = tx_context::sender(ctx);
    assert!(is_organizer(organizer_account), popchain_errors::e_not_organizer());
    assert!(sender == event.organizer, popchain_errors::e_unauthorized());

    // Get attendee details
    let attendee = popchain_user::get_owner(attendee_account);
    let attendee_email_hash = popchain_user::get_email_hash(attendee_account);
    
    // Verify attendee is whitelisted
    assert!(is_whitelisted(event, attendee_email_hash), popchain_errors::e_not_whitelisted());
    
    // Get tier
    let tier_count = vector::length(&event.tiers);
    assert!(tier_index < tier_count, popchain_errors::e_invalid_tier());
    let tier = *vector::borrow(&event.tiers, tier_index);
    
    // Charge minting fee to organizer
    let mint_fee = popchain_admin::get_mint_fee(treasury);
    let fee_coin = popchain_wallet::charge_platform_fee(organizer_account, mint_fee, ctx);
    popchain_admin::deposit_fees(treasury, fee_coin, ctx);
    
    // Remove from whitelist (prevent duplicate claims)
    table::remove(&mut event.whitelist, attendee_email_hash);
    
    // Mint certificate to organizer's account (they can transfer to attendee)
    let cert_id = popchain_certificate::mint_certificate(
        object::id(event),
        new_unsafe_from_bytes(certificate_url_hash),
        tier,
        attendee,
        ctx
    );
    
    // Note: In a real implementation, you'd transfer the certificate
    // to the actual attendee address, not the organizer
    
    event::emit(CertificateMintedToAttendee {
        event_id: object::id(event),
        certificate_id: cert_id,
        tier_index,
        attendee_email_hash,
    });
}

// ============ Getters ============

/// Get event organizer
public fun get_organizer(event: &Event): address {
    event.organizer
}

/// Check if event is active
public fun is_active(event: &Event): bool {
    event.active
}

/// Get event name
public fun get_name(event: &Event): string::String {
    event.name
}

/// Get number of tiers
public fun get_tier_count(event: &Event): u64 {
    vector::length(&event.tiers)
}

// ============ Events ============

public struct EventCreated has copy, drop {
    event_id: ID,
    organizer: address,
}

public struct AddedToWhitelist has copy, drop {
    event_id: ID,
    email_hash: vector<u8>,
}

public struct RemovedFromWhitelist has copy, drop {
    event_id: ID,
    email_hash: vector<u8>,
}

public struct EventClosed has copy, drop {
    event_id: ID,
}

public struct CertificateMintedToAttendee has copy, drop {
    event_id: ID,
    certificate_id: ID,
    tier_index: u64,
    attendee_email_hash: vector<u8>,
}

