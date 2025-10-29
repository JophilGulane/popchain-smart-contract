module popchain::popchain_certificate;

use sui::object::{Self, ID, UID};
use sui::url::{Self, Url, new_unsafe_from_bytes};
use sui::event;
use std::string;
use sui::transfer;
use std::vector;
use sui::tx_context::{TxContext, Self};

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
        url: new_unsafe_from_bytes(b"https://www.shutterstock.com/shutterstock/photos/2247393295/display_1500/stock-vector--d-cinema-movie-ticket-with-minimal-film-theater-play-icon-ready-for-watch-movie-in-theatre-media-2247393295.jpg")
    });
    
    vector::push_back(&mut tiers, Tier {
        name: string::utf8(b"PopBadge"),
        description: string::utf8(b"Achievement or side quest badge"),
        url: new_unsafe_from_bytes(b"https://www.shutterstock.com/shutterstock/photos/2458615663/display_1500/stock-vector-american-shield-icon-silhouette-illustration-united-states-vector-graphic-pictogram-symbol-clip-2458615663.jpg"),
    });
    
    vector::push_back(&mut tiers, Tier {
        name: string::utf8(b"PopMedal"),
        description: string::utf8(b"Recognition or distinction award"),
        url: new_unsafe_from_bytes(b"https://www.shutterstock.com/shutterstock/photos/2370504913/display_1500/stock-vector-gold-medals-awards-medal-champions-medal-champion-winner-award-medal-gold-trophy-2370504913.jpg"),
    });
    
    vector::push_back(&mut tiers, Tier {
        name: string::utf8(b"PopTrophy"),
        description: string::utf8(b"VIP or sponsor honor NFT"),
        url: new_unsafe_from_bytes(b"https://www.shutterstock.com/shutterstock/photos/2328657241/display_1500/stock-vector-champion-holds-a-trophy-cup-in-his-hand-prize-winner-victory-celebration-concept-vector-2328657241.jpg"),
    });
    
    tiers
}

// ============ Certificate Minting ============

/// Mint a certificate NFT for an attendee
public fun mint_certificate(
    event_id: ID,
    url: Url,
    tier: Tier,
    attendee: address,
    ctx: &mut TxContext
): ID {
    let now = sui::tx_context::epoch_timestamp_ms(ctx);
    
    let cert = CertificateNFT {
        id: object::new(ctx),
        event_id,
        tier_name: tier.name,
        url: url,
        tier_url: tier.url,
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

// ============ Events ============

public struct CertificateMinted has copy, drop {
    certificate_id: ID,
    event_id: ID,
    tier_name: string::String,
    issued_to: address,
    issued_at: u64,
}

