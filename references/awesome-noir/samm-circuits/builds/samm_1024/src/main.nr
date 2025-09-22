use dep::zkemail::{
    KEY_LIMBS_1024, dkim::RSAPubkey, Sequence
};
use dep::samm::{
    LEVELS, MAX_EMAIL_HEADER_LENGTH, MAX_EMAIL_ADDRESS_LENGTH,
    MAX_EMAIL_DOMAIN_LENGTH, MSG_HASH_LENGTH, verify_samm_logic
};


fn main(
    header: BoundedVec<u8, MAX_EMAIL_HEADER_LENGTH>,
    root: pub Field,
    path_indices: [Field; LEVELS],
    path_elements: [Field; LEVELS],
    secret: Field,
    padded_member: [u8; MAX_EMAIL_ADDRESS_LENGTH],
    domain: pub BoundedVec<u8, MAX_EMAIL_DOMAIN_LENGTH>,
    from_seq: Sequence,
    member_seq: Sequence,
    relayer: pub BoundedVec<u8, MAX_EMAIL_ADDRESS_LENGTH>,
    relayer_address: pub Field,
    to_seq: Sequence,
    relayer_seq: Sequence,
    msg_hash: pub [u8; MSG_HASH_LENGTH],
    pubkey: RSAPubkey<KEY_LIMBS_1024>,
    signature: [Field; KEY_LIMBS_1024]
) -> pub (Field, Field) {
    // check samm logic
    let commitment = verify_samm_logic(header, root, path_indices, path_elements, secret, padded_member,
        domain, from_seq, member_seq, relayer, relayer_address, to_seq, relayer_seq, msg_hash);

    // verify the dkim signature over the header
    pubkey.verify_dkim_signature(header, signature);

    // return pubkey hash
    let mut pubkey_9 = [0; 9];
    for i in 0..9 {
        pubkey_9[i] = pubkey.modulus[i];
    }
    let pubkeyHash = std::hash::poseidon::bn254::hash_9(pubkey_9);
    
    (commitment, pubkeyHash)
}

#[test]
fn test_sig_1024() {
    let header: BoundedVec<u8, MAX_EMAIL_HEADER_LENGTH> = BoundedVec {
        storage: [109, 101, 115, 115, 97, 103, 101, 45, 105, 100, 58, 60, 53, 52, 55, 57, 49, 55, 50, 57, 50, 56, 55, 55, 48, 48, 64, 109, 97, 105, 108, 46, 121, 97, 110, 100, 101, 120, 46, 114, 117, 62, 13, 10, 100, 97, 116, 101, 58, 70, 114, 105, 44, 32, 49, 56, 32, 79, 99, 116, 32, 50, 48, 50, 52, 32, 50, 51, 58, 52, 50, 58, 52, 50, 32, 43, 48, 50, 48, 48, 13, 10, 115, 117, 98, 106, 101, 99, 116, 58, 121, 120, 68, 110, 83, 110, 73, 54, 71, 84, 82, 115, 85, 50, 68, 120, 111, 108, 47, 85, 73, 101, 71, 101, 115, 84, 112, 89, 81, 81, 104, 70, 80, 121, 52, 116, 117, 88, 70, 43, 87, 54, 56, 61, 13, 10, 116, 111, 58, 34, 97, 100, 64, 111, 120, 111, 114, 46, 105, 111, 34, 32, 60, 97, 100, 64, 111, 120, 111, 114, 46, 105, 111, 62, 13, 10, 102, 114, 111, 109, 58, 68, 114, 121, 32, 57, 49, 52, 32, 60, 100, 114, 121, 45, 57, 49, 52, 64, 121, 97, 110, 100, 101, 120, 46, 99, 111, 109, 62, 13, 10, 100, 107, 105, 109, 45, 115, 105, 103, 110, 97, 116, 117, 114, 101, 58, 118, 61, 49, 59, 32, 97, 61, 114, 115, 97, 45, 115, 104, 97, 50, 53, 54, 59, 32, 99, 61, 114, 101, 108, 97, 120, 101, 100, 47, 114, 101, 108, 97, 120, 101, 100, 59, 32, 100, 61, 121, 97, 110, 100, 101, 120, 46, 99, 111, 109, 59, 32, 115, 61, 109, 97, 105, 108, 59, 32, 116, 61, 49, 55, 50, 57, 50, 56, 55, 55, 54, 50, 59, 32, 98, 104, 61, 55, 83, 56, 114, 115, 50, 50, 107, 75, 112, 109, 105, 110, 72, 82, 48, 48, 78, 77, 106, 98, 122, 79, 67, 98, 89, 53, 99, 98, 101, 79, 73, 71, 52, 81, 116, 101, 82, 72, 81, 71, 56, 103, 61, 59, 32, 104, 61, 77, 101, 115, 115, 97, 103, 101, 45, 73, 100, 58, 68, 97, 116, 101, 58, 83, 117, 98, 106, 101, 99, 116, 58, 84, 111, 58, 70, 114, 111, 109, 59, 32, 98, 61, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
        len: 376
    };

    // signature part
    let signature: [Field; 9] = [
        0x76c508d27d5c6db213ee99dbbe487c, 0xcf8a7267517141a66d19067f5ce5e3, 0x3ede5f052dc526b096a689e17a2644, 0x01fee7b13ed43cbda9749451e6d2ef, 0xf98f2d25d5718eb4fac5456e26e055, 0xbb714ca4d069ac166c74a3ce79f29c, 0x676ea4e12ddc5e9445d504f823c189, 0x6b7c7163368ec2db81f2b83a424b2a, 0x407475c3a8b7922d
    ];
    let pubkey_modulus_limbs: [Field; 9] = [
        0xe4e468d4a8aa968afb167878faf919, 0x0bbea2b2fd31d16e743acd4163e2ab, 0xdb95df2ccff3d2feb3dc38371ab5e7, 0xbc5b5d58a0649fec4cf765bc326c78, 0xffd5e9a11c12cc5bfbaf1d44908587, 0x13cb618ee314f1e928dadc546d1319, 0x96a517c4b42e3ce1139ba8a8cc05ff, 0x99898558d15fd00ac797a480819f91, 0xc9a55689988924f3
    ];
    let redc_params_limbs: [Field; 9] = [
        0xd6ddc96b326c15660fa6417b2ec470, 0x67496318ec9b005135d5a1e567cb65, 0x7856eb0e22f5d1242d784643f289d9, 0x7c5d7510c66ceedaba2ebc2e5a7214, 0xa8253b59bf60d6aae39c6fadf0d5e1, 0xb668e5277538b65054edef2f2ee11b, 0xb0fef0e6279cb9e900b5bb211ddb05, 0x64fc9654cfecbfb8fb21a7e9ad1a41, 0x01450164eb5e3eb69d
    ];
    let pubkey: RSAPubkey<KEY_LIMBS_1024> = RSAPubkey {
        modulus: pubkey_modulus_limbs,
        redc: redc_params_limbs
    };

    // check DKIM signature
    pubkey.verify_dkim_signature(header, signature);
}

