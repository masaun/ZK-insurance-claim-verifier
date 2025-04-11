pragma solidity ^0.8.17;

import { Script } from "forge-std/Script.sol";
import { UltraVerifier } from "../contracts/circuit/ultra-verifier/plonk_vk.sol";
//import "../circuits/target/contract.sol";
import { Starter } from "../contracts/circuit/Starter.sol";
import { ProofConverter } from "./utils/ProofConverter.sol";


contract VerifyScript is Script {
    Starter public starter;
    UltraVerifier public verifier;

    function setUp() public {}

    function run() public returns (bool) {
        //uint256 deployerPrivateKey = vm.envUint("LOCALHOST_PRIVATE_KEY");
        //vm.startBroadcast(deployerPrivateKey);

        verifier = new UltraVerifier();
        starter = new Starter(verifier);

        bytes memory proof_w_inputs = vm.readFileBinary("./circuits/target/with_foundry_proof.bin");
        bytes memory proofBytes = ProofConverter.sliceAfter64Bytes(proof_w_inputs);  /// @dev - In case of that there are 2 public inputs (bytes32 * 2 = 64 bytes), the proof file includes 64 bytes of the public inputs at the beginning. Hence it should be removed by using this function.

        // string memory proof = vm.readLine("./circuits/target/with_foundry_proof.bin");
        // bytes memory proofBytes = vm.parseBytes(proof);

        bytes32[] memory correct = new bytes32[](2);
        correct[0] = bytes32(0x0000000000000000000000000000000000000000000000000000000000000003);
        correct[1] = correct[0];

        bool equal = starter.verifyEqual(proofBytes, correct);
        return equal;
    }
}
