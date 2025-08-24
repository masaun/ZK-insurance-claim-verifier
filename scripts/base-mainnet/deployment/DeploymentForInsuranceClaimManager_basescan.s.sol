pragma solidity ^0.8.17;

import "forge-std/Script.sol";

/// @dev - ZK (Ultraplonk) circuit, which is generated in Noir.
import { InsuranceClaimProofVerifier } from "../../../contracts/circuit/InsuranceClaimProofVerifier.sol";
import { InsuranceClaimManager } from "../../../contracts/InsuranceClaimManager.sol";
import { ReInsurancePool } from "../../../contracts/ReInsurancePool.sol";

/**
 * @notice - Deployment script to deploy the InsuranceClaimManager SC - on BASE Mainnet
 */
contract DeploymentForInsuranceClaimManager_basescan is Script {
    InsuranceClaimProofVerifier public insuranceClaimProofVerifier;
    InsuranceClaimManager public insuranceClaimManager;
    ReInsurancePool public reInsurancePool;

    function setUp() public {}

    function run() public {
        vm.createSelectFork("https://mainnet.base.org"); // @dev - [NOTE]: Hardcoded the Base Mainnet RPC URL - Instead of using the environment variable via the foundry.toml
        //vm.createSelectFork('base-mainnet');

        uint256 deployerPrivateKey = vm.envUint("BASE_MAINNET_PRIVATE_KEY");
        //uint256 deployerPrivateKey = vm.envUint("LOCALHOST_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        //vm.startBroadcast();

        /// @dev - Deploy SCs
        insuranceClaimProofVerifier = InsuranceClaimProofVerifier(vm.envAddress("INSURANCE_CLAIM_PROOF_VERIFIER_ON_BASE_MAINNET"));
        //insuranceClaimProofVerifier = new InsuranceClaimProofVerifier(verifier);
        reInsurancePool = ReInsurancePool(payable(vm.envAddress("REINSURANCE_POOL_ON_BASE_MAINNET")));
        insuranceClaimManager = new InsuranceClaimManager(insuranceClaimProofVerifier, reInsurancePool);

        vm.stopBroadcast();

        /// @dev - Logs of the deployed-contracts on Base Mainnet
        console.logString("Logs of the deployed-contracts on Base Mainnet");
        console.logString("\n");
        console.log("%s: %s", "InsuranceClaimProofVerifier SC", address(insuranceClaimProofVerifier));
        console.logString("\n");
        console.log("%s: %s", "ReInsurancePool SC", address(reInsurancePool));
        console.logString("\n");
        console.log("%s: %s", "InsuranceClaimManager SC", address(insuranceClaimManager));
        console.logString("\n");
    }
}



/////////////////////////////////////////
/// CLI (icl. SC sources) - New version
//////////////////////////////////////

// forge script script/DeploymentAllContracts.s.sol --broadcast --private-key ${SWELL_CHAIN_TESTNET_PRIVATE_KEY} \
//     ./circuits/target/contract.sol:UltraVerifier \
//     ./Starter.sol:Starter --skip-simulation
