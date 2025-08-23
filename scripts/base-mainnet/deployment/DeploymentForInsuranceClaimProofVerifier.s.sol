pragma solidity ^0.8.17;

import "forge-std/Script.sol";

/// @dev - ZK (Ultraplonk) circuit, which is generated in Noir.
import { UltraVerifier } from "../../../contracts/circuit/ultra-verifier/plonk_vk.sol";
import { InsuranceClaimProofVerifier } from "../../../contracts/circuit/InsuranceClaimProofVerifier.sol";

/**
 * @notice - Deployment script to deploy InsuranceClaimProofVerifier - on Base Mainnet
 */
contract DeploymentForInsuranceClaimProofVerifier is Script {
    UltraVerifier public verifier;
    InsuranceClaimProofVerifier public insuranceClaimProofVerifier;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("BASE_MAINNET_PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        /// @dev - Deploy SCs
        verifier = new UltraVerifier();
        insuranceClaimProofVerifier = new InsuranceClaimProofVerifier(verifier);

        vm.stopBroadcast();

        /// @dev - Logs of the deployed-contracts on Base Mainnet
        console.logString("Logs of the deployed-contracts on Base Mainnet");
        console.logString("\n");
        console.log("%s: %s", "UltraVerifier SC", address(verifier));
        console.logString("\n");
        console.log("%s: %s", "InsuranceClaimProofVerifier SC", address(insuranceClaimProofVerifier));
    }
}
