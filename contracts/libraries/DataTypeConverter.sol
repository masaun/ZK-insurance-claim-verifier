pragma solidity ^0.8.17;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

import "forge-std/console.sol";

/**
 * @title DataTypeConverter library
 */
library DataTypeConverter {

    /// @notice - Convert string to hash (sha256)
    function stringToHash(string memory _message) public view returns (bytes32 _messageHash) {
        bytes memory _messageBytes = abi.encodePacked(_message);
        bytes32 messageHash = sha256(_messageBytes);
        return messageHash;
    }

    /// @notice - Convert uint32 to hash (sha256)
    function uint32ToHash(uint32 _message) public view returns (bytes32 _messageHash) {
        bytes memory _messageBytes = abi.encodePacked(Strings.toString(_message));
        bytes32 messageHash = sha256(_messageBytes);
        return messageHash;
    }

    /// @notice - Convert bytes to bytes32
    function bytesToBytes32(bytes memory data) internal pure returns (bytes32 result) {
        //console.logBytes(data);
        return bytes32(data);
    }

    /// @notice - Convert bytes32 to String
    function bytes32ToString(bytes32 _bytes32) public pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (uint8 j = 0; j < i; j++) {
            bytesArray[j] = _bytes32[j];
        }
        return string(bytesArray);
    }

    /// @notice - Convert string to bytes32
    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        bytes memory tempBytes = bytes(source);
        if (tempBytes.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
}