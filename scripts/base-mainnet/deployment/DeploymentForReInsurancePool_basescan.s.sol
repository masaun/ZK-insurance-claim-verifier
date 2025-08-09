pragma solidity ^0.8.17;

import "forge-std/Script.sol";

import { ReInsurancePool } from "../../../contracts/ReInsurancePool.sol";

/**
 * @notice - Deployment script to deploy all SCs at once - on BASE Mainnet
 */
contract DeploymentForReInsurancePool_basescan is Script {
    ReInsurancePool public reInsurancePool;

    function setUp() public {}

    function run() public {
        //vm.createSelectFork('base_mainnet'); // [NOTE]: foundry.toml - BASE Mainnet RPC URL

        uint256 deployerPrivateKey = vm.envUint("BASE_MAINNET_PRIVATE_KEY");
        //uint256 deployerPrivateKey = vm.envUint("LOCALHOST_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        //vm.startBroadcast();

        /// @dev - Deploy SCs
        reInsurancePool = new ReInsurancePool();

        vm.stopBroadcast();

        /// @dev - Logs of the deployed-contracts on BASE Mainnet
        console.logString("Logs of the deployed-contracts on BASE Mainnet");
        console.logString("\n");
        console.log("%s: %s", "ReInsurancePool SC", address(reInsurancePool));
    }
}