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

    /// @notice - Convert bytes to uint256
    function bytesToUint256(bytes memory b) public pure returns (uint256) {
        bytes memory _b = _ensureBytes32Length(b);
        require(_b.length == 32, "Bytes length must be exactly 32");
        return abi.decode(_b, (uint256));
    }

    /// @notice - Padding or truncating to ensure the length is 32 bytes
    function _ensureBytes32Length(bytes memory input) internal pure returns (bytes memory) {
        if (input.length == 32) {
            return input;
        } else if (input.length < 32) {
            // Pad with zeros if the input is shorter than 32 bytes
            bytes memory padded = new bytes(32);
            for (uint256 i = 0; i < input.length; i++) {
                padded[i] = input[i];
            }
            return padded;
        } else {
            // Truncate if the input is longer than 32 bytes
            bytes memory truncated = new bytes(32);
            for (uint256 i = 0; i < 32; i++) {
                truncated[i] = input[i];
            }
            return truncated;
        }
    }

    /**
     * @dev - Converts a bytes32 value to an uint8 array bytes (length is 32 bytes).
     * @dev - Target is to convert bytes32 in Solidity to [u8; 32] in Noir, which is same with uint8[] in Solidity.
     * @dev - i.e). 2 is converted to [0, 0, 0, 0, 0, 0, 0, 2]
     */
    function bytes32ToUint8Array(bytes32 input) internal pure returns (uint8[32] memory) {
        uint8[32] memory result;
        for (uint256 i = 0; i < 32; i++) {
            result[i] = uint8(input[i]);
        }
        return result;
    }

    /**
     * @dev - Converts a uint8 array bytes (length is 32 bytes) value to a bytes32 value.
     *
     * Example usage:
     *
     *   function testConversion() public pure returns (bytes32) {
     *       uint8[32] memory uint8Array = [
     *           1, 2, 3, 4, 5, 6, 7, 8,
     *           9, 10, 11, 12, 13, 14, 15, 16,
     *           17, 18, 19, 20, 21, 22, 23, 24,
     *           25, 26, 27, 28, 29, 30, 31, 32
     *       ];
     *
     *       return uint8ArrayToBytes32(uint8Array);
     *   }
     */
    function uint8ArrayToBytes32(uint8[32] memory uint8Array) internal pure returns (bytes32 result) {
        for (uint256 i = 0; i < 32; i++) {
            result |= bytes32(uint256(uint8Array[i]) & 0xFF) >> (i * 8);
        }
    }

}