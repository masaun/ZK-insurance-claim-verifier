//mod test_inputs; // test_inputs.nr
use std::hash::poseidon2;


/** 
 * @notice - Test: Convert IPFS CID (sha256) -> bytes -> Field -> Poseidon2 Hash
 */
pub fn convert_nft_metadata_cid_to_poseidon_hash(metadata_cid: str<46>) -> Field {
    let metadata_cid: str<46> = metadata_cid;
    println(metadata_cid); // [Log]: QmYwAPJzv5CZsnAzt8auVZRn5W4mBkpLsD4HaBFN6r5y6F

    let metadata_cid_bytes: [u8; 46] = metadata_cid.as_bytes();
    println(metadata_cid_bytes); // [Log]: 

    let metadata_cid_field = Field::from_be_bytes::<46>(metadata_cid_bytes);
    println(metadata_cid_field); // [Log]: 0x2182f80240dbbfd8b3316c247d0ea667122dfc185af9cf934aeb9ec6dc2e9b28

    let inputs_for_metadata_cid_field: [Field; 1] = [metadata_cid_field];
    let metadata_cid_hash = poseidon2::Poseidon2::hash(inputs_for_metadata_cid_field, inputs_for_metadata_cid_field.len());
    println(metadata_cid_hash); // [Log]: 0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0

    metadata_cid_hash
}

