pragma solidity ^0.8.17;

import { UltraVerifier } from "../../contracts/circuit/ultra-verifier/plonk_vk.sol";
import { InsuranceClaimProofVerifier } from "../../contracts/circuit/InsuranceClaimProofVerifier.sol";
//import "../circuits/target/contract.sol";
import { DataTypeConverter } from "../../contracts/libraries/DataTypeConverter.sol";

import "forge-std/console.sol";
import { Test } from "forge-std/Test.sol";
import { NoirHelper } from "foundry-noir-helper/NoirHelper.sol";

/// @dev - Import the PubkeyAndSignedMessageExtractor.sol from the scripts/utils/array-bytes-generator directory
import { PubkeyAndSignedMessageExtractor } from "../../scripts/utils/array-bytes-generator/contracts/libraries/PubkeyAndSignedMessageExtractor.sol";


contract InsuranceClaimProofVerifierTest is Test, PubkeyAndSignedMessageExtractor {
    InsuranceClaimProofVerifier public insuranceClaimProofVerifier;
    UltraVerifier public verifier;
    NoirHelper public noirHelper;

    function setUp() public {
        noirHelper = new NoirHelper();
        verifier = new UltraVerifier();
        insuranceClaimProofVerifier = new InsuranceClaimProofVerifier(verifier);
    }

    function test_verifyProof() public {

        uint8[] memory insurer_pubkey_bytes = new uint8[](64);
        uint8[] memory insurer_signature_bytes = new uint8[](64);
        uint8[] memory hospital_pubkey_bytes = new uint8[](64);
        uint8[] memory hospital_signature_bytes = new uint8[](64);
        // uint256[] memory insurer_pubkey_bytes = new uint256[](64);
        // uint256[] memory insurer_signature_bytes = new uint256[](64);
        // uint256[] memory hospital_pubkey_bytes = new uint256[](64);
        // uint256[] memory hospital_signature_bytes = new uint256[](64);

        /// @dev - [TEST]: Extract the public key and signed message from the output.json file
        PubkeyAndSignedMessage memory pubkeyAndSignedMessage = extractPubkeyAndSignedMessage();
        insurer_pubkey_bytes = pubkeyAndSignedMessage.insurer_pubkey_bytes;
        insurer_signature_bytes = pubkeyAndSignedMessage.insurer_signature_bytes;
        hospital_pubkey_bytes = pubkeyAndSignedMessage.hospital_pubkey_bytes;
        hospital_signature_bytes = pubkeyAndSignedMessage.hospital_signature_bytes;

        // uint256[] memory insurer_pubkey_bytes = pubkeyAndSignedMessage.insurer_pubkey_bytes;
        // uint256[] memory insurer_signature_bytes = pubkeyAndSignedMessage.insurer_signature_bytes;
        // uint256[] memory hospital_pubkey_bytes = pubkeyAndSignedMessage.hospital_pubkey_bytes;
        // uint256[] memory hospital_signature_bytes = pubkeyAndSignedMessage.hospital_signature_bytes;
        console.logUint(insurer_signature_bytes[0]); // [Log]: 211
        //console.logUint(insurer_pubkey_bytes[0]);
        //console.logUint(hospital_pubkey_bytes[0]);
        //console.logUint(hospital_signature_bytes[0]);  


        /// @dev - [TEST]: Convert a bytes32 value to an uint8 array bytes.
        //uint8[32] memory _hospital_bill_hash_bytes_uint8array = DataTypeConverter.bytes32ToUint8Array(0x5b001f2ad81fe86899545b51f8ecd1ca08674437d5c4748e1b70ba5dcf85ed86);
        uint8[32] memory _hospital_bill_hash_bytes_uint8array = [
            3,  57, 199, 96, 145,  58, 183, 241,
            206, 140,  36, 34, 165, 163,  17, 210,
            97, 254, 154, 79,  91, 223, 149,  18,
            3, 210, 111, 56, 246, 219,  19, 104
        ];
        //console.logUint(_hospital_bill_hash_bytes_uint8array[0]);

        uint256[32] memory _hospital_bill_hash_bytes_uint256array;
        for (uint256 i = 0; i < 32; i++) {
            _hospital_bill_hash_bytes_uint256array[i] = uint256(_hospital_bill_hash_bytes_uint8array[i]);
        }

        uint256[32] memory _hospital_bill_hash_bytes;
        for (uint i = 0; i < _hospital_bill_hash_bytes.length; i++) {
            _hospital_bill_hash_bytes[i] = _hospital_bill_hash_bytes_uint256array[i];
            console.log("_hospital_bill_hash_bytes[%s] = %s", i, _hospital_bill_hash_bytes[i]);
        }


        // uint8[32] memory uint8Array = [
        //     1, 2, 3, 4, 5, 6, 7, 8,
        //     9, 10, 11, 12, 13, 14, 15, 16,
        //     17, 18, 19, 20, 21, 22, 23, 24,
        //     25, 26, 27, 28, 29, 30, 31, 32
        // ];
     
        //bytes32 _hospital_bill_hash_bytes_bytes32 = DataTypeConverter.uint8ArrayToBytes32(_hospital_bill_hash_bytes);
        //console.logBytes32(_hospital_bill_hash_bytes_bytes32);


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
                  
                  // @dev - The InsurancePolicyData struct
                  .withStruct("insurance_policy_data")
                  .withStructInput("insurer_pubkey_bytes", insurer_pubkey_bytes) // [NOTE]: An input data of 'Address' type must be cast to uint160 first. Then, it should be cast to uint256 and bytes32.
                  .withStructInput("insurer_signature_bytes", insurer_signature_bytes)
                  .withStructInput("patient_name", bytes32(abi.encodePacked(string('John Doe'))))
                  .withStructInput("start_date", bytes32(uint256(1690982400))) // [NOTE]: 2023-08-01
                  .withStructInput("end_date", bytes32(uint256(1690982600)))   // [NOTE]: 2023-08-01
                  .withStructInput("minimum_threshold_of_bill_amount", bytes32(uint256(1000)))
                  .withStructInput("treatment_icd_code", bytes32(abi.encodePacked(string('ICD-10-CM: A00.0'))))
                  .withStructInput("treatment_cpt_code", bytes32(abi.encodePacked(string('CPT: 99213'))))
                  .withStructInput("treatment_hcpcs_code", bytes32(abi.encodePacked(string('HCPCS: G0008'))))
                  .withStructInput("treatment_drg_code", bytes32(abi.encodePacked(string('DRG: 001'))))
                  
                  // @dev - The HospitalBillData struct
                  .withStruct("hospital_bill_data")
                  .withStructInput("hospital_bill_hash_bytes", _hospital_bill_hash_bytes_uint8array)
                  //.withStructInput("hospital_bill_hash_bytes", _hospital_bill_hash_bytes) // [NOTE]: An input data of 'Address' type must be cast to uint160 first. Then, it should be cast to uint256 and bytes32.
                  //.withStructInput("hospital_bill_hash_bytes", bytes32(uint256(0x5b001f2ad81fe86899545b51f8ecd1ca08674437d5c4748e1b70ba5dcf85ed86))) // [NOTE]: An input data of 'Address' type must be cast to uint160 first. Then, it should be cast to uint256 and bytes32.
                  .withStructInput("hospital_bill_amount", bytes32(uint256(1000)))
                  .withStructInput("hospital_pubkey_bytes", hospital_pubkey_bytes) // [NOTE]: An input data of 'Address' type must be cast to uint160 first. Then, it should be cast to uint256 and bytes32.
                  .withStructInput("hospital_signature_bytes", hospital_signature_bytes)
                  .withStructInput("patient_name", bytes32(abi.encodePacked(string('John Doe'))))
                  .withStructInput("treatment_date", bytes32(uint256(1690982500))) // [NOTE]: 2023-08-01
                  .withStructInput("treatment_icd_code", bytes32(abi.encodePacked(string('ICD-10-CM: A00.0'))))
                  .withStructInput("treatment_cpt_code", bytes32(abi.encodePacked(string('CPT: 99213'))))
                  .withStructInput("treatment_hcpcs_code", bytes32(abi.encodePacked(string('HCPCS: G0008'))))
                  .withStructInput("treatment_drg_code", bytes32(abi.encodePacked(string('DRG: 001'))));

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
        // noirHelper.clean();
        // uint256[] memory hash_path = new uint256[](2);
        // hash_path[0] = 0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8;
        // hash_path[1] = 0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77;

        // bytes32[] memory hash_path_bytes32 = new bytes32[](2);
        // hash_path_bytes32[0] = bytes32(hash_path[0]);
        // hash_path_bytes32[1] = bytes32(hash_path[1]);

        // /// @dev - Set the input data for generating a proof
        // noirHelper.withInput("root", bytes32(uint256(0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629)))
        //           .withInput("hash_path", hash_path_bytes32)
        //           .withInput("index", bytes32(uint256(0)))
        //           .withInput("secret", bytes32(uint256(1)))                   
        //           .withInput("nullifier", bytes32(uint256(0x2658c0d82f9c0728e055fd8272568260ed2d5117a0ed2e1935f737c528ef3505)))
        //           .withStruct("insurance_policy_data") // @dev - The InsurancePolicyData struct
        //           .withStructInput("insurer_pubkey_bytes", bytes32(uint256(uint160(0xC6093Fd9cc143F9f058938868b2df2daF9A91d28)))) // [NOTE]: An input data of 'Address' type must be cast to uint160 first. Then, it should be cast to uint256 and bytes32.
        //           .withStructInput("insurer_signature_bytes", bytes32(uint256(1)))
        //           .withStructInput("patient_name", string('John Doe'))
        //           .withStructInput("start_date", bytes32(uint256(0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8)))
        //           .withStructInput("end_date", bytes32(uint256(0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77)))
        //           .withStructInput("minimum_threshold_of_bill_amount", bytes32(uint256(0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8)))
        //           .withStructInput("treatment_icd_code", bytes32(abi.encodePacked(string('ICD-10-CM: A00.0'))))
        //           .withStructInput("treatment_cpt_code", bytes32(abi.encodePacked(string('CPT: 99213'))))
        //           .withStructInput("treatment_hcpcs_code", bytes32(abi.encodePacked(string('HCPCS: G0008'))))
        //           .withStructInput("treatment_drg_code", bytes32(abi.encodePacked(string('DRG: 001'))))
        //           .withStruct("hospital_bill_data") // @dev - The HospitalBillData struct
        //           .withStructInput("hospital_bill_hash_bytes", bytes32(uint256(uint160(0xC6093Fd9cc143F9f058938868b2df2daF9A91d28)))) // [NOTE]: An input data of 'Address' type must be cast to uint160 first. Then, it should be cast to uint256 and bytes32.
        //           .withStructInput("hospital_bill_amount", bytes32(uint256(1)))
        //           .withStructInput("hospital_pubkey_bytes", bytes32(uint256(0x8318535b54105d4a7aae60c08fc45f9687181b4fdfc625bd1a753fa7397fed753547f11ca8696646f2f3acb08e31016afac23e630c5d11f59f61fef57b0d2aa5))) // [NOTE]: An input data of 'Address' type must be cast to uint160 first. Then, it should be cast to uint256 and bytes32.
        //           .withStructInput("hospital_signature_bytes", bytes32(uint256(1)))
        //           .withStructInput("patient_name", bytes32(abi.encodePacked(string('John Doe'))))
        //           .withStructInput("treatment_date", bytes32(uint256(0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8)))
        //           .withStructInput("treatment_icd_code", bytes32(abi.encodePacked(string('ICD-10-CM: A00.0'))))
        //           .withStructInput("treatment_cpt_code", bytes32(abi.encodePacked(string('CPT: 99213'))))
        //           .withStructInput("treatment_hcpcs_code", bytes32(abi.encodePacked(string('HCPCS: G0008'))))
        //           .withStructInput("treatment_drg_code", bytes32(abi.encodePacked(string('DRG: 001'))));

        // /// @dev - Generate the proof
        // (bytes32[] memory publicInputs, bytes memory proof) = noirHelper.generateProof("test_wrongProof", 6);
        // console.logBytes32(publicInputs[0]); // [Log]: 0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629
        // console.logBytes32(publicInputs[1]); // [Log]: 0x26df0d347e961cb94e1cc6d2ad8558696de8c1964b30e26f2ec8b926cbbbf862
        // console.logBytes32(publicInputs[2]); // [Log]: 0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0
        // console.logBytes32(publicInputs[3]); // [Log]: 
        // console.logBytes32(publicInputs[4]); // [Log]: 
        // console.logBytes32(publicInputs[5]); // [Log]: 

        // /// @dev - Create a fake public input, which should fail because the public input is wrong
        // bytes32[] memory fakePublicInputs = new bytes32[](2);
        // fakePublicInputs[0] = publicInputs[0];
        // fakePublicInputs[1] = bytes32(uint256(0xddddd));  // @dev - This is wrong publicInput ("nulifieir")

        // /// @dev - Verify the proof, which should be reverted
        // vm.expectRevert();
        // insuranceClaimProofVerifier.verifyInsuranceClaimProof(proof, fakePublicInputs);
    }

    // function test_all() public {
    //     // forge runs tests in parallel which messes with the read/writes to the proof file
    //     // Run tests in wrapper to force them run sequentially
    //     verifyProof();
    //     wrongProof();
    // }

}