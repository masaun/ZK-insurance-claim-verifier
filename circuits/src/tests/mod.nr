mod test_inputs; // test_inputs.nr

mod tests {
    use crate::main;                   // src/main.nr
    use crate::data_types::{ IPNftData, RevealedData };  // src/data_types.nr
    use crate::converters;             // src/converters.nr -> converters/convert_cid_to_poseidon_hash.nr -> convert_nft_metadata_cid_to_poseidon_hash()
    use std::hash::poseidon2;

    #[test]
    fn test_insurance_claim_proof_verifier() {
        let root: Field = 0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629;   // @dev - Merkle Root
        let hash_path: [Field; 2] = [0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8, 0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77];
        let index: Field = 0;
        let secret: Field = 1;

        let ip_nft_data: IPNftData = IPNftData {
            nft_owner: 0xC6093Fd9cc143F9f058938868b2df2daF9A91d28,
            nft_token_id: 1,
            nft_metadata_cid: "QmYwAPJzv5CZsnAzt8auVZRn5W4mBkpLsD4HaBFN6r5y6F"
        };

        //let expected_nullifier: Field = 0x168758332d5b3e2d13be8048c8011b454590e06c44bce7f702f09103eef5a373;          // @dev - Successful (NOTE: This is equal to Field(10190015755989328289879378487807721086446093622177241109507523918927702106995) in Noir)
        //let expected_nullifier: Field = 10190015755989328289879378487807721086446093622177241109507523918927702106995; // @dev - Same with the "hash" in the output.json
        let expected_nullifier = poseidon2::Poseidon2::hash([root, secret, ip_nft_data.nft_owner, ip_nft_data.nft_token_id, expected_nft_metadata_cid_hash], 5);
        println(expected_nullifier); // [Log]: 0x168758332d5b3e2d13be8048c8011b454590e06c44bce7f702f09103eef5a373

        // @dev - The insurance claim related input data
        let hospital_bill_hash_bytes: [u8; 32] = [
            3,  57, 199, 96, 145,  58, 183, 241,
            206, 140,  36, 34, 165, 163,  17, 210,
            97, 254, 154, 79,  91, 223, 149,  18,
            3, 210, 111, 56, 246, 219,  19, 104
        ];
        //let hospital_bill_hash: Field = 0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8; // @dev - The hash of the hospital bill
        let hospital_bill_amount: Field = 1000; // @dev - The insurance claim related input parameters
        let pubkey_of_hospital_bytes: [u8; 64] = [
            131,  24,  83,  91,  84,  16, 93,  74, 122, 174,  96,
            192, 143, 196,  95, 150, 135, 24,  27,  79, 223, 198,
            37, 189,  26, 117,  63, 167, 57, 127, 237, 117,  53,
            71, 241,  28, 168, 105, 102, 70, 242, 243, 172, 176,
            142,  49,   1, 106, 250, 194, 62,  99,  12,  93,  17,
            245, 159,  97, 254, 245, 123, 13,  42, 165
        ];
        //let pub_key_x = [131, 24, 83, 91, 84, 16, 93, 74, 122, 174, 96, 192, 143, 196, 95, 150, 135, 24, 27, 79, 223, 198, 37, 189, 26, 117, 63, 167, 57, 127, 237, 117];
        //let pub_key_y = [53, 71, 241, 28, 168, 105, 102, 70, 242, 243, 172, 176, 142, 49, 1, 106, 250, 194, 62, 99, 12, 93, 17, 245, 159, 97, 254, 245, 123, 13, 42, 165];
        let signature_from_hospital_bytes: [u8; 64] = [
            1,  83,  82, 167, 184,  77, 226, 104,   5,  27, 151,
            91, 202, 127,  17, 183,  75,  31, 190, 253, 159, 116,
            155,  13,  24, 178,  40, 165, 129,  90, 103, 204,  42,
            164, 230,  62,  73, 181, 169,  61, 251, 221, 128, 221,
            14,  19, 179,  25, 107, 132,  10, 188, 149,   0, 197,
            52, 151, 239, 244, 103, 215, 224,  56, 242
        ];
        //let signature_from_hospital: Field = 0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77; // @dev - The signature from the hospital
        let hospital_bill_hash_bytes: [u8; 32] = [
            3,  57, 199, 96, 145,  58, 183, 241,
            206, 140,  36, 34, 165, 163,  17, 210,
            97, 254, 154, 79,  91, 223, 149,  18,
            3, 210, 111, 56, 246, 219,  19, 104
        ];
        let authorized_healthcare_provider_pubkey: Field = 0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77; // @dev - This public key should be validated on-chain with a on-chain registry.
        let expected_authorized_healthcare_provider_pubkey_hash: Field = poseidon2::Poseidon2::hash([authorized_healthcare_provider_pubkey], 1); // @dev - Hashed pubKey

        //let nullifier = main(
        let revealed_data: RevealedData = main(
            root,
            hash_path,
            index,
            secret,
            expected_nullifier,
            ip_nft_data,
            hospital_bill_hash_bytes, // @dev - The hash of the hospital bill
            //hospital_bill_hash,
            hospital_bill_amount,
            pubkey_of_hospital_bytes,
            //pubkey_of_hospital,
            //pubkey_of_hospital_x,
            //pubkey_of_hospital_y,
            signature_from_hospital_bytes,
            //signature_from_hospital,
            authorized_healthcare_provider_pubkey,
            expected_authorized_healthcare_provider_pubkey_hash
        );
        println(revealed_data.nullifier); // [Log]: 
        println(revealed_data.nft_metadata_cid_hash); // [Log]: 
        println(revealed_data.authorized_healthcare_provider_pubkey_hash); // [Log]: 0x25a0ce4b4bb3a7b532fec02d9d03f324a8084e34e481c4520577e3db5ad30fc5

        let inputs_for_note_commitment: [Field; 1] = [secret];
        let note_commitment = poseidon2::Poseidon2::hash(inputs_for_note_commitment, inputs_for_note_commitment.len());

        //let inputs_for_nullifier: [Field; 1] = [ip_nft_data.nft_token_id];
        let inputs_for_nullifier: [Field; 5] = [root, secret, ip_nft_data.nft_owner, ip_nft_data.nft_token_id, revealed_data.nft_metadata_cid_hash];
        let _nullifier = poseidon2::Poseidon2::hash(inputs_for_nullifier, inputs_for_nullifier.len());
        println(_nullifier); // [Log]: 0x168758332d5b3e2d13be8048c8011b454590e06c44bce7f702f09103eef5a373

        // Constraint check
        assert(revealed_data.nullifier == _nullifier, "Invalid nullifier");

        println("The test of the test_nft_metadata_verifier()) has been successful");

        // Test - Convert IPFS CID (sha256) -> bytes -> Field -> Poseidon2 Hash
        test_convert_nft_metadata_cid_to_poseidon_hash();
    }

