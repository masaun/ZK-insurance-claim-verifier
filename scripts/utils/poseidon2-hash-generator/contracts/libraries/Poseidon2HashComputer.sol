pragma solidity ^0.8.17;

import { Script } from "forge-std/Script.sol";
import "forge-std/console.sol";

/**
 * @title Poseidon2HashComputer contract
 */
contract Poseidon2HashComputer is Script {

    struct Poseidon2HashAndPublicInputs {
        string hash; // Poseidon Hash of "nullifier"
        bytes32 merkleRoot;
        bytes32 nullifier;
        bytes32 nftMetadataCidHash;
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