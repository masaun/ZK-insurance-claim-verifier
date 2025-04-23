pragma solidity ^0.8.17;

import { Script } from "forge-std/Script.sol";
import "forge-std/console.sol";

/**
 * @title PubkeyAndSignedMessageExtractor contract
 */
contract PubkeyAndSignedMessageExtractor is Script {
    
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