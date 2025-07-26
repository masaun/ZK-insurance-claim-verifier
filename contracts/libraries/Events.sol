// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;


/**
 * @title Events library
 */
library Events {
    event ClaimApproved(address indexed claimant, uint256 payout);
    event ClaimDenied(address indexed claimant, string reason);
    event ClaimSubmitted(address indexed claimant, bytes proof, bytes32[] publicInputs);
    event HospitalBillDataStored(address indexed hospital, bytes32[] publicInputs);
    event PayoutProcessed(address indexed claimant, uint256 payoutAmount);
    event InsuranceClaimProofVerifierUpdated(address indexed newVerifier);
    event InsurerUpdated(address indexed newInsurer);
}