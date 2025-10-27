module popchain::popchain_user;

use sui::coin::{Self, Coin};
use sui::sui::SUI;
use sui::event;
use sui::transfer;
use sui::tx_context::{TxContext, Self};
use std::string;
use std::vector;
use sui::object::{Self, ID, UID};
use popchain::popchain_errors;

/// User role enum
public enum UserRole has copy, drop, store {
    Attendee,
    Organizer,
    Both,
}

/// PopChain account for all users
public struct PopChainAccount has key {
    id: UID,
    email_hash: vector<u8>,
    role: UserRole,
    owner_address: address,
    balance: Coin<SUI>,
    certificates: vector<ID>,
}

// ============ Struct Creation ============

/// Create a new PopChain account
/// - email_hash: hashed email address
/// - user_type: 0 = Attendee, 1 = Organizer, 2 = Both
/// - owner_address: linked wallet address
public entry fun create_account(
    email_hash: vector<u8>,
    user_type: u8,
    owner_address: address,
    ctx: &mut TxContext
) {
    let role = get_role_from_u8(user_type);
    let sender = tx_context::sender(ctx);
    
    let account = PopChainAccount {
        id: object::new(ctx),
        email_hash,
        role,
        owner_address,
        balance: coin::zero<SUI>(ctx),
        certificates: vector::empty<ID>(),
    };
    
    transfer::share_object(account);
    
    event::emit(CreatedAccount {
        owner: sender,
        owner_address,
        role: user_type,
    });
}

/// Helper to convert u8 to UserRole
fun get_role_from_u8(user_type: u8): UserRole {
    if (user_type == 0) {
        UserRole::Attendee
    } else if (user_type == 1) {
        UserRole::Organizer
    } else if (user_type == 2) {
        UserRole::Both
    } else {
        abort(popchain_errors::e_invalid_role())
    }
}

// ============ Role Checks ============

/// Check if account is an organizer
public fun is_organizer(account: &PopChainAccount): bool {
    matches_role(account.role, true)
}

/// Check if account is an attendee
public fun is_attendee(account: &PopChainAccount): bool {
    matches_role(account.role, false)
}

fun matches_role(role: UserRole, check_organizer: bool): bool {
    if (role == UserRole::Attendee) {
        !check_organizer
    } else if (role == UserRole::Organizer) {
        check_organizer
    } else {
        true
    }
}

// ============ Getters ============

/// Get account balance
public fun get_balance(account: &PopChainAccount): u64 {
    coin::value(&account.balance)
}

/// Get account owner address
public fun get_owner(account: &PopChainAccount): address {
    account.owner_address
}

/// Get account role as u8
public fun get_role(account: &PopChainAccount): u8 {
    if (account.role == UserRole::Attendee) {
        0
    } else if (account.role == UserRole::Organizer) {
        1
    } else {
        2
    }
}

/// Get email hash
public fun get_email_hash(account: &PopChainAccount): vector<u8> {
    account.email_hash
}

// ============ Certificate Management ============

/// Add a certificate to the account
public fun add_certificate(account: &mut PopChainAccount, cert_id: ID) {
    vector::push_back(&mut account.certificates, cert_id);
}

/// Get all certificate IDs
public fun get_certificates(account: &PopChainAccount): vector<ID> {
    account.certificates
}

// ============ Balance Management ============

/// Join a coin with the account balance
public fun join_balance(account: &mut PopChainAccount, payment: Coin<SUI>) {
    coin::join(&mut account.balance, payment);
}

/// Split a coin from the account balance
public fun split_balance(account: &mut PopChainAccount, amount: u64, ctx: &mut TxContext): Coin<SUI> {
    coin::split(&mut account.balance, amount, ctx)
}

// ============ Events ============

/// Event emitted when an account is created
public struct CreatedAccount has copy, drop {
    owner: address,
    owner_address: address,
    role: u8,
}

