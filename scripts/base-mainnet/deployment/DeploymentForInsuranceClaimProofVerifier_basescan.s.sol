pragma solidity ^0.8.17;

import "forge-std/Script.sol";

/// @dev - ZK (Ultraplonk) circuit, which is generated in Noir.
import { UltraVerifier } from "../../../contracts/circuit/ultra-verifier/plonk_vk.sol"; /// @dev - Deployed-Verifier SC, which was generated based on the main.nr
import { InsuranceClaimProofVerifier } from "../../../contracts/circuit/InsuranceClaimProofVerifier.sol";
//import { InsuranceClaim } from "../../../contracts/InsuranceClaim.sol";


/**
 * @notice - Deployment script to deploy the InsuranceClaimProofVerifier SC - on BASE Mainnet
 */
contract DeploymentForInsuranceClaimProofVerifier_basescan is Script {
    UltraVerifier public verifier;
    InsuranceClaimProofVerifier public insuranceClaimProofVerifier;
    //InsuranceClaim public insuranceClaim;

    function setUp() public {}

    function run() public {

        vm.createSelectFork("https://mainnet.base.org"); // @dev - [NOTE]: Hardcoded the Base Mainnet RPC URL - Instead of using the environment variable via the foundry.toml
        //vm.createSelectFork('base-mainnet');

        uint256 deployerPrivateKey = vm.envUint("BASE_MAINNET_PRIVATE_KEY");
        //uint256 deployerPrivateKey = vm.envUint("LOCALHOST_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);
        //vm.startBroadcast();

        /// @dev - Deploy SCs
        verifier = UltraVerifier(vm.envAddress("ULTRAVERIFIER_ON_BASE_MAINNET"));
        //verifier = new UltraVerifier();
        insuranceClaimProofVerifier = new InsuranceClaimProofVerifier(verifier);
        //insuranceClaim = new InsuranceClaim(insuranceClaimProofVerifier);

        vm.stopBroadcast();

        /// @dev - Logs of the deployed-contracts on BASE Mainnet
        console.logString("Logs of the deployed-contracts on BASE Mainnet");
        console.logString("\n");
        console.log("%s: %s", "UltraVerifier SC", address(verifier));
        console.logString("\n");
        console.log("%s: %s", "InsuranceClaimProofVerifier SC", address(insuranceClaimProofVerifier));
        //console.logString("\n");
        //console.log("%s: %s", "InsuranceClaim SC", address(insuranceClaim));
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
