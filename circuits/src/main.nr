mod tests;      // tests/mod.nr
mod data_types; // data_types.nr
mod utils;      // utils.nr -> utils/converter_field_to_bytes.nr -> convert_field_bytes32_to_uint8_array()

use std::hash::poseidon2;
use std::ecdsa_secp256k1::verify_signature;
use dep::std;
use dep::ecrecover; // @dev - Source: https://github.com/colinnielsen/ecrecover-noir

use data_types::{ InsurancePolicyData, HospitalBillData, RevealedData };    // @dev - struct
use utils::converter_field_to_bytes::convert_field_bytes32_to_uint8_array;  // @dev - Convert a Field (bytes32) value to uint8Array value
use utils::converter_field_to_bytes::convert_field_bytes64_to_uint8_array;  // @dev - Convert a Field (bytes64) value to uint8Array value

fn main(
    root: pub Field, // @dev - Merkle Root
    hash_path: [Field; 2],
    index: Field,
    secret: Field,   // @dev - A hidden metadata hash (private)
    nullifier: pub Field,
    insurance_policy_data: InsurancePolicyData,
    hospital_bill_data: HospitalBillData
) -> pub RevealedData {
    // @dev - [TEST] Convert a Field (bytes32) value to uint8Array value
    let uint8_array_value_32:[u8; 32]= convert_field_bytes32_to_uint8_array(root);
    println(f"uint8_array_value (bytes32): {uint8_array_value_32}"); // [Log]: uint8_array_value (bytes32): [33, 85, 151, 186, 205, 156, 126, 151, 125, 252, 23, 15, 50, 0, 116, 21, 93, 233, 116, 190, 73, 69, 121, 210, 88, 110, 91, 38, 143, 163, 182, 41]

    // let value_in_field: Field = 0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8;
    // //let value_in_field: Field = 0x8318535b54105d4a7aae60c08fc45f9687181b4fdfc625bd1a753fa7397fed753547f11ca8696646f2f3acb08e31016afac23e630c5d11f59f61fef57b0d2aa5;
    // let uint8_array_value_64:[u8; 64]= convert_field_bytes64_to_uint8_array(value_in_field);
    // println(f"uint8_array_value (bytes64): {uint8_array_value_64}"); // [Log]: uint8_array_value (bytes64): 


    // @dev - Convert data type from "Field" to "uint32"
    let hospital_bill_amount_as_uint: u32 = hospital_bill_data.hospital_bill_amount as u32;
    let minimum_threshold_of_bill_amount_as_uint: u32 = insurance_policy_data.minimum_threshold_of_bill_amount as u32;

    // @dev - Constraint: The hospital bill amount must be greater than the minimum threshold
    assert(hospital_bill_amount_as_uint >= minimum_threshold_of_bill_amount_as_uint, "Invalid hospital bill: A given hospital bill amount must be greater than the minimum threshold");
    let _is_bill_amount_exceed_threshold: bool = true;

    // @dev - Constraint: The treatment date must be within the insurance policy period
    let start_date_as_uint: u32 = insurance_policy_data.start_date as u32;
    let end_date_as_uint: u32 = insurance_policy_data.end_date as u32;
    let treatment_date_as_uint: u32 = hospital_bill_data.treatment_date as u32;
    assert(
        start_date_as_uint <= treatment_date_as_uint & 
        treatment_date_as_uint <= end_date_as_uint, 
        "Invalid the treatment date: A given treatment date must be within the insurance policy period"
    );

    // @dev - Constraint: The insurance policy must be valid
    let treatment_icd_code_hash: Field = poseidon2::Poseidon2::hash([hospital_bill_data.treatment_icd_code], 1);
    let treatment_cpt_code_hash: Field = poseidon2::Poseidon2::hash([hospital_bill_data.treatment_cpt_code], 1);
    let treatment_hcpcs_code_hash: Field = poseidon2::Poseidon2::hash([hospital_bill_data.treatment_hcpcs_code], 1);
    let treatment_drg_code_hash: Field = poseidon2::Poseidon2::hash([hospital_bill_data.treatment_drg_code], 1);
    let covered_treatment_icd_code_hash: Field = poseidon2::Poseidon2::hash([insurance_policy_data.treatment_icd_code], 1);
    let covered_treatment_cpt_code_hash: Field = poseidon2::Poseidon2::hash([insurance_policy_data.treatment_cpt_code], 1);
    let covered_treatment_hcpcs_code_hash: Field = poseidon2::Poseidon2::hash([insurance_policy_data.treatment_hcpcs_code], 1);
    let covered_treatment_drg_code_hash: Field = poseidon2::Poseidon2::hash([insurance_policy_data.treatment_drg_code], 1);
    assert(treatment_icd_code_hash == covered_treatment_icd_code_hash, "Invalid the treatment details (ICD): A given treatment details must be covered by the insurance policy");
    assert(treatment_cpt_code_hash == covered_treatment_cpt_code_hash, "Invalid the treatment details (CPT): A given treatment details must be covered by the insurance policy");
    assert(treatment_hcpcs_code_hash == covered_treatment_hcpcs_code_hash, "Invalid the treatment details (HCPCS): A given treatment details must be covered by the insurance policy");
    assert(treatment_drg_code_hash == covered_treatment_drg_code_hash, "Invalid the treatment details (DRG): A given treatment details must be covered by the insurance policy");
    let _is_policy_valid: bool = true;

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

    // @dev - Constraint: Verifying the signature of the hospital (for the bill that they issued).
    //let hospital_signature_bytes: [u8; 64] = hospital_signature_bytes.to_be_bytes();  // [Result]: Success
    //let hospital_bill_hash_bytes: [u8; 32] = hospital_bill_hash.to_be_bytes();
    assert(std::ecdsa_secp256k1::verify_signature(
        pubkey_of_hospital_x, // Slile the first half of the public key
        pubkey_of_hospital_y, // Slile the second half of the public key
           hospital_bill_data.hospital_signature_bytes,
        hospital_bill_data.hospital_bill_hash_bytes
    ) == true, "Invalid hospital bill: A given hospital bill is not valid");
    let _is_bill_signed: bool = true;

    let inputs_for_note_commitment: [Field; 1] = [secret];
    let note_commitment = poseidon2::Poseidon2::hash(inputs_for_note_commitment, inputs_for_note_commitment.len());

    //let inputs_for_nullifier: [Field; 1] = [ip_nft_data.nft_token_id];
    let inputs_for_nullifier: [Field; 3] = [root, secret, hospital_bill_data.hospital_bill_amount];
    let expected_nullifier = poseidon2::Poseidon2::hash(inputs_for_nullifier, inputs_for_nullifier.len());
    println(nullifier);
    println(expected_nullifier); // [Log]: 0x1265c921cb8e0dc6c91f70ae08b14352b8f10451aee7582b9ed44abea8d4123c

    // Constraint: nullifier (hash) == expected_nullifier (hash)
    assert(nullifier == expected_nullifier);

    // @dev - Return
    RevealedData {
        nullifier: nullifier,
        is_bill_signed: _is_bill_signed,
        is_bill_amount_exceed_threshold: _is_bill_amount_exceed_threshold,
        is_policy_valid: _is_policy_valid,
    }
}
