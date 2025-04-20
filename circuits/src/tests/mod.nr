mod test_inputs; // test_inputs.nr

mod tests {
    use crate::main;                   // src/main.nr
    use crate::data_types::{ InsurancePolicyData, HospitalBillData, RevealedData };  // src/data_types.nr
    use crate::converters;             // src/converters.nr -> converters/convert_cid_to_poseidon_hash.nr -> convert_nft_metadata_cid_to_poseidon_hash()
    use std::hash::poseidon2;

    #[test]
    fn test_hospital_bill_proof_verifier() {
        let root: Field = 0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629;   // @dev - Merkle Root
        let hash_path: [Field; 2] = [0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8, 0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77];
        let index: Field = 0;
        let secret: Field = 1;

        // @dev - The insurance policy related input data
        let _patient_name: Field = 0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8; // @dev - The patient name
        let _insurance_policy_start_date: Field = 1690982400; // @dev - The start date of the insurance policy (UNIX timestamp)
        let _insurance_policy_end_date: Field = 1690982400;   // @dev - The end date of the insurance policy (UNIX timestamp)
        let _insurance_policy_minimum_threshold_of_bill_amount: Field = 1000; // @dev - The minimum threshold for the insurance claim
        let _insurance_policy_treatment_icd_code: Field = 0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8; // @dev - The treatment details to be covered by a insurance policy (ICD code)
        let _insurance_policy_treatment_cpt_code: Field = 0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77; // @dev - The treatment details to be covered by a insurance policy (CPT code)
        let _insurance_policy_treatment_hcpcs_code: Field = 0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8; // @dev - The treatment details to be covered by a insurance policy (HCPCS code)
        let _insurance_policy_treatment_drg_code: Field = 0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77; // @dev - The treatment details to be covered by a insurance policy (DRG code)
        let insurance_policy_data: InsurancePolicyData = InsurancePolicyData {
            patient_name: _patient_name,
            start_date: _insurance_policy_start_date,
            end_date: _insurance_policy_end_date,
            minimum_threshold_of_bill_amount: _insurance_policy_minimum_threshold_of_bill_amount,
            treatment_icd_code: _insurance_policy_treatment_icd_code,
            treatment_cpt_code: _insurance_policy_treatment_cpt_code,
            treatment_hcpcs_code: _insurance_policy_treatment_hcpcs_code,
            treatment_drg_code: _insurance_policy_treatment_drg_code
        };

        // @dev - The insurance claim related input data
        let _hospital_bill_hash_bytes: [u8; 32] = [
            3,  57, 199, 96, 145,  58, 183, 241,
            206, 140,  36, 34, 165, 163,  17, 210,
            97, 254, 154, 79,  91, 223, 149,  18,
            3, 210, 111, 56, 246, 219,  19, 104
        ];
        //let hospital_bill_hash: Field = 0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8; // @dev - The hash of the hospital bill
        let _hospital_bill_amount: Field = 1000; // @dev - The insurance claim related input parameters
        let _hospital_pubkey_bytes: [u8; 64] = [
            131,  24,  83,  91,  84,  16, 93,  74, 122, 174,  96,
            192, 143, 196,  95, 150, 135, 24,  27,  79, 223, 198,
            37, 189,  26, 117,  63, 167, 57, 127, 237, 117,  53,
            71, 241,  28, 168, 105, 102, 70, 242, 243, 172, 176,
            142,  49,   1, 106, 250, 194, 62,  99,  12,  93,  17,
            245, 159,  97, 254, 245, 123, 13,  42, 165
        ];
        //let pub_key_x = [131, 24, 83, 91, 84, 16, 93, 74, 122, 174, 96, 192, 143, 196, 95, 150, 135, 24, 27, 79, 223, 198, 37, 189, 26, 117, 63, 167, 57, 127, 237, 117];
        //let pub_key_y = [53, 71, 241, 28, 168, 105, 102, 70, 242, 243, 172, 176, 142, 49, 1, 106, 250, 194, 62, 99, 12, 93, 17, 245, 159, 97, 254, 245, 123, 13, 42, 165];
        let _hospital_signature_bytes: [u8; 64] = [
            1,  83,  82, 167, 184,  77, 226, 104,   5,  27, 151,
            91, 202, 127,  17, 183,  75,  31, 190, 253, 159, 116,
            155,  13,  24, 178,  40, 165, 129,  90, 103, 204,  42,
            164, 230,  62,  73, 181, 169,  61, 251, 221, 128, 221,
            14,  19, 179,  25, 107, 132,  10, 188, 149,   0, 197,
            52, 151, 239, 244, 103, 215, 224,  56, 242
        ];
        //let hospital_signature_bytes: Field = 0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77; // @dev - The signature from the hospital
        let _hospital_bill_hash_bytes: [u8; 32] = [
            3,  57, 199, 96, 145,  58, 183, 241,
            206, 140,  36, 34, 165, 163,  17, 210,
            97, 254, 154, 79,  91, 223, 149,  18,
            3, 210, 111, 56, 246, 219,  19, 104
        ];

        let _patient_name: Field = 0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8; // @dev - The patient name
        let _treatment_date: Field = 1690982400; // @dev - The date of treatment (UNIX timestamp)
        let _treatment_icd_code: Field = 0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8; // @dev - The treatment details to be covered by a insurance policy (ICD code)
        let _treatment_cpt_code: Field = 0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77; // @dev - The treatment details to be covered by a insurance policy (CPT code)
        let _treatment_hcpcs_code: Field = 0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8; // @dev - The treatment details to be covered by a insurance policy (HCPCS code)
        let _treatment_drg_code: Field = 0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77; // @dev - The treatment details to be covered by a insurance policy (DRG code)        
        let hospital_bill_data: HospitalBillData = HospitalBillData {
            hospital_bill_hash_bytes: _hospital_bill_hash_bytes,
            hospital_bill_amount: _hospital_bill_amount,
            hospital_pubkey_bytes: _hospital_pubkey_bytes,
            hospital_signature_bytes: _hospital_signature_bytes, // @dev - The signature from the hospital
            patient_name: _patient_name, // @dev - The patient name
            treatment_date: _treatment_date, // @dev - The date of treatment (UNIX timestamp)
            treatment_icd_code: _treatment_icd_code, // @dev - The treatment details (ICD code)
            treatment_cpt_code: _treatment_cpt_code, // @dev - The treatment details (CPT code)
            treatment_hcpcs_code: _treatment_hcpcs_code, // @dev - The treatment details (HCPCS code)
            treatment_drg_code: _treatment_drg_code // @dev - The treatment details (DRG code)
        };

        // @dev - Split the pubKey into 2 parts
        let key = ecrecover::secp256k1::PubKey::from_unified(hospital_bill_data.hospital_pubkey_bytes);
        let pubkey_of_hospital_x: [u8; 32] = key.pub_x;
        let pubkey_of_hospital_y: [u8; 32] = key.pub_y;
        println(f"pubkey_of_hospital_x: {pubkey_of_hospital_x}");
        println(f"pubkey_of_hospital_y: {pubkey_of_hospital_y}");

        // @dev - Recover the wallet address from the pubKey, signature, and the hashed message
        let wallet_address = ecrecover::ecrecover(key.pub_x, key.pub_y, hospital_bill_data.hospital_signature_bytes, hospital_bill_data.hospital_bill_hash_bytes);
        let signature_as_fields: [Field; 64] = hospital_bill_data.hospital_signature_bytes.map(|x : u8| x as Field);
        println(f"wallet_address: {wallet_address}");
        println(f"signature_as_fields: {signature_as_fields}");

        // @dev - Generate the nullifier
        let nullifier = poseidon2::Poseidon2::hash([root, secret, hospital_bill_data.hospital_bill_amount], 3);
        println(f"nullifier: {nullifier}");

        // @dev - Generate a ZKP and publicInput as the "revealed_data"
        let revealed_data: RevealedData = main(
            root,
            hash_path,
            index,
            secret,
            nullifier,
            insurance_policy_data,
            hospital_bill_data
        );

        // @dev - Check the revealed data, which is the publicInput
        let revealed_data_nullifier = revealed_data.nullifier;
        let revealed_data_is_bill_signed = revealed_data.is_bill_signed;
        let revealed_data_is_bill_amount_exceed_threshold = revealed_data.is_bill_amount_exceed_threshold;
        let revealed_data_is_policy_valid = revealed_data.is_policy_valid;
        println(f"revealed_data.nullifier: {revealed_data_nullifier}");
        println(f"revealed_data.is_bill_signed: {revealed_data_is_bill_signed}");
        println(f"revealed_data.is_bill_amount_exceed_threshold: {revealed_data_is_bill_amount_exceed_threshold}");
        println(f"revealed_data.is_policy_valid: {revealed_data_is_policy_valid}");

        let inputs_for_note_commitment: [Field; 1] = [secret];
        let note_commitment = poseidon2::Poseidon2::hash(inputs_for_note_commitment, inputs_for_note_commitment.len());

        //let inputs_for_nullifier: [Field; 1] = [ip_nft_data.nft_token_id];
        let inputs_for_nullifier: [Field; 3] = [root, secret, hospital_bill_data.hospital_bill_amount];
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
