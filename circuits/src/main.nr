mod tests;      // tests/mod.nr
mod data_types; // data_types.nr
mod converters; // converters.nr -> converters/convert_cid_to_poseidon_hash.nr -> convert_nft_metadata_cid_to_poseidon_hash()

use std::hash::poseidon2;
use std::ecdsa_secp256k1::verify_signature;
use dep::std;
use dep::ecrecover; // @dev - Source: https://github.com/colinnielsen/ecrecover-noir

use data_types::{ InsurancePolicyData, HospitalBillData, RevealedData }; // @dev - IPNftData struct


fn main(
    root: pub Field, // @dev - Merkle Root
    hash_path: [Field; 2],
    index: Field,
    secret: Field,   // @dev - A hidden metadata hash (private)
    nullifier: Field,
    insurance_policy_data: InsurancePolicyData,
    hospital_bill_data: HospitalBillData
) -> pub RevealedData {
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
