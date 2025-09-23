use noir_social_verify::{
    constants::MAX_EMAIL_HEADER_LENGTH, google::verify_google_email, utils::VerifiedOutputs,
};
use zkemail::{dkim::RSAPubkey, KEY_LIMBS_2048, Sequence};

fn main(
    header: BoundedVec<u8, MAX_EMAIL_HEADER_LENGTH>,
    pubkey: RSAPubkey<KEY_LIMBS_2048>,
    signature: [Field; KEY_LIMBS_2048],
    from_header_sequence: Sequence,
    from_address_sequence: Sequence,
    to_header_sequence: Sequence,
    to_address_sequence: Sequence,
) -> pub VerifiedOutputs {
    let verified_outputs: VerifiedOutputs = verify_google_email(
        header,
        pubkey,
        signature,
        from_header_sequence,
        from_address_sequence,
        to_header_sequence,
        to_address_sequence,
    );

    verified_outputs
}
