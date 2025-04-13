pragma solidity ^0.8.17;

import { UltraVerifier } from "./ultra-verifier/plonk_vk.sol";
//import "../circuits/target/contract.sol";

contract InsuranceClaimProofVerifier {
    UltraVerifier public verifier;

    constructor(UltraVerifier _verifier) {
        verifier = _verifier;
    }

    function verifyInsuranceClaimProof(bytes calldata proof, bytes32[] calldata publicInputs) public view returns (bool) {
        bool proofResult = verifier.verify(proof, publicInputs);
        require(proofResult, "A given InsuranceClaimProof is not valid");
        return proofResult;
    }
}
