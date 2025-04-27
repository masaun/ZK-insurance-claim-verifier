pragma solidity ^0.8.17;

import { Script } from "forge-std/Script.sol";
import "forge-std/console.sol";

/**
 * @title PubkeyAndSignedMessageExtractor contract
 */
contract PubkeyAndSignedMessageExtractor is Script {

    /**
     * @dev - Struct to store the PubkeyAndSignedMessage related data (to be the bytes64 Field data)
     */
    struct PubkeyAndSignedMessage {
        uint8[] insurer_signature_bytes;
        uint8[] insurer_pubkey_bytes;
        uint8[] hospital_pubkey_bytes;
        uint8[] hospital_signature_bytes;
        // uint256[] insurer_signature_bytes;
        // uint256[] insurer_pubkey_bytes;
        // uint256[] hospital_pubkey_bytes;
        // uint256[] hospital_signature_bytes;
    }

    /**
     * @dev - Extract the public key and signed message from the output.json file
     */
    function extractPubkeyAndSignedMessage() public returns (PubkeyAndSignedMessage memory _pubkeyAndSignedMessage) {
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

        /// @dev - Define the uint256 array variables (64 bytes each)
        uint8[] memory insurer_pubkey_bytes_array = new uint8[](64);
        uint8[] memory insurer_signature_bytes_array = new uint8[](64);
        uint8[] memory hospital_pubkey_bytes_array = new uint8[](64);
        uint8[] memory hospital_signature_bytes_array = new uint8[](64);
        // uint256[] memory insurer_pubkey_bytes_array = new uint256[](64);
        // uint256[] memory insurer_signature_bytes_array = new uint256[](64);
        // uint256[] memory hospital_pubkey_bytes_array = new uint256[](64);
        // uint256[] memory hospital_signature_bytes_array = new uint256[](64);
        console.log("insurer_pubkey_bytes_array.length: %s", insurer_pubkey_bytes_array.length); // [Log]: 64

        /// @dev - Store a Uint8Array value, which was retrieved from the output.json, into the uint256 array variable (uint256[])
        //uint8[] memory _insurer_signature_bytes = vm.parseJsonUintArray(json, ".insurer_signature_bytes");
        uint256[] memory _insurer_signature_bytes = vm.parseJsonUintArray(json, ".insurer_signature_bytes");
        console.log("_insurer_signature_bytes.length: %s", _insurer_signature_bytes.length);     // [Log]: 99
        for (uint i = 0; i < _insurer_signature_bytes.length - 1; i++) {
            insurer_signature_bytes_array[i] = uint8(_insurer_signature_bytes[i]);
            //insurer_signature_bytes_array[i] = _insurer_signature_bytes[i];
            console.log("insurer_signature_bytes_array[%s] = %s", i, insurer_signature_bytes_array[i]); // [Log - Success]: _insurer_signature_bytes[0] = 211, _insurer_signature_bytes[1] = 23, ...
        }

        //uint8[] memory _hospital_signature_bytes = vm.parseJsonUintArray(json, ".hospital_signature_bytes");
        uint256[] memory _hospital_signature_bytes = vm.parseJsonUintArray(json, ".hospital_signature_bytes");
        for (uint i = 0; i < _hospital_signature_bytes.length - 1; i++) {
            hospital_signature_bytes_array[i] = uint8(_hospital_signature_bytes[i]);
            //hospital_signature_bytes_array[i] = _hospital_signature_bytes[i];
            console.log("hospital_signature_bytes_array[%s] = %s", i, hospital_signature_bytes_array[i]); // [Log - Success]: _hospital_signature_bytes[0] = 211, _hospital_signature_bytes[1] = 23, ...
        }

        //uint8[] memory _insurer_pubkey_bytes = vm.parseJsonUintArray(json, ".insurer_pubkey_bytes");
        uint256[] memory _insurer_pubkey_bytes = vm.parseJsonUintArray(json, ".insurer_pubkey_bytes");
        for (uint i = 0; i < _insurer_pubkey_bytes.length; i++) {
            insurer_pubkey_bytes_array[i] = uint8(_insurer_pubkey_bytes[i]);
            //insurer_pubkey_bytes_array[i] = _insurer_pubkey_bytes[i];
            console.log("insurer_pubkey_bytes_array[%s] = %s", i, insurer_pubkey_bytes_array[i]); // [Log - Success]: _insurer_pubkey_bytes[0] = 0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629, _insurer_pubkey_bytes[1] = 0x26df0d347e961cb94e1cc6d2ad8558696de8c1964b30e26f2ec8b926cbbbf862, ...
        }

        //uint8[] memory _hospital_pubkey_bytes = vm.parseJsonUintArray(json, ".hospital_pubkey_bytes");
        uint256[] memory _hospital_pubkey_bytes = vm.parseJsonUintArray(json, ".hospital_pubkey_bytes");
        for (uint i = 0; i < _hospital_pubkey_bytes.length - 1; i++) {
            hospital_pubkey_bytes_array[i] = uint8(_hospital_pubkey_bytes[i]);
            //hospital_pubkey_bytes_array[i] = _hospital_pubkey_bytes[i];
            console.log("hospital_signature_bytes_array[%s] = %s", i, hospital_signature_bytes_array[i]); // [Log - Success]: _hospital_pubkey_bytes[0] = 0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629, _hospital_pubkey_bytes[1] = 0x26df0d347e961cb94e1cc6d2ad8558696de8c1964b30e26f2ec8b926cbbbf862, ...
        }

        PubkeyAndSignedMessage memory pubkeyAndSignedMessage = PubkeyAndSignedMessage({
            insurer_signature_bytes: insurer_signature_bytes_array,
            insurer_pubkey_bytes: insurer_pubkey_bytes_array,
            hospital_pubkey_bytes: hospital_pubkey_bytes_array, 
            hospital_signature_bytes: hospital_signature_bytes_array
            // insurer_signature_bytes: _insurer_signature_bytes,
            // insurer_pubkey_bytes: _insurer_pubkey_bytes,
            // hospital_pubkey_bytes: _hospital_pubkey_bytes,
            // hospital_signature_bytes: _hospital_signature_bytes
        });

        return pubkeyAndSignedMessage;
    }
}