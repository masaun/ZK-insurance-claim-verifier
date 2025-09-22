use std::hash::pedersen_hash;
use zkemail::{dkim::RSAPubkey, headers::email_address::get_email_address, KEY_LIMBS_2048, Sequence};

use crate::constants::MAX_EMAIL_HEADER_LENGTH;
use super::{constants::GOOGLE_FROM_EMAIL, utils::VerifiedOutputs};

/// Verifies a Google email by checking the DKIM signature and validating the 'from' address.
///
/// # Arguments
///
/// * `header` - A bounded vector containing the email header, which must not exceed the maximum length.
/// * `pubkey` - The RSA public key used to verify the DKIM signature.
/// * `signature` - The DKIM signature of the email, represented as an array of fields.
/// * `from_header_sequence` - The sequence used to locate the 'from' header in the email.
/// * `from_address_sequence` - The sequence used to locate the 'from' address in the email.
/// * `to_header_sequence` - The sequence used to locate the 'to' header in the email.
/// * `to_address_sequence` - The sequence used to locate the 'to' address in the email.
///
/// # Returns
///
/// * `VerifiedOutputs` - A struct containing the public key hash, email nullifier, and the 'to' address.
#[export]
pub fn verify_google_email(
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
    assert(from_address.eq(BoundedVec::from(GOOGLE_FROM_EMAIL)), "Invalid from address");

    // Extract the 'to' address from the email header
    let to_address = get_email_address(header, to_header_sequence, to_address_sequence, to);

    // Compute the email nullifier using the DKIM signature
    let email_nullifier = pedersen_hash(signature);

    // Return the verified outputs
    VerifiedOutputs::new(pubkey.hash(), email_nullifier, to_address)
}
