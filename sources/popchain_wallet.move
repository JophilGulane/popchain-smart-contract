module popchain::popchain_wallet;

use sui::coin::{Coin, Self};
use sui::sui::SUI;
use sui::event;
use sui::transfer;
use sui::tx_context::{TxContext, Self};
use popchain::popchain_user::{Self, PopChainAccount};
use popchain::popchain_errors;

// ============ Deposit ============

/// Deposit funds into PopChain account
public entry fun deposit(
    account: &mut PopChainAccount,
    payment: Coin<SUI>,
    ctx: &mut TxContext
) {
    let amount = coin::value(&payment);
    popchain_user::join_balance(account, payment);
    
    event::emit(Deposited {
        owner: popchain_user::get_owner(account),
        amount,
        new_balance: popchain_user::get_balance(account),
    });
}

// ============ Withdraw ============

/// Withdraw funds from PopChain account
public entry fun withdraw(
    account: &mut PopChainAccount,
    amount: u64,
    ctx: &mut TxContext
) {
    let owner = popchain_user::get_owner(account);
    assert!(tx_context::sender(ctx) == owner, popchain_errors::e_unauthorized());
    
    let balance = popchain_user::get_balance(account);
    assert!(balance >= amount, popchain_errors::e_insufficient_funds());
    
    let coin = popchain_user::split_balance(account, amount, ctx);
    transfer::public_transfer(coin, owner);
    
    event::emit(Withdrawn {
        owner,
        amount,
        remaining_balance: popchain_user::get_balance(account),
    });
}

// ============ Platform Fees ============

/// Charge platform fee from account
public fun charge_platform_fee(
    account: &mut PopChainAccount,
    amount: u64,
    ctx: &mut TxContext
): Coin<SUI> {
    let balance = popchain_user::get_balance(account);
    assert!(balance >= amount, popchain_errors::e_insufficient_funds());
    
    let fee_coin = popchain_user::split_balance(account, amount, ctx);
    
    event::emit(FeeCharged {
        owner: popchain_user::get_owner(account),
        amount,
        remaining_balance: popchain_user::get_balance(account),
    });
    
    fee_coin
}

// ============ Events ============

public struct Deposited has copy, drop {
    owner: address,
    amount: u64,
    new_balance: u64,
}

public struct Withdrawn has copy, drop {
    owner: address,
    amount: u64,
    remaining_balance: u64,
}

public struct FeeCharged has copy, drop {
    owner: address,
    amount: u64,
    remaining_balance: u64,
}

