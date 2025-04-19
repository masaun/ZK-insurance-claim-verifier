pub struct InsuranceClaimData {
    hospital_bill_hash_bytes: [u8; 32], // @dev - The hash of the hospital bill
    //hospital_bill_hash: Field,
    hospital_bill_amount: Field,
    hospital_pubkey_bytes: [u8; 64],
    //pubkey_of_hospital_x: [u8; 32], // @dev - public key, which is sliced at the 1st half of 
    //pubkey_of_hospital_y: [u8; 32], // @dev - public key, which is sliced at the 2nd half of public key
    hospital_signature_bytes: [u8; 64] // @dev - The signature from the hospital
    //hospital_signature_bytes: Field,        // @dev - The signature from the hospital
}

pub struct RevealedData {
    nullifier: Field
}