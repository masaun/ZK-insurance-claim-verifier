pragma solidity ^0.8.17;

import "forge-std/Script.sol";

/// @dev - ZK (Ultraplonk) circuit, which is generated in Noir.
import { InsuranceClaimProofVerifier } from "../../../contracts/circuit/InsuranceClaimProofVerifier.sol";
import { InsuranceClaimManager } from "../../../contracts/InsuranceClaimManager.sol";


/**
 * @notice - Deployment script to deploy the InsuranceClaimManager SC - on Celo Mainnet
 */
contract DeploymentForInsuranceClaimManager_celoscan is Script {
    InsuranceClaimProofVerifier public insuranceClaimProofVerifier;
    InsuranceClaim public insuranceClaim;

    function setUp() public {}

    function run() public {

        vm.createSelectFork("https://forno.celo.org"); // @dev - [NOTE]: Hardcoded the Celo Mainnet RPC URL - Instead of using the environment variable via the foundry.toml
        //vm.createSelectFork('celo-mainnet');

        uint256 deployerPrivateKey = vm.envUint("CELO_MAINNET_PRIVATE_KEY");
        //uint256 deployerPrivateKey = vm.envUint("LOCALHOST_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        //vm.startBroadcast();

        /// @dev - Deploy SCs
        insuranceClaimProofVerifier = InsuranceClaimProofVerifier(vm.envAddress("INSURANCE_CLAIM_PROOF_VERIFIER_ON_CELO_MAINNET"));
        //insuranceClaimProofVerifier = new InsuranceClaimProofVerifier(verifier);
        insuranceClaimManager = new InsuranceClaimManager(insuranceClaimProofVerifier);

        vm.stopBroadcast();

        /// @dev - Logs of the deployed-contracts on Celo Mainnet
        console.logString("Logs of the deployed-contracts on Celo Mainnet");
        console.logString("\n");
        console.log("%s: %s", "InsuranceClaimProofVerifier SC", address(insuranceClaimProofVerifier));
        console.logString("\n");
        console.log("%s: %s", "InsuranceClaimManager SC", address(insuranceClaimManager));
    }
}



/////////////////////////////////////////
/// CLI (icl. SC sources) - New version
//////////////////////////////////////

// forge script script/DeploymentAllContracts.s.sol --broadcast --private-key ${SWELL_CHAIN_TESTNET_PRIVATE_KEY} \
//     ./circuits/target/contract.sol:UltraVerifier \
//     ./Starter.sol:Starter --skip-simulation
