pub struct InsuranceClaimData {
    hospital_bill_hash_bytes: [u8; 32], // @dev - The hash of the hospital bill
    //hospital_bill_hash: Field,
    hospital_bill_amount: Field,
    hospital_pubkey_bytes: [u8; 64],
    //pubkey_of_hospital_x: [u8; 32], // @dev - public key, which is sliced at the 1st half of 
    //pubkey_of_hospital_y: [u8; 32], // @dev - public key, which is sliced at the 2nd half of public key
    hospital_signature_bytes: [u8; 64], // @dev - The signature from the hospital
    //hospital_signature_bytes: Field,        // @dev - The signature from the hospital
    healthcare_insurance_provider_pubkey: Field,      // @dev - Raw pubKey /This public key should be validated on-chain with a on-chain registry.
    healthcare_insurance_provider_pubkey_hash: Field  // @dev - Hashed pubKey
}

pub struct RevealedData {
    nullifier: Field,
    healthcare_insurance_provider_pubkey_hash: Field // @dev - This public key should be validated on-chain with a on-chain registry.
}