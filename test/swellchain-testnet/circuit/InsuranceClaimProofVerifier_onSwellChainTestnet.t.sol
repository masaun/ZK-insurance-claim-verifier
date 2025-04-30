pragma solidity ^0.8.17;

import { UltraVerifier } from "../../../contracts/circuit/ultra-verifier/plonk_vk.sol";
import { InsuranceClaimProofVerifier } from "../../../contracts/circuit/InsuranceClaimProofVerifier.sol";
//import "../circuits/target/contract.sol";
import { DataTypeConverter } from "../../../contracts/libraries/DataTypeConverter.sol";

import "forge-std/console.sol";
import { Test } from "forge-std/Test.sol";
import { NoirHelper } from "foundry-noir-helper/NoirHelper.sol";

/// @dev - Import the PubkeyAndSignedMessageExtractor.sol from the scripts/utils/array-bytes-generator directory
import { PubkeyAndSignedMessageExtractor } from "../../../scripts/utils/array-bytes-generator/contracts/libraries/PubkeyAndSignedMessageExtractor.sol";


/**
 * @title - The test of the InsuranceClaimProofVerifier contract on Swell Chain Testnet
 */
contract InsuranceClaimProofVerifierTest_OnSwellChainTestnet is Test, PubkeyAndSignedMessageExtractor {
    InsuranceClaimProofVerifier public insuranceClaimProofVerifier;
    UltraVerifier public verifier;
    NoirHelper public noirHelper;

    function setUp() public {
        noirHelper = new NoirHelper();

        /// @dev - Read the each deployed address from the configuration file.
        address ULTRAVERIFER = vm.envAddress("ULTRAVERIFER_ON_SWELL_CHAIN_TESTNET");
        address INSURANCE_CLAIM_PROOF_VERIFIER = vm.envAddress("INSURANCE_CLAIM_PROOF_VERIFIER_ON_SWELL_CHAIN_TESTNET");

        /// @dev - Create the SC instances /w deployed SC addresses
        verifier = UltraVerifier(ULTRAVERIFER);
        insuranceClaimProofVerifier = InsuranceClaimProofVerifier(INSURANCE_CLAIM_PROOF_VERIFIER);
        //verifier = new UltraVerifier();
        //insuranceClaimProofVerifier = new InsuranceClaimProofVerifier(verifier);
    }

    function test_verifyProof() public {

        // uint8[] memory insurer_pubkey_bytes = new uint8[](64);
        // uint8[] memory insurer_signature_bytes = new uint8[](64);
        // uint8[] memory hospital_pubkey_bytes = new uint8[](64);
        // uint8[] memory hospital_signature_bytes = new uint8[](64);
        uint256[] memory insurer_pubkey_bytes = new uint256[](64);
        uint256[] memory insurer_signature_bytes = new uint256[](64);
        uint256[] memory hospital_pubkey_bytes = new uint256[](64);
        uint256[] memory hospital_signature_bytes = new uint256[](64);

        /// @dev - [TEST]: Extract the public key and signed message from the output.json file
        /// [🟣Key Point]: bytes64 array value should be directly stored into the "uint256[]" array variable like this:
        PubkeyAndSignedMessage memory pubkeyAndSignedMessage = extractPubkeyAndSignedMessage();
        //insurer_pubkey_bytes = pubkeyAndSignedMessage.insurer_pubkey_bytes;
        //insurer_signature_bytes = pubkeyAndSignedMessage.insurer_signature_bytes;
        //hospital_pubkey_bytes = pubkeyAndSignedMessage.hospital_pubkey_bytes;
        //hospital_signature_bytes = pubkeyAndSignedMessage.hospital_signature_bytes;
        for (uint256 i = 0; i < 64; i++) {
            insurer_pubkey_bytes[i] = [
                131,  24,  83,  91,  84,  16, 93,  74, 122, 174,  96,
                192, 143, 196,  95, 150, 135, 24,  27,  79, 223, 198,
                37, 189,  26, 117,  63, 167, 57, 127, 237, 117,  53,
                71, 241,  28, 168, 105, 102, 70, 242, 243, 172, 176,
                142,  49,   1, 106, 250, 194, 62,  99,  12, 93,  17,
                245, 159,  97, 254, 245, 123, 13,  42, 165
            ][i];
        }
        for (uint256 i = 0; i < 64; i++) {
            insurer_signature_bytes[i] = [
                1,  83,  82, 167, 184,  77, 226, 104,   5,  27, 151,
                91, 202, 127,  17, 183,  75,  31, 190, 253, 159, 116,
                155,  13,  24, 178,  40, 165, 129,  90, 103, 204,  42,
                164, 230,  62,  73, 181, 169,  61, 251, 221, 128, 221,
                14,  19, 179,  25, 107, 132,  10, 188, 149,   0, 197,
                52, 151, 239, 244, 103, 215, 224,  56, 242
            ][i];
        }
        for (uint256 i = 0; i < 64; i++) {
            hospital_pubkey_bytes[i] = [
                131,  24,  83,  91,  84,  16, 93,  74, 122, 174,  96,
                192, 143, 196,  95, 150, 135, 24,  27,  79, 223, 198,
                37, 189,  26, 117,  63, 167, 57, 127, 237, 117,  53,
                71, 241,  28, 168, 105, 102, 70, 242, 243, 172, 176,
                142,  49,   1, 106, 250, 194, 62,  99,  12,  93,  17,
                245, 159,  97, 254, 245, 123, 13,  42, 165
            ][i];
        }
        for (uint256 i = 0; i < 64; i++) {
            hospital_signature_bytes[i] = [
                1,  83,  82, 167, 184,  77, 226, 104,   5,  27, 151,
                91, 202, 127,  17, 183,  75,  31, 190, 253, 159, 116,
                155,  13,  24, 178,  40, 165, 129,  90, 103, 204,  42,
                164, 230,  62,  73, 181, 169,  61, 251, 221, 128, 221,
                14,  19, 179,  25, 107, 132,  10, 188, 149,   0, 197,
                52, 151, 239, 244, 103, 215, 224,  56, 242
            ][i];
        }

        /// @dev - [TEST]: Convert a bytes32 value to an uint8 array bytes.
        //uint8[] memory hospital_bill_hash_bytes = new uint8[](32);
        uint256[] memory hospital_bill_hash_bytes = new uint256[](32);
        for (uint256 i = 0; i < 32; i++) {
            hospital_bill_hash_bytes[i] = [
                3,  57, 199, 96, 145,  58, 183, 241,
                206, 140,  36, 34, 165, 163,  17, 210,
                97, 254, 154, 79,  91, 223, 149,  18,
                3, 210, 111, 56, 246, 219,  19, 104
            ][i];
        }

        //console.logUint(_hospital_bill_hash_bytes_uint8array[0]);

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
                  .withStructInput("patient_name", bytes32(uint256(0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8)))
                  //.withStructInput("patient_name", bytes32(DataTypeConverter.bytesToUint256(abi.encodePacked(string('John Doe')))))
                  .withStructInput("start_date", bytes32(uint256(1690982400))) // [NOTE]: 2023-08-01
                  .withStructInput("end_date", bytes32(uint256(1690982600)))   // [NOTE]: 2023-08-01
                  .withStructInput("minimum_threshold_of_bill_amount", bytes32(uint256(1000)))
                  .withStructInput("treatment_icd_code", bytes32(uint256(0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8)))
                  .withStructInput("treatment_cpt_code", bytes32(uint256(0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77)))
                  .withStructInput("treatment_hcpcs_code", bytes32(uint256(0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8)))
                  .withStructInput("treatment_drg_code", bytes32(uint256(0x2658c0d82f9c0728e055fd8272568260ed2d5117a0ed2e1935f737c528ef3505)))
                  //.withStructInput("treatment_icd_code", bytes32(DataTypeConverter.bytesToUint256(abi.encodePacked(string('ICD-10-CM: A00.0')))))
                  //.withStructInput("treatment_cpt_code", bytes32(DataTypeConverter.bytesToUint256(abi.encodePacked(string('CPT: 99213')))))
                  //.withStructInput("treatment_hcpcs_code", bytes32(DataTypeConverter.bytesToUint256(abi.encodePacked(string('HCPCS: G0008')))))
                  //.withStructInput("treatment_drg_code", bytes32(DataTypeConverter.bytesToUint256(abi.encodePacked(string('DRG: 001')))))

                  // @dev - The HospitalBillData struct
                  .withStruct("hospital_bill_data")
                  .withStructInput("hospital_bill_hash_bytes", hospital_bill_hash_bytes)
                  .withStructInput("hospital_bill_amount", bytes32(uint256(1000)))
                  .withStructInput("hospital_pubkey_bytes", hospital_pubkey_bytes) // [NOTE]: An input data of 'Address' type must be cast to uint160 first. Then, it should be cast to uint256 and bytes32.
                  .withStructInput("hospital_signature_bytes", hospital_signature_bytes)
                  .withStructInput("patient_name", bytes32(uint256(0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8)))
                  .withStructInput("treatment_date", bytes32(uint256(1690982500))) // [NOTE]: 2023-08-01
                  .withStructInput("treatment_icd_code", bytes32(uint256(0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8)))
                  .withStructInput("treatment_cpt_code", bytes32(uint256(0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77)))
                  .withStructInput("treatment_hcpcs_code", bytes32(uint256(0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8)))
                  .withStructInput("treatment_drg_code", bytes32(uint256(0x2658c0d82f9c0728e055fd8272568260ed2d5117a0ed2e1935f737c528ef3505)));
                  //.withStructInput("treatment_icd_code", bytes32(DataTypeConverter.bytesToUint256(abi.encodePacked(string('ICD-10-CM: A00.0')))))
                  //.withStructInput("treatment_cpt_code", bytes32(DataTypeConverter.bytesToUint256(abi.encodePacked(string('CPT: 99213')))))
                  //.withStructInput("treatment_hcpcs_code", bytes32(DataTypeConverter.bytesToUint256(abi.encodePacked(string('HCPCS: G0008')))))
                  //.withStructInput("treatment_drg_code", bytes32(DataTypeConverter.bytesToUint256(abi.encodePacked(string('DRG: 001')))));

        /// @dev - Generate the proof
        (bytes32[] memory publicInputs, bytes memory proof) = noirHelper.generateProof("test_verifyProof", 6); // [NOTE]: The number of public inputs is '3'.
        console.logBytes32(publicInputs[0]); // [Log]: 0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629
        console.logBytes32(publicInputs[1]); // [Log]: 0x26df0d347e961cb94e1cc6d2ad8558696de8c1964b30e26f2ec8b926cbbbf862
        console.logBytes32(publicInputs[2]); // [Log]: 0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0
        console.logBytes32(publicInputs[3]); // [Log]: 
        console.logBytes32(publicInputs[4]); // [Log]: 

        /// @dev - Verify the proof
        insuranceClaimProofVerifier.verifyInsuranceClaimProof(proof, publicInputs);
    }

    /**
     * @notice - Should be reverted if the proof is invalid
     */
    function test_wrongProof() public {
        noirHelper.clean();

        // // uint8[] memory insurer_pubkey_bytes = new uint8[](64);
        // // uint8[] memory insurer_signature_bytes = new uint8[](64);
        // // uint8[] memory hospital_pubkey_bytes = new uint8[](64);
        // // uint8[] memory hospital_signature_bytes = new uint8[](64);
        // uint256[] memory insurer_pubkey_bytes = new uint256[](64);
        // uint256[] memory insurer_signature_bytes = new uint256[](64);
        // uint256[] memory hospital_pubkey_bytes = new uint256[](64);
        // uint256[] memory hospital_signature_bytes = new uint256[](64);

        // /// @dev - [TEST]: Extract the public key and signed message from the output.json file
        // /// [🟣Key Point]: bytes64 array value should be directly stored into the "uint256[]" array variable like this:
        // PubkeyAndSignedMessage memory pubkeyAndSignedMessage = extractPubkeyAndSignedMessage();
        // //insurer_pubkey_bytes = pubkeyAndSignedMessage.insurer_pubkey_bytes;
        // //insurer_signature_bytes = pubkeyAndSignedMessage.insurer_signature_bytes;
        // //hospital_pubkey_bytes = pubkeyAndSignedMessage.hospital_pubkey_bytes;
        // //hospital_signature_bytes = pubkeyAndSignedMessage.hospital_signature_bytes;
        // for (uint256 i = 0; i < 64; i++) {
        //     insurer_pubkey_bytes[i] = [
        //         131,  24,  83,  91,  84,  16, 93,  74, 122, 174,  96,
        //         192, 143, 196,  95, 150, 135, 24,  27,  79, 223, 198,
        //         37, 189,  26, 117,  63, 167, 57, 127, 237, 117,  53,
        //         71, 241,  28, 168, 105, 102, 70, 242, 243, 172, 176,
        //         142,  49,   1, 106, 250, 194, 62,  99,  12, 93,  17,
        //         245, 159,  97, 254, 245, 123, 13,  42, 165
        //     ][i];
        // }
        // for (uint256 i = 0; i < 64; i++) {
        //     insurer_signature_bytes[i] = [
        //         1,  83,  82, 167, 184,  77, 226, 104,   5,  27, 151,
        //         91, 202, 127,  17, 183,  75,  31, 190, 253, 159, 116,
        //         155,  13,  24, 178,  40, 165, 129,  90, 103, 204,  42,
        //         164, 230,  62,  73, 181, 169,  61, 251, 221, 128, 221,
        //         14,  19, 179,  25, 107, 132,  10, 188, 149,   0, 197,
        //         52, 151, 239, 244, 103, 215, 224,  56, 242
        //     ][i];
        // }
        // for (uint256 i = 0; i < 64; i++) {
        //     hospital_pubkey_bytes[i] = [
        //         131,  24,  83,  91,  84,  16, 93,  74, 122, 174,  96,
        //         192, 143, 196,  95, 150, 135, 24,  27,  79, 223, 198,
        //         37, 189,  26, 117,  63, 167, 57, 127, 237, 117,  53,
        //         71, 241,  28, 168, 105, 102, 70, 242, 243, 172, 176,
        //         142,  49,   1, 106, 250, 194, 62,  99,  12,  93,  17,
        //         245, 159,  97, 254, 245, 123, 13,  42, 165
        //     ][i];
        // }
        // for (uint256 i = 0; i < 64; i++) {
        //     hospital_signature_bytes[i] = [
        //         1,  83,  82, 167, 184,  77, 226, 104,   5,  27, 151,
        //         91, 202, 127,  17, 183,  75,  31, 190, 253, 159, 116,
        //         155,  13,  24, 178,  40, 165, 129,  90, 103, 204,  42,
        //         164, 230,  62,  73, 181, 169,  61, 251, 221, 128, 221,
        //         14,  19, 179,  25, 107, 132,  10, 188, 149,   0, 197,
        //         52, 151, 239, 244, 103, 215, 224,  56, 242
        //     ][i];
        // }

        // /// @dev - [TEST]: Convert a bytes32 value to an uint8 array bytes.
        // //uint8[] memory hospital_bill_hash_bytes = new uint8[](32);
        // uint256[] memory hospital_bill_hash_bytes = new uint256[](32);
        // for (uint256 i = 0; i < 32; i++) {
        //     hospital_bill_hash_bytes[i] = [
        //         3,  57, 199, 96, 145,  58, 183, 241,
        //         206, 140,  36, 34, 165, 163,  17, 210,
        //         97, 254, 154, 79,  91, 223, 149,  18,
        //         3, 210, 111, 56, 246, 219,  19, 104
        //     ][i];
        // }

        // //console.logUint(_hospital_bill_hash_bytes_uint8array[0]);

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
                  
        //           // @dev - The InsurancePolicyData struct
        //           .withStruct("insurance_policy_data")
        //           .withStructInput("insurer_pubkey_bytes", insurer_pubkey_bytes) // [NOTE]: An input data of 'Address' type must be cast to uint160 first. Then, it should be cast to uint256 and bytes32.
        //           .withStructInput("insurer_signature_bytes", insurer_signature_bytes)
        //           .withStructInput("patient_name", bytes32(uint256(0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8)))
        //           //.withStructInput("patient_name", bytes32(DataTypeConverter.bytesToUint256(abi.encodePacked(string('John Doe')))))
        //           .withStructInput("start_date", bytes32(uint256(1690982400))) // [NOTE]: 2023-08-01
        //           .withStructInput("end_date", bytes32(uint256(1690982600)))   // [NOTE]: 2023-08-01
        //           .withStructInput("minimum_threshold_of_bill_amount", bytes32(uint256(1000)))
        //           .withStructInput("treatment_icd_code", bytes32(uint256(0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8)))
        //           .withStructInput("treatment_cpt_code", bytes32(uint256(0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77)))
        //           .withStructInput("treatment_hcpcs_code", bytes32(uint256(0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8)))
        //           .withStructInput("treatment_drg_code", bytes32(uint256(0x2658c0d82f9c0728e055fd8272568260ed2d5117a0ed2e1935f737c528ef3505)))
        //           //.withStructInput("treatment_icd_code", bytes32(DataTypeConverter.bytesToUint256(abi.encodePacked(string('ICD-10-CM: A00.0')))))
        //           //.withStructInput("treatment_cpt_code", bytes32(DataTypeConverter.bytesToUint256(abi.encodePacked(string('CPT: 99213')))))
        //           //.withStructInput("treatment_hcpcs_code", bytes32(DataTypeConverter.bytesToUint256(abi.encodePacked(string('HCPCS: G0008')))))
        //           //.withStructInput("treatment_drg_code", bytes32(DataTypeConverter.bytesToUint256(abi.encodePacked(string('DRG: 001')))))

        //           // @dev - The HospitalBillData struct
        //           .withStruct("hospital_bill_data")
        //           .withStructInput("hospital_bill_hash_bytes", hospital_bill_hash_bytes)
        //           .withStructInput("hospital_bill_amount", bytes32(uint256(1000)))
        //           .withStructInput("hospital_pubkey_bytes", hospital_pubkey_bytes) // [NOTE]: An input data of 'Address' type must be cast to uint160 first. Then, it should be cast to uint256 and bytes32.
        //           .withStructInput("hospital_signature_bytes", hospital_signature_bytes)
        //           .withStructInput("patient_name", bytes32(uint256(0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8)))
        //           .withStructInput("treatment_date", bytes32(uint256(1690982500))) // [NOTE]: 2023-08-01
        //           .withStructInput("treatment_icd_code", bytes32(uint256(0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8)))
        //           .withStructInput("treatment_cpt_code", bytes32(uint256(0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77)))
        //           .withStructInput("treatment_hcpcs_code", bytes32(uint256(0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8)))
        //           .withStructInput("treatment_drg_code", bytes32(uint256(0x2658c0d82f9c0728e055fd8272568260ed2d5117a0ed2e1935f737c528ef3505)));
        //           //.withStructInput("treatment_icd_code", bytes32(DataTypeConverter.bytesToUint256(abi.encodePacked(string('ICD-10-CM: A00.0')))))
        //           //.withStructInput("treatment_cpt_code", bytes32(DataTypeConverter.bytesToUint256(abi.encodePacked(string('CPT: 99213')))))
        //           //.withStructInput("treatment_hcpcs_code", bytes32(DataTypeConverter.bytesToUint256(abi.encodePacked(string('HCPCS: G0008')))))
        //           //.withStructInput("treatment_drg_code", bytes32(DataTypeConverter.bytesToUint256(abi.encodePacked(string('DRG: 001')))));

        // /// @dev - Generate the proof
        // (bytes32[] memory publicInputs, bytes memory proof) = noirHelper.generateProof("test_verifyProof", 6); // [NOTE]: The number of public inputs is '3'.
        // console.logBytes32(publicInputs[0]); // [Log]: 0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629
        // console.logBytes32(publicInputs[1]); // [Log]: 0x2658c0d82f9c0728e055fd8272568260ed2d5117a0ed2e1935f737c528ef3505
        // console.logBytes32(publicInputs[2]); // [Log]: 0x2658c0d82f9c0728e055fd8272568260ed2d5117a0ed2e1935f737c528ef3505
        // console.logBytes32(publicInputs[3]); // [Log]: 0x0000000000000000000000000000000000000000000000000000000000000001
        // console.logBytes32(publicInputs[4]); // [Log]: 0x0000000000000000000000000000000000000000000000000000000000000001

        // /// @dev - Create a fake public input, which should fail because the public input is wrong
        // bytes32[] memory fakePublicInputs = new bytes32[](5);
        // fakePublicInputs[0] = publicInputs[0];
        // fakePublicInputs[1] = bytes32(uint256(0xddddd));  // @dev - This is wrong publicInput ("nulifieir")
        // fakePublicInputs[2] = publicInputs[2];
        // fakePublicInputs[3] = publicInputs[3];
        // fakePublicInputs[4] = publicInputs[4];

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