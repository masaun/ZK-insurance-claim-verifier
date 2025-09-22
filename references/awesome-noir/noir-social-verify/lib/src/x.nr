use std::hash::pedersen_hash;
use zkemail::{dkim::RSAPubkey, headers::email_address::get_email_address, KEY_LIMBS_2048, Sequence};

use crate::constants::MAX_EMAIL_HEADER_LENGTH;
use super::{constants::X_FROM_EMAIL, utils::VerifiedOutputs};

/// Verifies an X (Twitter) email by checking its DKIM signature and extracting relevant information.
///
/// This function performs several verification steps:
/// 1. Validates the email header length
/// 2. Verifies the DKIM signature using the provided public key
/// 3. Extracts and validates the 'from' address matches the expected X email
/// 4. Extracts the 'to' address
/// 5. Computes an email nullifier using the DKIM signature
///
/// # Arguments
///
/// * `header` - The email header as a bounded vector of bytes
/// * `pubkey` - The RSA public key used for DKIM signature verification
/// * `signature` - The DKIM signature to verify
/// * `from_header_sequence` - Sequence information for the 'from' header
/// * `from_address_sequence` - Sequence information for the 'from' address
/// * `to_header_sequence` - Sequence information for the 'to' header
/// * `to_address_sequence` - Sequence information for the 'to' address
///
/// # Returns
///
/// Returns a `VerifiedOutputs` struct containing:
/// * `pub_key_hash` - The hash of the public key
/// * `email_nullifier` - A unique identifier for the email
/// * `to_address` - The extracted 'to' address
///
/// # Panics
///
/// This function will panic if:
/// * The email header exceeds the maximum allowed length
/// * The DKIM signature verification fails
/// * The 'from' address does not match the expected X email address
#[export]
pub fn verify_x_email(
    header: BoundedVec<u8, MAX_EMAIL_HEADER_LENGTH>,
    pubkey: RSAPubkey<KEY_LIMBS_2048>,
    signature: [Field; KEY_LIMBS_2048],
    from_header_sequence: Sequence,
    from_address_sequence: Sequence,
    to_header_sequence: Sequence,
    to_address_sequence: Sequence,
) -> VerifiedOutputs {
    // Ensure the email header does not exceed the maximum allowed length
    assert(header.len() <= MAX_EMAIL_HEADER_LENGTH, "Email header exceeds max length");

    pubkey.verify_dkim_signature(header, signature);

    let from = comptime { "from".as_bytes() };
    let to = comptime { "to".as_bytes() };

    // Extract the 'from' address from the email header
    let from_address = get_email_address(header, from_header_sequence, from_address_sequence, from);

    // Verify that the 'from' address matches the expected Google email address
    assert(from_address.eq(BoundedVec::from(X_FROM_EMAIL)), "Invalid from address");

    // Extract the 'to' address from the email header
    let to_address = get_email_address(header, to_header_sequence, to_address_sequence, to);

    // Compute the email nullifier using the DKIM signature
    let email_nullifier = pedersen_hash(signature);

    // Return the verified outputs
    VerifiedOutputs::new(pubkey.hash(), email_nullifier, to_address)
}
