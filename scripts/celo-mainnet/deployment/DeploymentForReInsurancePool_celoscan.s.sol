pragma solidity ^0.8.17;

import "forge-std/Script.sol";

import { ReInsurancePool } from "../../../contracts/ReInsurancePool.sol";

/**
 * @notice - Deployment script to deploy all SCs at once - on CELO Mainnet
 */
contract DeploymentForReInsurancePool_celoscan is Script {
    ReInsurancePool public reInsurancePool;

    function setUp() public {}

    function run() public {
        //vm.createSelectFork('base_mainnet'); // [NOTE]: foundry.toml - CELO Mainnet RPC URL

        uint256 deployerPrivateKey = vm.envUint("CELO_MAINNET_PRIVATE_KEY");
        //uint256 deployerPrivateKey = vm.envUint("LOCALHOST_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        //vm.startBroadcast();

        /// @dev - Deploy SCs
        reInsurancePool = new ReInsurancePool();

        vm.stopBroadcast();

        /// @dev - Logs of the deployed-contracts on CELO Mainnet
        console.logString("Logs of the deployed-contracts on CELO Mainnet");
        console.logString("\n");
        console.log("%s: %s", "ReInsurancePool SC", address(reInsurancePool));
    }
}