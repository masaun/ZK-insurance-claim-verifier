pragma solidity ^0.8.17;

import { InsuranceClaimProofVerifier } from "./circuit/InsuranceClaimProofVerifier.sol";
//import "../circuits/target/contract.sol";

contract InsuranceClaimManager {

    string public version;

    InsuranceClaimProofVerifier public insuranceClaimProofVerifier;

    mapping(address => bool) public insurers;
    mapping(address => bool) public claimants;
    mapping(address => mapping(address => bool)) public claimRequests;
    mapping(address => mapping(address => bool)) public approvedClaims;

    constructor(InsuranceClaimProofVerifier _insuranceClaimProofVerifier) {
        insuranceClaimProofVerifier = _insuranceClaimProofVerifier;
        version = "0.1.3";
    }

    /**
     * @notice - Submit the insurance claim by a claimant
     */
    function submitInsuranceClaim(bytes calldata proof, bytes32[] calldata publicInputs, address insurer) public returns (bool) {
        require(claimants[msg.sender], "You are not registered as a claimant");

        bool proofResult = insuranceClaimProofVerifier.verifyInsuranceClaimProof(proof, publicInputs);
        //bool proofResult = insuranceClaimProofVerifier.verifyInsuranceClaimProof(proof, publicInputs);
        require(proofResult, "A given InsuranceClaimProof is not valid");

        claimRequests[insurer][msg.sender] = true;
    }

    /**
     * @notice - Approve the insurance claim by an insurer
     */
    function approveInsuranceClaim(address claimant) public returns (bool) {
        require(insurers[msg.sender], "You are not registered as an insurer");
        require(claimants[claimant], "No claim request found for this address");

        approvedClaims[msg.sender][claimant] = true;

        return true;
    }

    /**
     * @notice - Register as a claimant or an insurer
     */
    function registerAsClaimant() public returns (bool) {
        require(!claimants[msg.sender], "You have already registered as a claimant");
        claimants[msg.sender] = true;
        return true;
    }

    function registerAsInsurer() public returns (bool) {
        require(!insurers[msg.sender], "You have already registered as an insurer");
        insurers[msg.sender] = true;
        return true;
    }

    /**
     * @notice - Deregister as a claimant or an insurer
     */
    function deregisterAsClaimant() public returns (bool) {
        require(claimants[msg.sender], "You are not registered as a claimant");
        claimants[msg.sender] = false;
        return true;
    }

    function deregisterAsInsurer() public returns (bool) {
        require(insurers[msg.sender], "You are not registered as an insurer");
        insurers[msg.sender] = false;
        return true;
    }

    /**
     * @notice - This function is a test function
     */
    function poke() public returns (bool) {
        return true;
    }
}
