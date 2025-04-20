pub struct InsurancePolicyData {
    start_date: Field, // @dev - The start date of the insurance policy (UNIX timestamp)
    end_date: Field,   // @dev - The end date of the insurance policy (UNIX timestamp)
    minimum_threshold_of_bill_amount: Field, // @dev - The minimum threshold for the insurance claim  
    treatment_icd_code: Field,          // @dev - The treatment details (ICD code)
    treatment_cpt_code: Field,          // @dev - The treatment details (CPT code)
    treatment_hcpcs_code: Field,        // @dev - The treatment details (HCPCS code)
    treatment_drg_code: Field           // @dev - The treatment details (DRG code)
}

pub struct HospitalBillData { // @dev - Bill data, which is issued by a Hospital. (Healthcare Provider)
    hospital_bill_hash_bytes: [u8; 32], // @dev - The hash of the hospital bill
    //hospital_bill_hash: Field,
    hospital_bill_amount: Field,        // @dev - Charges for the treatment
    hospital_pubkey_bytes: [u8; 64],    // @dev - The public key of the hospital, which must be registered in the on-Chain Registry contract (HospitalRegistry.sol).
    //hospital_pubkey_x: [u8; 32],      // @dev - public key, which is sliced at the 1st half of 
    //hospital_pubkey_y: [u8; 32],      // @dev - public key, which is sliced at the 2nd half of public key
    hospital_signature_bytes: [u8; 64], // @dev - The signature from the hospital
    //hospital_signature: Field,        // @dev - The signature from the hospital
    patient_name: Field,                // @dev - The patient name
    treatment_date: Field,              // @dev - The date of treatment (UNIX timestamp)
    treatment_icd_code: Field,          // @dev - The treatment details (ICD code)
    treatment_cpt_code: Field,          // @dev - The treatment details (CPT code)
    treatment_hcpcs_code: Field,        // @dev - The treatment details (HCPCS code)
    treatment_drg_code: Field           // @dev - The treatment details (DRG code)
}

pub struct RevealedData {
    nullifier: Field,
    is_bill_signed: bool,
    is_bill_amount_exceed_threshold: bool,
    is_policy_valid: bool
}