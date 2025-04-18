pub struct InsuranceClaimData {
    hospital_bill_hash_bytes: [u8; 32], // @dev - The hash of the hospital bill
    //hospital_bill_hash: Field,
    hospital_bill_amount: Field,
    pubkey_of_hospital_bytes: [u8; 64],
    //pubkey_of_hospital_x: [u8; 32], // @dev - public key, which is sliced at the 1st half of 
    //pubkey_of_hospital_y: [u8; 32], // @dev - public key, which is sliced at the 2nd half of public key
    signature_from_hospital_bytes: [u8; 64], // @dev - The signature from the hospital
    //signature_from_hospital: Field,        // @dev - The signature from the hospital
    authorized_healthcare_provider_pubkey: Field,      // @dev - Raw pubKey /This public key should be validated on-chain with a on-chain registry.
    authorized_healthcare_provider_pubkey_hash: Field  // @dev - Hashed pubKey
}

pub struct RevealedData {
    nullifier: Field,
    authorized_healthcare_provider_pubkey_hash: Field // @dev - This public key should be validated on-chain with a on-chain registry.
}