    /** 
     * @notice - Test: Convert IPFS CID (sha256) -> bytes -> Field -> Poseidon2 Hash
     */
    fn test_convert_nft_metadata_cid_to_poseidon_hash() {
        let metadata_cid_1: str<46> = "QmYwAPJzv5CZsnAzt8auVZRn5W4mBkpLsD4HaBFN6r5y6F";
        let metadata_cid_2: str<46> = "QmT78zSuBmuS4z925W1XycoGEErPzHcYjzvAQLCNs5fLhn";
        let metadata_cid_1_bytes: [u8; 46] = metadata_cid_1.as_bytes();
        let metadata_cid_2_bytes: [u8; 46] = metadata_cid_2.as_bytes();
        println(metadata_cid_1); // [Log]: QmYwAPJzv5CZsnAzt8auVZRn5W4mBkpLsD4HaBFN6r5y6F
        println(metadata_cid_2); // [Log]: QmT78zSuBmuS4z925W1XycoGEErPzHcYjzvAQLCNs5fLhn

        let metadata_cid_1_field = Field::from_be_bytes::<46>(metadata_cid_1_bytes);
        let metadata_cid_2_field = Field::from_be_bytes::<46>(metadata_cid_2_bytes);
        println(metadata_cid_1_field); // [Log]: 0x2182f80240dbbfd8b3316c247d0ea667122dfc185af9cf934aeb9ec6dc2e9b28
        println(metadata_cid_2_field); // [Log]: 0x2cdf90be3235c6bf5def83da7f43b6ff87c0921a030d25bdba939747953d2978

        let inputs_for_metadata_cid_field_1: [Field; 1] = [metadata_cid_1_field];
        let inputs_for_metadata_cid_field_2: [Field; 1] = [metadata_cid_2_field];
        let metadata_cid_hash_1 = poseidon2::Poseidon2::hash(inputs_for_metadata_cid_field_1, inputs_for_metadata_cid_field_1.len());
        let metadata_cid_hash_2 = poseidon2::Poseidon2::hash(inputs_for_metadata_cid_field_2, inputs_for_metadata_cid_field_2.len());
        println(metadata_cid_hash_1); // [Log]: 0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0
        println(metadata_cid_hash_2); // [Log]: 0x214d21e2af69ee717d49475734429bce912b83c4da4d0e4e2f3dc0b044e2906b
    }
}
