pragma solidity ^0.8.17;

import "forge-std/Script.sol";

/// @dev - ZK (Ultraplonk) circuit, which is generated in Noir.
import { InsuranceClaimProofVerifier } from "../../../contracts/circuit/InsuranceClaimProofVerifier.sol";
import { InsuranceClaim } from "../../../contracts/InsuranceClaim.sol";


/**
 * @notice - Deployment script to deploy all SCs at once - on BASE Testnet
 */
contract DeploymentInsuranceClaim is Script {
    InsuranceClaimProofVerifier public insuranceClaimProofVerifier;
    InsuranceClaim public insuranceClaim;

    function setUp() public {}

    function run() public {

        //vm.createSelectFork('base-testnet'); // [NOTE]: Commmentout due to the error of the "Multi chain deployment does not support library linking at the moment"

        uint256 deployerPrivateKey = vm.envUint("BASE_TESTNET_PRIVATE_KEY");
        //uint256 deployerPrivateKey = vm.envUint("LOCALHOST_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        //vm.startBroadcast();

        address INSURANCE_CLAIM_PROOF_VERIFIER = vm.envAddress("INSURANCE_CLAIM_PROOF_VERIFIER_ON_BASE_TESTNET");

        /// @dev - Deploy SCs
        insuranceClaimProofVerifier = InsuranceClaimProofVerifier(INSURANCE_CLAIM_PROOF_VERIFIER);
        insuranceClaim = new InsuranceClaim(insuranceClaimProofVerifier);
        //insuranceClaimRegistry = new InsuranceClaimRegistry();

        vm.stopBroadcast();

        /// @dev - Logs of the deployed-contracts on BASE Testnet
        console.logString("Logs of the deployed-contracts on BASE Testnet");
        console.logString("\n");
        console.log("%s: %s", "InsuranceClaimProofVerifier SC", INSURANCE_CLAIM_PROOF_VERIFIER);
        console.logString("\n");
        console.log("%s: %s", "InsuranceClaim SC", address(insuranceClaim));
        //console.logString("\n");
        //console.log("%s: %s", "InsuranceClaimRegistry SC", address(insuranceClaimRegistry));
    }
}



/////////////////////////////////////////
/// CLI (icl. SC sources) - New version
//////////////////////////////////////

// forge script script/DeploymentAllContracts.s.sol --broadcast --private-key ${SWELL_CHAIN_TESTNET_PRIVATE_KEY} \
//     ./circuits/target/contract.sol:UltraVerifier \
//     ./Starter.sol:Starter --skip-simulation
