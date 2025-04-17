mod tests;      // tests/mod.nr
mod data_types; // data_types.nr
mod converters; // converters.nr -> converters/convert_cid_to_poseidon_hash.nr -> convert_nft_metadata_cid_to_poseidon_hash()

use std::hash::poseidon2;
use std::ecdsa_secp256k1::verify_signature;
use dep::std;
use dep::ecrecover; // @dev - Source: https://github.com/colinnielsen/ecrecover-noir

use data_types::{ InsuranceClaimData, RevealedData }; // @dev - IPNftData struct


fn main(
    root: pub Field, // @dev - Merkle Root
    hash_path: [Field; 2],
    index: Field,
    secret: Field,   // @dev - A hidden metadata hash (private)
    expected_nullifier: Field,
    insurance_claim_data: InsuranceClaimData
) -> pub RevealedData {
    // @dev - The minimum threshold for the insurance claim
    let min_threshold: Field = 1000;

    // @dev - Convert data type from "Field" to "uint32"
    let hospital_bill_amount_as_uint: u32 = insurance_claim_data.hospital_bill_amount as u32;
    let min_threshold_as_uint: u32 = min_threshold as u32;

    // @dev - The insurance claim related constraints
    assert(hospital_bill_amount_as_uint >= min_threshold_as_uint, "Invalid hospital bill: A given hospital bill amount is less than the minimum threshold");
    let is_policy_valid: bool = true;

    // @dev - Hashing the "raw" pubKey of the authorized healthcare provider
    let authorized_healthcare_provider_pubkey_hash: Field = poseidon2::Poseidon2::hash([insurance_claim_data.authorized_healthcare_provider_pubkey], 1);
    assert(authorized_healthcare_provider_pubkey_hash == insurance_claim_data.expected_authorized_healthcare_provider_pubkey_hash, "Invalid authorized healthcare provider pubKey: The given pubKey is not valid");


    // @dev - 
    let key = ecrecover::secp256k1::PubKey::from_unified(insurance_claim_data.pubkey_of_hospital_bytes);
    let pubkey_of_hospital_x: [u8; 32] = key.pub_x;
    let pubkey_of_hospital_y: [u8; 32] = key.pub_y;
    println(pubkey_of_hospital_x);
    println(pubkey_of_hospital_y);
    //let address = ecrecover::ecrecover(key.pub_x, key.pub_y, signature, hashed_message);
    //let signature_as_fields = signature.map(|x : u8| x as Field);

    // @dev - Verifying the signature of the hospital (for the bill that they issued).
    //let signature_from_hospital_bytes: [u8; 64] = signature_from_hospital.to_be_bytes();  // [Result]: Success
    //let hospital_bill_hash_bytes: [u8; 32] = hospital_bill_hash.to_be_bytes();
    assert(std::ecdsa_secp256k1::verify_signature(
        pubkey_of_hospital_x, // Slile the first half of the public key
        pubkey_of_hospital_y, // Slile the second half of the public key
           insurance_claim_data.signature_from_hospital_bytes,
        insurance_claim_data.hospital_bill_hash_bytes
    ) == true, "Invalid hospital bill: The given hospital bill is not valid");

    let inputs_for_note_commitment: [Field; 1] = [secret];
    let note_commitment = poseidon2::Poseidon2::hash(inputs_for_note_commitment, inputs_for_note_commitment.len());

    //let inputs_for_nullifier: [Field; 1] = [ip_nft_data.nft_token_id];
    let inputs_for_nullifier: [Field; 3] = [root, secret, insurance_claim_data.hospital_bill_amount];
    let nullifier = poseidon2::Poseidon2::hash(inputs_for_nullifier, inputs_for_nullifier.len());
    println(nullifier);
    println(expected_nullifier); // [Log]: 0x1265c921cb8e0dc6c91f70ae08b14352b8f10451aee7582b9ed44abea8d4123c

    // Constraint: nullifier (hash) == expected_nullifier (hash)
    assert(nullifier == expected_nullifier);

    //nullifier
    //(nullifier, nft_metadata_cid_hash)
    RevealedData {
        nullifier,
        authorized_healthcare_provider_pubkey_hash // @dev - Hashed pubKey
    }
}
