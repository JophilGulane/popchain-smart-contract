module popchain::popchain_certificate;

use sui::object::{Self, ID, UID};
use sui::url::{Self, Url, new_unsafe_from_bytes};
use sui::event;
use std::string;
use sui::transfer;
use std::vector;
use sui::tx_context::{TxContext, Self};
use popchain::popchain_user::{Self, PopChainAccount};

/// Certificate tier structure
public struct Tier has copy, drop, store {
    name: string::String,
    description: string::String,
    url: Url
}

/// NFT Certificate
public struct CertificateNFT has key, store {
    id: UID,
    event_id: ID,
    tier_name: string::String,
    url: Url,
    tier_url: Url,
    issued_to: address,
    issued_at: u64,
}

// ============ Default Tiers ============

/// Generate default PopChain tiers
public fun default_popchain_tiers(ctx: &mut TxContext): vector<Tier> {
    let mut tiers = vector::empty<Tier>();
    
    vector::push_back(&mut tiers, Tier {
        name: string::utf8(b"PopPass"),
        description: string::utf8(b"Proof of attendance certificate"),
        url: new_unsafe_from_bytes(b"https://ktummovckegufdsuiikr.supabase.co/storage/v1/object/public/tiers/pop_pass.png")
    });
    
    vector::push_back(&mut tiers, Tier {
        name: string::utf8(b"PopBadge"),
        description: string::utf8(b"Achievement or side quest badge"),
        url: new_unsafe_from_bytes(b"https://ktummovckegufdsuiikr.supabase.co/storage/v1/object/public/tiers/pop_badge.png"),
    });
    
    vector::push_back(&mut tiers, Tier {
        name: string::utf8(b"PopMedal"),
        description: string::utf8(b"Recognition or distinction award"),
        url: new_unsafe_from_bytes(b"https://ktummovckegufdsuiikr.supabase.co/storage/v1/object/public/tiers/pop_medal.png"),
    });
    
    vector::push_back(&mut tiers, Tier {
        name: string::utf8(b"PopTrophy"),
        description: string::utf8(b"VIP or sponsor honor NFT"),
        url: new_unsafe_from_bytes(b"https://ktummovckegufdsuiikr.supabase.co/storage/v1/object/public/tiers/pop_trophy.png"),
    });
    
    tiers
}

// ============ Certificate Minting ============

/// Mint a certificate NFT to an attendee's account
/// If the attendee has no wallet (owner_address = 0x0), the NFT is transferred to the account object.
/// Otherwise, it's transferred to the attendee's wallet address.
public fun mint_certificate(
    event_id: ID,
    url: Url,
    tier: Tier,
    attendee_account: &mut PopChainAccount,
    ctx: &mut TxContext
): ID {
    let now = sui::tx_context::epoch_timestamp_ms(ctx);
    
    // Get the attendee's owner address (may be @0x0 if they don't have a wallet yet)
    let owner_address = popchain_user::get_owner(attendee_account);
    
    let cert = CertificateNFT {
        id: object::new(ctx),
        event_id,
        tier_name: tier.name,
        url: url,
        tier_url: tier.url,
        issued_to: owner_address, // Record the owner_address (even if @0x0)
        issued_at: now,
    };
    
    let cert_id = object::id(&cert);
    
    // Transfer NFT: if owner_address is @0x0 (no wallet), transfer to @0x0 (null address)
    // Otherwise, transfer to the attendee's wallet address
    // The certificate ID is always added to the account's certificates vector
    if (owner_address == @0x0) {
        // If no wallet, transfer to null address (NFT exists but not in a wallet)
        // The certificate is still tracked in the attendee's account
        transfer::public_transfer(cert, @0x0);
    } else {
        // If wallet exists, transfer to owner's address
        transfer::public_transfer(cert, owner_address);
    };
    
    // Always add certificate ID to the attendee's account (regardless of wallet status)
    popchain_user::add_certificate(attendee_account, cert_id);
    
    event::emit(CertificateMinted {
        certificate_id: cert_id,
        event_id,
        tier_name: tier.name,
        issued_to: owner_address,
        issued_at: now,
    });
    
    cert_id
}

// ============ Getters ============

/// Get certificate event ID
public fun get_event_id(cert: &CertificateNFT): ID {
    cert.event_id
}

/// Get certificate tier name
public fun get_tier_name(cert: &CertificateNFT): string::String {
    cert.tier_name
}

/// Get certificate metadata URL
public fun get_metadata_url(cert: &CertificateNFT): Url {
    cert.url
}

/// Get certificate recipient
public fun get_issued_to(cert: &CertificateNFT): address {
    cert.issued_to
}

/// Get certificate issue timestamp
public fun get_issued_at(cert: &CertificateNFT): u64 {
    cert.issued_at
}

// ============ Certificate Transfer ============

/// Transfer a certificate NFT to the attendee's linked wallet
/// Requires that the attendee has already linked a wallet (owner_address != @0x0)
/// 
/// Note: This function requires the certificate object to be passed by the caller.
/// The certificate must be currently owned by the caller (their wallet address).
/// 
/// If a certificate was minted when owner_address was @0x0 and transferred to @0x0,
/// it cannot be retrieved and cannot be transferred (it's permanently lost).
/// 
/// This function will:
/// - Verify the certificate is associated with the account
/// - Transfer it to the wallet address (if not already there)
/// - Emit a transfer event
public entry fun transfer_certificate_to_wallet(
    account: &mut PopChainAccount,
    certificate: CertificateNFT,
    _ctx: &mut TxContext
) {
    use popchain::popchain_errors;
    
    // Verify that a wallet is linked
    let owner_address = popchain_user::get_owner(account);
    assert!(owner_address != @0x0, popchain_errors::e_invalid_address());
    
    // Verify the certificate was issued to this account (or was at @0x0)
    let cert_issued_to = certificate.issued_to;
    assert!(
        cert_issued_to == @0x0 || cert_issued_to == owner_address,
        popchain_errors::e_unauthorized()
    );
    
    let cert_id = object::id(&certificate);
    
    // Verify the certificate is in the account's certificate list
    let certificates = popchain_user::get_certificates(account);
    let mut found = false;
    let mut i = 0;
    let len = vector::length(&certificates);
    while (i < len) {
        if (*vector::borrow(&certificates, i) == cert_id) {
            found = true;
            break
        };
        i = i + 1;
    };
    assert!(found, popchain_errors::e_unauthorized());
    
    // Transfer the certificate to the wallet address
    // Note: In Sui, if the certificate is already owned by owner_address, 
    // transferring to the same address is a no-op but still valid
    transfer::public_transfer(certificate, owner_address);
    
    // Emit event for the transfer
    event::emit(CertificateTransferredToWallet {
        certificate_id: cert_id,
        account_id: object::id(account),
        wallet_address: owner_address,
    });
}

// ============ Events ============

public struct CertificateMinted has copy, drop {
    certificate_id: ID,
    event_id: ID,
    tier_name: string::String,
    issued_to: address,
    issued_at: u64,
}

/// Event emitted when a certificate is transferred to a wallet
public struct CertificateTransferredToWallet has copy, drop {
    certificate_id: ID,
    account_id: ID,
    wallet_address: address,
}

