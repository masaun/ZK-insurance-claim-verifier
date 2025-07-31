pragma solidity ^0.8.17;

import "forge-std/Script.sol";

/// @dev - ZK (Ultraplonk) circuit, which is generated in Noir.
import { UltraVerifier } from "../../../contracts/circuit/ultra-verifier/plonk_vk.sol"; /// @dev - Deployed-Verifier SC, which was generated based on the main.nr

/**
 * @notice - Deployment script to deploy all SCs at once - on BASE Mainnet
 */
contract DeploymentForHonkVerifier_basescan is Script {
    UltraVerifier public verifier;

    function setUp() public {}

    function run() public {

        vm.createSelectFork("https://mainnet.base.org"); // @dev - [NOTE]: Hardcoded the Base Mainnet RPC URL - Instead of using the environment variable via the foundry.toml
        //vm.createSelectFork('base-mainnet');
        
        uint256 deployerPrivateKey = vm.envUint("BASE_MAINNET_PRIVATE_KEY");
        //uint256 deployerPrivateKey = vm.envUint("LOCALHOST_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        //vm.startBroadcast();

        /// @dev - Deploy SCs
        //verifier = UltraVerifier(vm.envAddress("ULTRA_VERIFIER_ON_BASE_MAINNET"));
        verifier = new UltraVerifier();

        vm.stopBroadcast();

        /// @dev - Logs of the deployed-contracts on Base Mainnet
        console.logString("Logs of the deployed-contracts on Base Mainnet");
        console.logString("\n");
        console.log("%s: %s", "UltraVerifier SC", address(verifier));
    }
}