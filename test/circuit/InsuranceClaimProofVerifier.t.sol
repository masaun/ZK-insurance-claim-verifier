pragma solidity ^0.8.17;

import { UltraVerifier } from "../../contracts/circuit/ultra-verifier/plonk_vk.sol";
import { InsuranceClaimProofVerifier } from "../../contracts/circuit/InsuranceClaimProofVerifier.sol";
//import "../circuits/target/contract.sol";
import { DataTypeConverter } from "../../contracts/libraries/DataTypeConverter.sol";

import "forge-std/console.sol";
import { Test } from "forge-std/Test.sol";
import { NoirHelper } from "foundry-noir-helper/NoirHelper.sol";


contract InsuranceClaimProofVerifierTest is Test {
    InsuranceClaimProofVerifier public insuranceClaimProofVerifier;
    UltraVerifier public verifier;
    NoirHelper public noirHelper;

    function setUp() public {
        noirHelper = new NoirHelper();
        verifier = new UltraVerifier();
        insuranceClaimProofVerifier = new InsuranceClaimProofVerifier(verifier);
    }

    function test_verifyProof() public {
        uint256[] memory hash_path = new uint256[](2);
        hash_path[0] = 0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8;
        hash_path[1] = 0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77;

        bytes32[] memory hash_path_bytes32 = new bytes32[](2);
        hash_path_bytes32[0] = bytes32(hash_path[0]);
        hash_path_bytes32[1] = bytes32(hash_path[1]);

        /// @dev - [TEST]: Convert the first element of the hash_path array to bytes
        //bytes memory valueInUTF8Bytes = DataTypeConverter.toUtf8Bytes(hash_path[0]);
        //console.logBytes(valueInUTF8Bytes);

        /// @dev - [TODO]: Using NoirJS to generate a value in "UTF-8 bytes array".

        /// @dev - Set the input data for generating a proof
        noirHelper.withInput("root", bytes32(uint256(0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629)))
                  .withInput("hash_path", hash_path_bytes32)
                  .withInput("index", bytes32(uint256(0)))
                  .withInput("secret", bytes32(uint256(1)))                   
                  .withInput("nullifier", bytes32(uint256(0x2658c0d82f9c0728e055fd8272568260ed2d5117a0ed2e1935f737c528ef3505)))
                  
                  // @dev - The InsurancePolicyData struct
                  .withStruct("insurance_policy_data")
                  .withStructInput("insurer_pubkey_bytes", bytes32(uint256(uint160(0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266)))) // [NOTE]: An input data of 'Address' type must be cast to uint160 first. Then, it should be cast to uint256 and bytes32.
                  .withStructInput("insurer_signature_bytes", bytes32(uint256(1)))
                  .withStructInput("patient_name", string('John Doe'))
                  .withStructInput("start_date", bytes32(uint256(1690982400))) // [NOTE]: 2023-08-01
                  .withStructInput("end_date", bytes32(uint256(1690982600)))   // [NOTE]: 2023-08-01
                  .withStructInput("minimum_threshold_of_bill_amount", bytes32(uint256(1000)))
                  .withStructInput("treatment_icd_code", string('ICD-10-CM: A00.0'))
                  .withStructInput("treatment_cpt_code", string('CPT: 99213'))
                  .withStructInput("treatment_hcpcs_code", string('HCPCS: G0008'))
                  .withStructInput("treatment_drg_code", string('DRG: 001'))
                  
                  // @dev - The HospitalBillData struct
                  .withStruct("hospital_bill_data")
                  .withStructInput("hospital_bill_hash_bytes", bytes32(uint256(0x2658c0d82f9c0728e055fd8272568260ed2d5117a0ed2e1935f737c528ef3505))) // [NOTE]: An input data of 'Address' type must be cast to uint160 first. Then, it should be cast to uint256 and bytes32.
                  .withStructInput("hospital_bill_amount", bytes32(uint256(1000)))
                  .withStructInput("hospital_pubkey_bytes", bytes32(uint256(uint160(0x1357Be3F8ba486146f34F782eB14346747FF5d80)))) // [NOTE]: An input data of 'Address' type must be cast to uint160 first. Then, it should be cast to uint256 and bytes32.
                  .withStructInput("hospital_signature_bytes", bytes32(uint256(0x2658c0d82f9c0728e055fd8272568260ed2d5117a0ed2e1935f737c528ef3505)))
                  .withStructInput("patient_name", string('John Doe'))
                  .withStructInput("treatment_date", bytes32(uint256(1690982500))) // [NOTE]: 2023-08-01
                  .withStructInput("treatment_icd_code", string('ICD-10-CM: A00.0'))
                  .withStructInput("treatment_cpt_code", string('CPT: 99213'))
                  .withStructInput("treatment_hcpcs_code", string('HCPCS: G0008'))
                  .withStructInput("treatment_drg_code", string('DRG: 001'));

        /// @dev - Generate the proof
        (bytes32[] memory publicInputs, bytes memory proof) = noirHelper.generateProof("test_verifyProof", 6); // [NOTE]: The number of public inputs is '3'.
        console.logBytes32(publicInputs[0]); // [Log]: 0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629
        console.logBytes32(publicInputs[1]); // [Log]: 0x26df0d347e961cb94e1cc6d2ad8558696de8c1964b30e26f2ec8b926cbbbf862
        console.logBytes32(publicInputs[2]); // [Log]: 0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0
        console.logBytes32(publicInputs[3]); // [Log]: 
        console.logBytes32(publicInputs[4]); // [Log]: 
        console.logBytes32(publicInputs[5]); // [Log]: 

        /// @dev - Verify the proof
        insuranceClaimProofVerifier.verifyInsuranceClaimProof(proof, publicInputs);
    }

    function test_wrongProof() public {
        noirHelper.clean();
        uint256[] memory hash_path = new uint256[](2);
        hash_path[0] = 0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8;
        hash_path[1] = 0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77;

        bytes32[] memory hash_path_bytes32 = new bytes32[](2);
        hash_path_bytes32[0] = bytes32(hash_path[0]);
        hash_path_bytes32[1] = bytes32(hash_path[1]);

        /// @dev - Set the input data for generating a proof
        noirHelper.withInput("root", bytes32(uint256(0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629)))
                  .withInput("hash_path", hash_path_bytes32)
                  .withInput("index", bytes32(uint256(0)))
                  .withInput("secret", bytes32(uint256(1)))                   
                  .withInput("nullifier", bytes32(uint256(0x2658c0d82f9c0728e055fd8272568260ed2d5117a0ed2e1935f737c528ef3505)))
                  .withStruct("insurance_policy_data") // @dev - The InsurancePolicyData struct
                  .withStructInput("insurer_pubkey_bytes", bytes32(uint256(uint160(0xC6093Fd9cc143F9f058938868b2df2daF9A91d28)))) // [NOTE]: An input data of 'Address' type must be cast to uint160 first. Then, it should be cast to uint256 and bytes32.
                  .withStructInput("insurer_signature_bytes", bytes32(uint256(1)))
                  .withStructInput("patient_name", string('John Doe'))
                  .withStructInput("start_date", bytes32(uint256(0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8)))
                  .withStructInput("end_date", bytes32(uint256(0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77)))
                  .withStructInput("minimum_threshold_of_bill_amount", bytes32(uint256(0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8)))
                  .withStructInput("treatment_icd_code", string('ICD-10-CM: A00.0'))
                  .withStructInput("treatment_cpt_code", string('CPT: 99213'))
                  .withStructInput("treatment_hcpcs_code", string('HCPCS: G0008'))
                  .withStructInput("treatment_drg_code", string('DRG: 001'))
                  .withStruct("hospital_bill_data") // @dev - The HospitalBillData struct
                  .withStructInput("hospital_bill_hash_bytes", bytes32(uint256(uint160(0xC6093Fd9cc143F9f058938868b2df2daF9A91d28)))) // [NOTE]: An input data of 'Address' type must be cast to uint160 first. Then, it should be cast to uint256 and bytes32.
                  .withStructInput("hospital_bill_amount", bytes32(uint256(1)))
                  .withStructInput("hospital_pubkey_bytes", bytes32(uint256(uint160(0xC6093Fd9cc143F9f058938868b2df2daF9A91d28)))) // [NOTE]: An input data of 'Address' type must be cast to uint160 first. Then, it should be cast to uint256 and bytes32.
                  .withStructInput("hospital_signature_bytes", bytes32(uint256(1)))
                  .withStructInput("patient_name", string('John Doe'))
                  .withStructInput("treatment_date", bytes32(uint256(0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8)))
                  .withStructInput("treatment_icd_code", string('ICD-10-CM: A00.0'))
                  .withStructInput("treatment_cpt_code", string('CPT: 99213'))
                  .withStructInput("treatment_hcpcs_code", string('HCPCS: G0008'))
                  .withStructInput("treatment_drg_code", string('DRG: 001'));

        /// @dev - Generate the proof
        (bytes32[] memory publicInputs, bytes memory proof) = noirHelper.generateProof("test_wrongProof", 6);
        console.logBytes32(publicInputs[0]); // [Log]: 0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629
        console.logBytes32(publicInputs[1]); // [Log]: 0x26df0d347e961cb94e1cc6d2ad8558696de8c1964b30e26f2ec8b926cbbbf862
        console.logBytes32(publicInputs[2]); // [Log]: 0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0
        console.logBytes32(publicInputs[3]); // [Log]: 
        console.logBytes32(publicInputs[4]); // [Log]: 
        console.logBytes32(publicInputs[5]); // [Log]: 

        /// @dev - Create a fake public input, which should fail because the public input is wrong
        bytes32[] memory fakePublicInputs = new bytes32[](2);
        fakePublicInputs[0] = publicInputs[0];
        fakePublicInputs[1] = bytes32(uint256(0xddddd));  // @dev - This is wrong publicInput ("nulifieir")

        /// @dev - Verify the proof, which should be reverted
        vm.expectRevert();
        insuranceClaimProofVerifier.verifyInsuranceClaimProof(proof, fakePublicInputs);
    }

    // function test_all() public {
    //     // forge runs tests in parallel which messes with the read/writes to the proof file
    //     // Run tests in wrapper to force them run sequentially
    //     verifyProof();
    //     wrongProof();
    // }

}