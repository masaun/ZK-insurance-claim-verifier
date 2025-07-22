pragma solidity ^0.8.17;

import "forge-std/Script.sol";

/// @dev - ZK (Ultraplonk) circuit, which is generated in Noir.
import { UltraVerifier } from "../../../contracts/circuit/ultra-verifier/plonk_vk.sol"; /// @dev - Deployed-Verifier SC, which was generated based on the main.nr
import { InsuranceClaimProofVerifier } from "../../../contracts/circuit/InsuranceClaimProofVerifier.sol";
import { InsuranceClaim } from "../../../contracts/InsuranceClaim.sol";
//import { InsuranceClaimRegistry } from "../../../contracts/InsuranceClaimRegistry.sol";


/**
 * @notice - Deployment script to deploy all SCs at once - on Sonic Blaze Testnet
 * @dev - [CLI]: Using the CLI, which is written in the bottom of this file, to deploy all SCs
 */
contract DeploymentAllContracts is Script {
    UltraVerifier public verifier;
    InsuranceClaimProofVerifier public insuranceClaimProofVerifier;
    InsuranceClaim public insuranceClaim;
    //InsuranceClaimRegistry public insuranceClaimRegistry;

    function setUp() public {}

    function run() public {

        //vm.createSelectFork('base-testnet'); // [NOTE]: Commmentout due to the error of the "Multi chain deployment does not support library linking at the moment"

        uint256 deployerPrivateKey = vm.envUint("BASE_TESTNET_PRIVATE_KEY");
        //uint256 deployerPrivateKey = vm.envUint("LOCALHOST_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        //vm.startBroadcast();

        /// @dev - Deploy SCs
        verifier = new UltraVerifier();
        insuranceClaimProofVerifier = new InsuranceClaimProofVerifier(verifier);
        insuranceClaim = new InsuranceClaim(insuranceClaimProofVerifier);
        //insuranceClaimRegistry = new InsuranceClaimRegistry();

        vm.stopBroadcast();

        /// @dev - Logs of the deployed-contracts on BASE Testnet
        console.logString("Logs of the deployed-contracts on BASE Testnet");
        console.logString("\n");
        console.log("%s: %s", "UltraVerifier SC", address(verifier));
        console.logString("\n");
        console.log("%s: %s", "InsuranceClaimProofVerifier SC", address(insuranceClaimProofVerifier));
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
