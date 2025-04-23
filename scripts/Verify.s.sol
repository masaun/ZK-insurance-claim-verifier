pragma solidity ^0.8.17;

import { Script } from "forge-std/Script.sol";
import "forge-std/console.sol";

import { UltraVerifier } from "../contracts/circuit/ultra-verifier/plonk_vk.sol";
//import "../circuits/target/contract.sol";
import { InsuranceClaimProofVerifier } from "../contracts/circuit/InsuranceClaimProofVerifier.sol";
import { ProofConverter } from "./utils/ProofConverter.sol";

import { DataTypeConverter } from "../../contracts/libraries/DataTypeConverter.sol";


contract VerifyScript is Script {
    InsuranceClaimProofVerifier public insuranceClaimProofVerifier;
    UltraVerifier public verifier;

    struct PublicInputs {
        bytes32 merkleRoot; // root
        bytes32 nullifier;    
        bytes32 nullifierInRevealedDataStruct, // Same with the "nullifier"
        bool is_bill_signed;
        bool is_bill_amount_exceed_threshold;
        bool is_policy_valid;
    }

    // struct Poseidon2HashAndPublicInputs {
    //     string hash; // Poseidon Hash of "nullifier"
    //     bytes32 merkleRoot;
    //     bytes32 nullifier;
    //     bytes32 nftMetadataCidHash;
    // }

    function setUp() public {}

    function run() public returns (bool) {
        verifier = new UltraVerifier();
        insuranceClaimProofVerifier = new InsuranceClaimProofVerifier(verifier);


        // @dev - [TEST]: Extract the public key and signed message from the output.json file
        extractPubkeyAndSignedMessage();


        // @dev - Retrieve the Poseidon2 hash and public inputs, which was read from the output.json file
        Poseidon2HashAndPublicInputs memory poseidon2HashAndPublicInputs = computePoseidon2Hash();
        bytes32 merkleRoot = poseidon2HashAndPublicInputs.merkleRoot;
        bytes32 nullifierHash = poseidon2HashAndPublicInputs.nullifier;
        bytes32 nftMetadataCidHash = poseidon2HashAndPublicInputs.nftMetadataCidHash;
        console.logBytes32(merkleRoot);          // [Log]: 0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629
        console.logBytes32(nullifierHash);       // [Log]: 0x26df0d347e961cb94e1cc6d2ad8558696de8c1964b30e26f2ec8b926cbbbf862
        console.logBytes32(nftMetadataCidHash);  // [Log]: 0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0

        bytes memory proof_w_inputs = vm.readFileBinary("./circuits/target/insurance_claim_proof.bin");
        bytes memory proofBytes = ProofConverter.sliceAfter96Bytes(proof_w_inputs);    /// @dev - In case of that there are 3 public inputs (bytes32 * 3 = 96 bytes), the proof file includes 64 bytes of the public inputs at the beginning. Hence it should be removed by using this function.
        //bytes memory proofBytes = ProofConverter.sliceAfter64Bytes(proof_w_inputs);  /// @dev - In case of that there are 2 public inputs (bytes32 * 2 = 64 bytes), the proof file includes 64 bytes of the public inputs at the beginning. Hence it should be removed by using this function.

        // string memory proof = vm.readLine("./circuits/target/ip_nft_ownership_proof.bin");
        // bytes memory proofBytes = vm.parseBytes(proof);

        bytes32[] memory correctPublicInputs = new bytes32[](3);
        correctPublicInputs[0] = merkleRoot;
        correctPublicInputs[1] = nullifierHash;
        correctPublicInputs[2] = nftMetadataCidHash;
    
        bool isValidProof = insuranceClaimProofVerifier.verifyInsuranceClaimProof(proofBytes, correctPublicInputs);
        require(isValidProof == true, "isValidProof should be true");
        console.logBool(isValidProof); // [Log]: true
        return isValidProof;
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



        // string memory _insurer_pubkey_bytes = vm.parseJsonString(json, ".insurer_pubkey_bytes");
        // bytes32 _insurer_signature_bytes = vm.parseJsonBytes32(json, ".insurer_signature_bytes");
        // bytes32 _hospital_pubkey_bytes = vm.parseJsonBytes32(json, ".hospital_pubkey_bytes");
        // bytes32 _hospital_signature_bytes = vm.parseJsonBytes32(json, ".hospital_signature_bytes");
        // console.logString(_insurer_pubkey_bytes);
        // console.logBytes32(_insurer_signature_bytes);
        // console.logBytes32(_hospital_pubkey_bytes);
        // console.logBytes32(_hospital_signature_bytes);
    }



    /**
     * @dev - Compute Poseidon2 hash
     */
    function computePoseidon2Hash() public returns (Poseidon2HashAndPublicInputs memory _poseidon2HashAndPublicInputs) {
        /// @dev - Run the Poseidon2 hash generator script
        string[] memory ffi_commands_for_generating_poseidon2_hash = new string[](2);
        ffi_commands_for_generating_poseidon2_hash[0] = "sh";
        ffi_commands_for_generating_poseidon2_hash[1] = "scripts/utils/poseidon2-hash-generator/usages/async/runningScript_poseidon2HashGeneratorWithAsync.sh";
        bytes memory commandResponse = vm.ffi(ffi_commands_for_generating_poseidon2_hash);
        console.log(string(commandResponse));

        /// @dev - Write the output.json of the Poseidon2 hash-generated and Read the 'hash' field from the output.json
        string[] memory ffi_commands_for_generating_output_json = new string[](3);
        ffi_commands_for_generating_output_json[0] = "sh";
        ffi_commands_for_generating_output_json[1] = "-c";
        ffi_commands_for_generating_output_json[2] = "cat scripts/utils/poseidon2-hash-generator/usages/async/output/output.json | grep 'hash' | awk -F '\"' '{print $4}'"; // Extracts the 'hash' field

        bytes memory poseidon2HashBytes = vm.ffi(ffi_commands_for_generating_output_json);
        //console.logBytes(poseidon2HashBytes);

        /// @dev - Read the output.json file and parse the JSON data
        string memory json = vm.readFile("scripts/utils/poseidon2-hash-generator/usages/async/output/output.json");
        console.log(json);
        bytes memory data = vm.parseJson(json);
        //console.logBytes(data);

        string memory _hash = vm.parseJsonString(json, ".hash");
        bytes32 _merkleRoot = vm.parseJsonBytes32(json, ".merkleRoot");
        bytes32 _nullifier = vm.parseJsonBytes32(json, ".nullifier");
        bytes32 _nftMetadataCidHash = vm.parseJsonBytes32(json, ".nftMetadataCidHash");
        console.logString(_hash);
        console.logBytes32(_merkleRoot);
        console.logBytes32(_nullifier);
        console.logBytes32(_nftMetadataCidHash);

        Poseidon2HashAndPublicInputs memory poseidon2HashAndPublicInputs = Poseidon2HashAndPublicInputs({
            hash: _hash,
            merkleRoot: _merkleRoot,
            nullifier: _nullifier,
            nftMetadataCidHash: _nftMetadataCidHash
        });
        // console.logString(poseidon2HashAndPublicInputs.hash);
        // console.logBytes32(poseidon2HashAndPublicInputs.merkleRoot);
        // console.logBytes32(poseidon2HashAndPublicInputs.nullifier);
        // console.logBytes32(poseidon2HashAndPublicInputs.nftMetadataCidHash);

        return poseidon2HashAndPublicInputs;
    }

}

