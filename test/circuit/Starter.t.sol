pragma solidity ^0.8.17;

import { UltraVerifier } from "../../contracts/circuit/ultra-verifier/plonk_vk.sol";
import { Starter } from "../../contracts/circuit/Starter.sol";
//import "../circuits/target/contract.sol";
import { DataTypeConverter } from "../../contracts/libraries/DataTypeConverter.sol";

import "forge-std/console.sol";
import { Test } from "forge-std/Test.sol";
import { NoirHelper } from "foundry-noir-helper/NoirHelper.sol";


contract StarterTest is Test {
    Starter public starter;
    UltraVerifier public verifier;
    NoirHelper public noirHelper;

    function setUp() public {
        noirHelper = new NoirHelper();
        verifier = new UltraVerifier();
        starter = new Starter(verifier);
    }

    function test_verifyProof() public {
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
                  .withInput("expected_nullifier", bytes32(uint256(0x26df0d347e961cb94e1cc6d2ad8558696de8c1964b30e26f2ec8b926cbbbf862)))
                  .withInput("expected_nft_metadata_cid_hash", bytes32(uint256(0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0)))
                  .withStruct("ip_nft_data")
                  .withStructInput("nft_owner", bytes32(uint256(uint160(0xC6093Fd9cc143F9f058938868b2df2daF9A91d28)))) // [NOTE]: An input data of 'Address' type must be cast to uint160 first. Then, it should be cast to uint256 and bytes32.
                  .withStructInput("nft_token_id", bytes32(uint256(1)))
                  .withStructInput("nft_metadata_cid", string('QmYwAPJzv5CZsnAzt8auVZRn5W4mBkpLsD4HaBFN6r5y6F'));

        /// @dev - Generate the proof
        (bytes32[] memory publicInputs, bytes memory proof) = noirHelper.generateProof("test_verifyProof", 3); // [NOTE]: The number of public inputs is '3'.
        console.logBytes32(publicInputs[0]); // [Log]: 0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629
        console.logBytes32(publicInputs[1]); // [Log]: 0x26df0d347e961cb94e1cc6d2ad8558696de8c1964b30e26f2ec8b926cbbbf862
        console.logBytes32(publicInputs[2]); // [Log]: 0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0

        /// @dev - Verify the proof
        starter.verifyEqual(proof, publicInputs);
    }

    function test_wrongProof() public {
        noirHelper.clean();
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
                  .withInput("expected_nullifier", bytes32(uint256(0x26df0d347e961cb94e1cc6d2ad8558696de8c1964b30e26f2ec8b926cbbbf862)))
                  .withInput("expected_nft_metadata_cid_hash", bytes32(uint256(0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0)))
                  .withStruct("ip_nft_data")
                  .withStructInput("nft_owner", bytes32(uint256(uint160(0xC6093Fd9cc143F9f058938868b2df2daF9A91d28)))) // [NOTE]: An input data of 'Address' type must be cast to uint160 first. Then, it should be cast to uint256 and bytes32.
                  .withStructInput("nft_token_id", bytes32(uint256(1)))
                  .withStructInput("nft_metadata_cid", string('QmYwAPJzv5CZsnAzt8auVZRn5W4mBkpLsD4HaBFN6r5y6F'));

        /// @dev - Generate the proof
        (bytes32[] memory publicInputs, bytes memory proof) = noirHelper.generateProof("test_wrongProof", 3);
        console.logBytes32(publicInputs[0]); // [Log]: 0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629
        console.logBytes32(publicInputs[1]); // [Log]: 0x26df0d347e961cb94e1cc6d2ad8558696de8c1964b30e26f2ec8b926cbbbf862
        console.logBytes32(publicInputs[2]); // [Log]: 0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0

        /// @dev - Create a fake public input, which should fail because the public input is wrong
        bytes32[] memory fakePublicInputs = new bytes32[](2);
        fakePublicInputs[0] = publicInputs[0];
        fakePublicInputs[1] = bytes32(uint256(0xddddd));  // @dev - This is wrong publicInput ("nulifieir")

        /// @dev - Verify the proof, which should be reverted
        vm.expectRevert();
        starter.verifyEqual(proof, fakePublicInputs);
    }

    // function test_all() public {
    //     // forge runs tests in parallel which messes with the read/writes to the proof file
    //     // Run tests in wrapper to force them run sequentially
    //     verifyProof();
    //     wrongProof();
    // }

}