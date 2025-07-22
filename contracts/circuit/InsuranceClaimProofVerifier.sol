pragma solidity ^0.8.17;

import { UltraVerifier } from "./ultra-verifier/plonk_vk.sol";
//import "../circuits/target/contract.sol";

contract InsuranceClaimProofVerifier {

    string public version;

    UltraVerifier public verifier;

    constructor(UltraVerifier _verifier) {
        verifier = _verifier;
        version = "0.1.0";
    }

    function verifyInsuranceClaimProof(bytes calldata proof, bytes32[] calldata publicInputs) public view returns (bool) {
        bool proofResult = verifier.verify(proof, publicInputs);
        require(proofResult, "A given InsuranceClaimProof is not valid");
        return proofResult;
    }

    function pock() public returns (bool) {
        return true;
    }
}
