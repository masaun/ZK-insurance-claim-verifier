pragma solidity ^0.8.17;

import { InsuranceClaimProofVerifier } from "./circuit/InsuranceClaimProofVerifier.sol";


contract InsuranceClaim {

    string public version;

    InsuranceClaimProofVerifier public insuranceClaimProofVerifier;

    mapping(address => bool) public claimed;

    constructor(InsuranceClaimProofVerifier _insuranceClaimProofVerifier) {
        insuranceClaimProofVerifier = _insuranceClaimProofVerifier;
        version = "0.1.0";
    }

    function submitInsuranceClaim(bytes calldata proof, bytes32[] calldata publicInputs) public returns (bool) {
        bool proofResult = insuranceClaimProofVerifier.verifyInsuranceClaimProof(proof, publicInputs);
        require(proofResult, "A given InsuranceClaimProof is not valid");

        claimed[msg.sender] = true;

        return proofResult;
    }

    function poke() public returns (bool) {
        return true;
    }
}
