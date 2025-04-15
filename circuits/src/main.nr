mod tests;      // tests/mod.nr
mod data_types; // data_types.nr
mod converters; // converters.nr -> converters/convert_cid_to_poseidon_hash.nr -> convert_nft_metadata_cid_to_poseidon_hash()

use std::hash::poseidon2;
use std::ecdsa_secp256k1::verify_signature;

use data_types::{ IPNftData, RevealedData }; // @dev - IPNftData struct


fn main(
    root: pub Field, // @dev - Merkle Root
    hash_path: [Field; 2],
    index: Field,
    secret: Field,   // @dev - A hidden metadata hash (private)
    expected_nullifier: Field,
    expected_nft_metadata_cid_hash: Field,
    ip_nft_data: IPNftData,
    hospital_bill_hash: Field,
    hospital_bill_amount: Field,
    pubkey_of_hospital_x: [u8; 32], // @dev - public key, which is sliced at the 1st half of 
    pubkey_of_hospital_y: [u8; 32], // @dev - public key, which is sliced at the 2nd half of public key
    signature_from_hospital: Field,
    authorized_healthcare_provider_pubkey: Field,               // @dev - Raw pubKey /This public key should be validated on-chain with a on-chain registry.
    expected_authorized_healthcare_provider_pubkey_hash: Field, // @dev - Hashed pubKey
) -> pub RevealedData {
    // @dev - The minimum threshold for the insurance claim
    let min_threshold: Field = 1000;

    // @dev - Convert data type from "Field" to "uint32"
    let hospital_bill_amount_as_uint: u32 = hospital_bill_amount as u32;
    let min_threshold_as_uint: u32 = min_threshold as u32;

    // @dev - The insurance claim related constraints
    assert(hospital_bill_amount_as_uint >= min_threshold_as_uint, "Invalid hospital bill: A given hospital bill amount is less than the minimum threshold");
    let is_policy_valid: bool = true;

    // @dev - Hashing the "raw" pubKey of the authorized healthcare provider
    let authorized_healthcare_provider_pubkey_hash: Field = poseidon2::Poseidon2::hash([authorized_healthcare_provider_pubkey], 1);
    assert(authorized_healthcare_provider_pubkey_hash == expected_authorized_healthcare_provider_pubkey_hash, "Invalid authorized healthcare provider pubKey: The given pubKey is not valid");

    // @dev - Verifying the signature of the hospital (for the bill that they issued).
    assert(verify_signature(
        pubkey_of_hospital_x, // Slile the first half of the public key
        pubkey_of_hospital_y, // Slile the second half of the public key
        signature_from_hospital.to_be_bytes(),
        hospital_bill_hash.to_be_bytes()
    ) == true, "Invalid hospital bill: The given hospital bill is not valid");

    // Convert a IPFS CID (sha256) -> bytes -> Field -> Poseidon2 Hash
    //let nft_metadata_cid: str<46> = "QmYwAPJzv5CZsnAzt8auVZRn5W4mBkpLsD4HaBFN6r5y6F";
    let nft_metadata_cid_hash: Field = converters::converter_module::convert_nft_metadata_cid_to_poseidon_hash(ip_nft_data.nft_metadata_cid);
    println(nft_metadata_cid_hash); // [Log]: 0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0

    // Constraint: nft_metadata_cid_hash == expected_nft_metadata_hash
    assert(nft_metadata_cid_hash == expected_nft_metadata_cid_hash);

    println(expected_nullifier); // [Log]: 0x1265c921cb8e0dc6c91f70ae08b14352b8f10451aee7582b9ed44abea8d4123c

    let inputs_for_note_commitment: [Field; 1] = [secret];
    let note_commitment = poseidon2::Poseidon2::hash(inputs_for_note_commitment, inputs_for_note_commitment.len());

    //let inputs_for_nullifier: [Field; 1] = [ip_nft_data.nft_token_id];
    let inputs_for_nullifier: [Field; 5] = [root, secret, ip_nft_data.nft_owner, ip_nft_data.nft_token_id, expected_nft_metadata_cid_hash];
    let nullifier = poseidon2::Poseidon2::hash(inputs_for_nullifier, inputs_for_nullifier.len());
    println(nullifier);

    // Constraint: nullifier (hash) == expected_nullifier (hash)
    assert(nullifier == expected_nullifier);

    //nullifier
    //(nullifier, nft_metadata_cid_hash)
    RevealedData {
        nullifier,
        nft_metadata_cid_hash,
        authorized_healthcare_provider_pubkey_hash // @dev - Hashed pubKey
    }
}
