pragma solidity ^0.8.17;

import { Script } from "forge-std/Script.sol";
import "forge-std/console.sol";

import { UltraVerifier } from "../contracts/circuit/ultra-verifier/plonk_vk.sol";
//import "../circuits/target/contract.sol";
import { InsuranceClaimProofVerifier } from "../contracts/circuit/InsuranceClaimProofVerifier.sol";
import { ProofConverter } from "./utils/ProofConverter.sol";
import { Poseidon2HashComputer } from "./utils/poseidon2-hash-generator/contracts/libraries/Poseidon2HashComputer.sol";

import { DataTypeConverter } from "../../contracts/libraries/DataTypeConverter.sol";


contract VerifyScript is Script {
    InsuranceClaimProofVerifier public insuranceClaimProofVerifier;
    UltraVerifier public verifier;

    struct PublicInputs {
        bytes32 merkle_root; // root
        bytes32 nullifier;    
        bytes32 nullifier_in_revealed_data_struct; // Same with the "nullifier"
        bytes32 is_bill_signed;                    // "0": False <-> "1": True
        bytes32 is_bill_amount_exceed_threshold;   // "0": False <-> "1": True
        bytes32 is_policy_valid;                   // "0": False <-> "1": True
    }

    function setUp() public {}

    function run() public returns (bool) {
        verifier = new UltraVerifier();
        insuranceClaimProofVerifier = new InsuranceClaimProofVerifier(verifier);



        // @dev - [TEST]: Extract the public key and signed message from the output.json file
        extractPubkeyAndSignedMessage();

        // @dev - Retrieve the Poseidon2 hash and public inputs, which was read from the output.json file
        PublicInputs memory publicInputs = getPublicInputs();
        bytes32 merkle_root = publicInputs.merkle_root;
        bytes32 nullifier = publicInputs.nullifier;
        bytes32 nullifier_in_revealed_data_struct = publicInputs.nullifier_in_revealed_data_struct;
        bytes32 is_bill_signed = publicInputs.is_bill_signed;
        bytes32 is_bill_amount_exceed_threshold = publicInputs.is_bill_amount_exceed_threshold;
        bytes32 is_policy_valid = publicInputs.is_policy_valid;
        console.logBytes32(merkle_root); // [Log]: 0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629
        console.logBytes32(nullifier); // [Log]: 0x26df0d347e961cb94e1cc6d2ad8558696de8c1964b30e26f2ec8b926cbbbf862
        console.logBytes32(nullifier_in_revealed_data_struct); // [Log]: 0x26df0d347e961cb94e1cc6d2ad8558696de8c1964b30e26f2ec8b926cbbbf862
        console.logBytes32(is_bill_signed); // [Log]: true
        console.logBytes32(is_bill_amount_exceed_threshold); // [Log]: true
        console.logBytes32(is_policy_valid); // [Log]: true

        bytes memory proof_w_inputs = vm.readFileBinary("./circuits/target/insurance_claim_proof.bin");
        bytes memory proofBytes = ProofConverter.sliceAfter192Bytes(proof_w_inputs);    /// @dev - In case of that there are 6 public inputs (bytes32 * 6 = 192 bytes), the proof file includes 192 bytes of the public inputs at the beginning. Hence it should be removed by using this function.
        //bytes memory proofBytes = ProofConverter.sliceAfter96Bytes(proof_w_inputs);    /// @dev - In case of that there are 3 public inputs (bytes32 * 3 = 96 bytes), the proof file includes 96 bytes of the public inputs at the beginning. Hence it should be removed by using this function.
        //bytes memory proofBytes = ProofConverter.sliceAfter64Bytes(proof_w_inputs);  /// @dev - In case of that there are 2 public inputs (bytes32 * 2 = 64 bytes), the proof file includes 64 bytes of the public inputs at the beginning. Hence it should be removed by using this function.
        console.logString("proofBytes:");
        console.logBytes(proofBytes);

        // string memory proof = vm.readLine("./circuits/target/ip_nft_ownership_proof.bin");
        // bytes memory proofBytes = vm.parseBytes(proof);

        bytes32[] memory correctPublicInputs = new bytes32[](6);
        correctPublicInputs[0] = merkle_root;
        correctPublicInputs[1] = nullifier;
        correctPublicInputs[2] = nullifier_in_revealed_data_struct;
        correctPublicInputs[3] = is_bill_signed;
        correctPublicInputs[4] = is_bill_amount_exceed_threshold;
        correctPublicInputs[5] = is_policy_valid;
        console.logString("correctPublicInputs:");
        for (uint i = 0; i < correctPublicInputs.length; i++) {
            console.log("correctPublicInputs[%s]:", i);
            console.logBytes32(correctPublicInputs[i]);
        }

        bool isValidProof = insuranceClaimProofVerifier.verifyInsuranceClaimProof(proofBytes, correctPublicInputs);
        require(isValidProof == true, "isValidProof should be true");
        console.logString("isValidProof:");
        console.logBool(isValidProof); // [Log]: true
        return isValidProof;
    }

    function getPublicInputs() public view returns (PublicInputs memory _pulicInputs) {
        /// @dev - Read the publicInputs.json file and parse the JSON data
        string memory json = vm.readFile("scripts/utils/array-bytes-generator/pubkey-and-signed-message-extractor/output/publicInputs.json");
        console.log(json);
        bytes memory data = vm.parseJson(json);

        bytes32 _merkle_root = vm.parseJsonBytes32(json, ".merkle_root");
        bytes32 _nullifier = vm.parseJsonBytes32(json, ".nullifier");
        bytes32 _nullifier_in_revealed_data_struct = vm.parseJsonBytes32(json, ".nullifier_in_revealed_data_struct");
        bytes32 _is_bill_signed = vm.parseJsonBytes32(json, ".is_bill_signed");
        bytes32 _is_bill_amount_exceed_threshold = vm.parseJsonBytes32(json, ".is_bill_amount_exceed_threshold");
        bytes32 _is_policy_valid = vm.parseJsonBytes32(json, ".is_policy_valid");
        // bytes32 _is_bill_signed = bytes32(uint256(vm.parseJsonBytes32(json, ".is_bill_signed")));
        // bytes32 _is_bill_amount_exceed_threshold = bytes32(uint256(vm.parseJsonBytes32(json, ".is_bill_amount_exceed_threshold")));
        // bytes32 _is_policy_valid = bytes32(uint256(vm.parseJsonBytes32(json, ".is_policy_valid")));
        console.logBytes32(_merkle_root);
        console.logBytes32(_nullifier);
        console.logBytes32(_nullifier_in_revealed_data_struct);
        console.logBytes32(_is_bill_signed);
        console.logBytes32(_is_bill_amount_exceed_threshold);
        console.logBytes32(_is_policy_valid);

        PublicInputs memory publicInputs = PublicInputs({
            merkle_root: _merkle_root,
            nullifier: _nullifier,
            nullifier_in_revealed_data_struct: _nullifier_in_revealed_data_struct,
            is_bill_signed: _is_bill_signed,
            is_bill_amount_exceed_threshold: _is_bill_amount_exceed_threshold,
            is_policy_valid: _is_policy_valid
        });

        return publicInputs;
    }


    /**
     * @dev - Extract the public key and signed message from the output.json file
     */
    function extractPubkeyAndSignedMessage() public returns (bool) {
        /// @dev - Run the Poseidon2 hash generator script
        string[] memory ffi_commands_for_generating_poseidon2_hash = new string[](2);
        ffi_commands_for_generating_poseidon2_hash[0] = "sh";
        ffi_commands_for_generating_poseidon2_hash[1] = "scripts/utils/array-bytes-generator/random-array-bytes-generator/runningScript_randomArrayBytesGeneratorWithEthersjs.sh";
        bytes memory commandResponse = vm.ffi(ffi_commands_for_generating_poseidon2_hash);
        console.log(string(commandResponse));

        /// @dev - Read the output.json file and parse the JSON data
        string memory json = vm.readFile("scripts/utils/array-bytes-generator/pubkey-and-signed-message-extractor/output/output.json");
        console.log(json);
        bytes memory data = vm.parseJson(json);
        //console.logBytes(data);

        /// @dev - Store a Uint8Array value, which was retrieved from the output.json, into the uint256 array variable (uint256[])
        uint256[] memory _insurer_signature_bytes = vm.parseJsonUintArray(json, ".insurer_signature_bytes");
        for (uint i = 0; i < _insurer_signature_bytes.length; i++) {
            console.log("_insurer_signature_bytes[%s] = %s", i, _insurer_signature_bytes[i]); // [Log - Success]: _insurer_signature_bytes[0] = 211, _insurer_signature_bytes[1] = 23, ...
        }

        uint256[] memory _hospital_signature_bytes = vm.parseJsonUintArray(json, ".hospital_signature_bytes");
        for (uint i = 0; i < _hospital_signature_bytes.length; i++) {
            console.log("_hospital_signature_bytes[%s] = %s", i, _hospital_signature_bytes[i]); // [Log - Success]: _hospital_signature_bytes[0] = 211, _hospital_signature_bytes[1] = 23, ...
        }

        uint256[] memory _insurer_pubkey_bytes = vm.parseJsonUintArray(json, ".insurer_pubkey_bytes");
        for (uint i = 0; i < _insurer_pubkey_bytes.length; i++) {
            console.log("_insurer_pubkey_bytes[%s] = %s", i, _insurer_pubkey_bytes[i]); // [Log - Success]: _insurer_pubkey_bytes[0] = 0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629, _insurer_pubkey_bytes[1] = 0x26df0d347e961cb94e1cc6d2ad8558696de8c1964b30e26f2ec8b926cbbbf862, ...
        }

        uint256[] memory _hospital_pubkey_bytes = vm.parseJsonUintArray(json, ".hospital_pubkey_bytes");
        for (uint i = 0; i < _hospital_pubkey_bytes.length; i++) {
            console.log("_hospital_pubkey_bytes[%s] = %s", i, _hospital_pubkey_bytes[i]); // [Log - Success]: _hospital_pubkey_bytes[0] = 0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629, _hospital_pubkey_bytes[1] = 0x26df0d347e961cb94e1cc6d2ad8558696de8c1964b30e26f2ec8b926cbbbf862, ...
        }

        // string memory _insurer_pubkey_bytes = vm.parseJsonString(json, ".insurer_pubkey_bytes");
        // bytes32 _insurer_signature_bytes = vm.parseJsonBytes32(json, ".insurer_signature_bytes");
        // bytes32 _hospital_pubkey_bytes = vm.parseJsonBytes32(json, ".hospital_pubkey_bytes");
        // bytes32 _hospital_signature_bytes = vm.parseJsonBytes32(json, ".hospital_signature_bytes");
        // console.logString(_insurer_pubkey_bytes);
        // console.logBytes32(_insurer_signature_bytes);
        // console.logBytes32(_hospital_pubkey_bytes);
        // console.logBytes32(_hospital_signature_bytes);
    }

}

