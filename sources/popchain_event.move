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
use popchain::popchain_admin::{Self, PlatformTreasury};
use popchain::popchain_errors;

/// Event structure - Tiers stored IN the event!
public struct Event has key {
    id: UID,
    name: string::String,
    description: string::String,
    organizer: address,
    organizer_account: ID,
    tiers: vector<Tier>,  // Each tier has its own price now!
    whitelist: Table<vector<u8>, bool>,
    active: bool,
}

// ============ Event Creation ============

/// Create event with default tiers
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

/// Create event with custom tiers and prices
public entry fun create_event_with_custom_tiers(
    account: &mut PopChainAccount,
    name: string::String,
    description: string::String,
    tier_names: vector<vector<u8>>,
    tier_descriptions: vector<vector<u8>>,
    tier_urls: vector<vector<u8>>,
    tier_prices: vector<u64>,  // NEW: Custom prices per tier!
    treasury: &mut PlatformTreasury,
    ctx: &mut TxContext
) {
    let custom_tiers = popchain_certificate::create_custom_tiers(
        tier_names,
        tier_descriptions,
        tier_urls,
        tier_prices
    );
    create_event(account, name, description, custom_tiers, treasury, ctx);
}

/// Internal event creation
public fun create_event(
    account: &mut PopChainAccount,
    name: string::String,
    description: string::String,
    tiers: vector<Tier>,
    treasury: &mut PlatformTreasury,
    ctx: &mut TxContext
) {
    assert!(is_organizer(account), popchain_errors::e_not_organizer());
    assert!(vector::length(&tiers) > 0, popchain_errors::e_no_tiers());
    
    // Charge platform fee
    let fee = popchain_admin::get_event_creation_fee(treasury);
    let fee_coin = popchain_wallet::charge_platform_fee(account, fee, ctx);
    popchain_admin::deposit_fees(treasury, fee_coin, ctx);
    
    let organizer = popchain_user::get_owner(account);
    // Calculate tier_count BEFORE creating and moving event
    let tier_count = vector::length(&tiers);
    let event = Event {
        id: object::new(ctx),
        name,
        description,
        organizer,
        organizer_account: object::id(account),
        tiers,  // Tiers with prices stored in event
        whitelist: table::new(ctx),
        active: true,
    };
    
    let event_id = object::id(&event);
    transfer::share_object(event);  // event is moved here, cannot be used after this
    
    event::emit(EventCreated {
        event_id,
        organizer,
        tier_count,  // Use pre-calculated tier_count (calculated before event was moved)
    });
}

// ============ Whitelist Management ============

public entry fun add_to_whitelist(
    event: &mut Event,
    email_hash: vector<u8>,
    ctx: &mut TxContext
) {
    let sender = tx_context::sender(ctx);
    assert!(sender == event.organizer, popchain_errors::e_unauthorized());
    table::add(&mut event.whitelist, email_hash, true);
    event::emit(AddedToWhitelist { event_id: object::id(event), email_hash });
}

public entry fun remove_from_whitelist(
    event: &mut Event,
    email_hash: vector<u8>,
    ctx: &mut TxContext
) {
    let sender = tx_context::sender(ctx);
    assert!(sender == event.organizer, popchain_errors::e_unauthorized());
    table::remove(&mut event.whitelist, email_hash);
    event::emit(RemovedFromWhitelist { event_id: object::id(event), email_hash });
}

public fun is_whitelisted(event: &Event, email_hash: vector<u8>): bool {
    if (!table::contains(&event.whitelist, email_hash)) {
        return false
    };
    table::borrow(&event.whitelist, email_hash) == true
}

public entry fun close_event(event: &mut Event, ctx: &mut TxContext) {
    let sender = tx_context::sender(ctx);
    assert!(sender == event.organizer, popchain_errors::e_unauthorized());
    event.active = false;
    event::emit(EventClosed { event_id: object::id(event) });
}

// ============ Certificate Minting ============

/// Mint certificate - tier price is automatically used from the tier!
public entry fun mint_certificate_for_attendee(
    event: &mut Event,
    organizer_account: &mut PopChainAccount,
    attendee_account: &mut PopChainAccount,
    certificate_url_hash: vector<u8>,
    tier_index: u64,
    treasury: &mut PlatformTreasury,
    ctx: &mut TxContext
) {
    assert!(event.active, popchain_errors::e_event_closed());
    
    let sender = tx_context::sender(ctx);
    let treasury_owner = popchain_admin::get_treasury_owner(treasury);
    assert!(is_organizer(organizer_account), popchain_errors::e_not_organizer());
    assert!(sender == event.organizer || sender == treasury_owner, popchain_errors::e_unauthorized());

    let attendee_email_hash = popchain_user::get_email_hash(attendee_account);
    assert!(is_whitelisted(event, attendee_email_hash), popchain_errors::e_not_whitelisted());
    
    // Get tier (which contains the price!)
    let tier_count = vector::length(&event.tiers);
    assert!(tier_index < tier_count, popchain_errors::e_invalid_tier());
    let tier = *vector::borrow(&event.tiers, tier_index);
    
    // Get tier price from the tier itself!
    let tier_price = popchain_certificate::get_tier_price(&tier);
    
    // Calculate platform fee (percentage of tier price)
    let platform_fee = popchain_admin::calculate_platform_fee(treasury, tier_price);
    let total_fee = tier_price + platform_fee;
    
    // Charge organizer
    let fee_coin = popchain_wallet::charge_platform_fee(organizer_account, total_fee, ctx);
    popchain_admin::deposit_fees(treasury, fee_coin, ctx);
    
    // Remove from whitelist
    table::remove(&mut event.whitelist, attendee_email_hash);
    
    // Mint certificate
    let cert_id = popchain_certificate::mint_certificate(
        object::id(event),
        new_unsafe_from_bytes(certificate_url_hash),
        tier,
        attendee_account,
        treasury_owner,
        ctx
    );
    
    event::emit(CertificateMintedToAttendee {
        event_id: object::id(event),
        certificate_id: cert_id,
        tier_index,
        tier_price,
        platform_fee,
        attendee_email_hash,
    });
}

// ============ Getters ============

public fun get_organizer(event: &Event): address {
    event.organizer
}

public fun is_active(event: &Event): bool {
    event.active
}

public fun get_name(event: &Event): string::String {
    event.name
}

public fun get_tier_count(event: &Event): u64 {
    vector::length(&event.tiers)
}

/// Get tier price by index
public fun get_tier_price_by_index(event: &Event, tier_index: u64): u64 {
    let tier = vector::borrow(&event.tiers, tier_index);
    popchain_certificate::get_tier_price(tier)
}

/// Get all tier prices for an event
public fun get_all_tier_prices(event: &Event): vector<u64> {
    let mut prices = vector::empty<u64>();
    let mut i = 0;
    let len = vector::length(&event.tiers);
    while (i < len) {
        let tier = vector::borrow(&event.tiers, i);
        vector::push_back(&mut prices, popchain_certificate::get_tier_price(tier));
        i = i + 1;
    };
    prices
}

// ============ Events ============

public struct EventCreated has copy, drop {
    event_id: ID,
    organizer: address,
    tier_count: u64,
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
    tier_price: u64,
    platform_fee: u64,
    attendee_email_hash: vector<u8>,
}