module popchain::popchain_admin;

use sui::coin::{Coin, Self};
use sui::sui::SUI;
use sui::event;
use sui::transfer;
use sui::tx_context::{TxContext, Self};
use sui::object::{Self, UID};
use popchain::popchain_errors;

/// Platform treasury - NO tier fees here, just platform fees
public struct PlatformTreasury has key {
    id: UID,
    balance: Coin<SUI>,
    owner: address,
    base_fee: u64,
    event_creation_fee: u64,
    // Platform takes a percentage of each mint (optional)
    platform_mint_fee_percentage: u64, // e.g., 10 = 10% of mint price
}

// ============ Initialization ============

public entry fun init_platform(
    base_fee: u64,
    event_creation_fee: u64,
    platform_mint_fee_percentage: u64,
    ctx: &mut TxContext
) {
    let treasury = PlatformTreasury {
        id: object::new(ctx),
        balance: coin::zero<SUI>(ctx),
        owner: tx_context::sender(ctx),
        base_fee,
        event_creation_fee,
        platform_mint_fee_percentage,
    };
    
    transfer::share_object(treasury);
    
    event::emit(PlatformInitialized {
        owner: tx_context::sender(ctx),
        base_fee,
        event_creation_fee,
        platform_mint_fee_percentage,
    });
}

// ============ Fee Management ============

public fun get_base_fee(treasury: &PlatformTreasury): u64 {
    treasury.base_fee
}

public fun get_event_creation_fee(treasury: &PlatformTreasury): u64 {
    treasury.event_creation_fee
}

public fun get_platform_mint_fee_percentage(treasury: &PlatformTreasury): u64 {
    treasury.platform_mint_fee_percentage
}

/// Calculate platform fee from mint price
public fun calculate_platform_fee(treasury: &PlatformTreasury, mint_price: u64): u64 {
    (mint_price * treasury.platform_mint_fee_percentage) / 100
}

public fun deposit_fees(
    treasury: &mut PlatformTreasury,
    payment: Coin<SUI>,
    ctx: &mut TxContext
) {
    let amount = coin::value(&payment);
    coin::join(&mut treasury.balance, payment);
    
    event::emit(FeesDeposited {
        amount,
        new_balance: coin::value(&treasury.balance),
    });
}

public entry fun withdraw_to_owner(
    treasury: &mut PlatformTreasury,
    amount: u64,
    ctx: &mut TxContext
) {
    let sender = tx_context::sender(ctx);
    assert!(sender == treasury.owner, popchain_errors::e_unauthorized());
    
    let coin_balance = coin::value(&treasury.balance);
    assert!(coin_balance >= amount, popchain_errors::e_insufficient_funds());
    
    let payment = coin::split(&mut treasury.balance, amount, ctx);
    transfer::public_transfer(payment, treasury.owner);
    
    event::emit(FundsWithdrawn {
        amount,
        remaining_balance: coin::value(&treasury.balance),
    });
}

public fun get_treasury_balance(treasury: &PlatformTreasury): u64 {
    coin::value(&treasury.balance)
}

public fun get_treasury_owner(treasury: &PlatformTreasury): address {
    treasury.owner
}

// ============ Events ============

public struct PlatformInitialized has copy, drop {
    owner: address,
    base_fee: u64,
    event_creation_fee: u64,
    platform_mint_fee_percentage: u64,
}

public struct FeesDeposited has copy, drop {
    amount: u64,
    new_balance: u64,
}

public struct FundsWithdrawn has copy, drop {
    amount: u64,
    remaining_balance: u64,
}