module popchain::popchain_certificate;

use sui::object::{Self, ID, UID};
use sui::event;
use std::string;
use sui::transfer;
use std::vector;
use sui::tx_context::{TxContext, Self};

/// Certificate tier structure
public struct Tier has copy, drop, store {
    name: string::String,
    description: string::String,
    metadata_url: string::String,
}

/// NFT Certificate
public struct CertificateNFT has key, store {
    id: UID,
    event_id: ID,
    tier_name: string::String,
    metadata_url: string::String,
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
        metadata_url: string::utf8(b"https://ipfs.io/ipfs/popchain/pop_pass.json"),
    });
    
    vector::push_back(&mut tiers, Tier {
        name: string::utf8(b"PopBadge"),
        description: string::utf8(b"Achievement or side quest badge"),
        metadata_url: string::utf8(b"https://ipfs.io/ipfs/popchain/pop_badge.json"),
    });
    
    vector::push_back(&mut tiers, Tier {
        name: string::utf8(b"PopMedal"),
        description: string::utf8(b"Recognition or distinction award"),
        metadata_url: string::utf8(b"https://ipfs.io/ipfs/popchain/pop_medal.json"),
    });
    
    vector::push_back(&mut tiers, Tier {
        name: string::utf8(b"PopTrophy"),
        description: string::utf8(b"VIP or sponsor honor NFT"),
        metadata_url: string::utf8(b"https://ipfs.io/ipfs/popchain/pop_trophy.json"),
    });
    
    tiers
}

// ============ Certificate Minting ============

/// Mint a certificate NFT for an attendee
public fun mint_certificate(
    event_id: ID,
    tier: Tier,
    attendee: address,
    ctx: &mut TxContext
): ID {
    let now = sui::tx_context::epoch_timestamp_ms(ctx);
    
    let cert = CertificateNFT {
        id: object::new(ctx),
        event_id,
        tier_name: tier.name,
        metadata_url: tier.metadata_url,
        issued_to: attendee,
        issued_at: now,
    };
    
    let cert_id = object::id(&cert);
    transfer::public_transfer(cert, attendee);
    
    event::emit(CertificateMinted {
        certificate_id: cert_id,
        event_id,
        tier_name: tier.name,
        issued_to: attendee,
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
public fun get_metadata_url(cert: &CertificateNFT): string::String {
    cert.metadata_url
}

/// Get certificate recipient
public fun get_issued_to(cert: &CertificateNFT): address {
    cert.issued_to
}

/// Get certificate issue timestamp
public fun get_issued_at(cert: &CertificateNFT): u64 {
    cert.issued_at
}

// ============ Events ============

public struct CertificateMinted has copy, drop {
    certificate_id: ID,
    event_id: ID,
    tier_name: string::String,
    issued_to: address,
    issued_at: u64,
}

