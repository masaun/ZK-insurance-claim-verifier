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

    mapping(address => uint256) public checkpoints;
    mapping(address => uint256) public checkpointOfStakings;
    mapping(address => bool) public stakers;
    mapping(address => uint256) public stakedAmounts;

    constructor(InsuranceClaimProofVerifier _insuranceClaimProofVerifier) {
        insuranceClaimProofVerifier = _insuranceClaimProofVerifier;
        version = "0.2.1";
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
     * @notice - checkpoint function
     */
    function checkpoint() public returns (bool) {
        checkpoints[msg.sender] = block.timestamp;
        return true;
    }

    /**
     * @notice - checkpoint function
     */
    function _checkpointOfStaking() internal returns (bool) {
        checkpointOfStakings[msg.sender] = block.timestamp;
        return true;
    }

    /**
     * @notice - Register/Deregister as a staker (of the insurance pool)
     */
    function registerAsStaker() public returns (bool) {
        require(!stakers[msg.sender], "You are already registered as a staker");
        stakers[msg.sender] = true;
        return true;
    }

    function deregisterAsStaker() public returns (bool) {
        require(stakers[msg.sender], "You are not registered as a staker");
        require(stakedAmounts[msg.sender] == 0, "You have staked amount, please unstake first");
        stakers[msg.sender] = false;
        return true;
    }

    /**
     * @notice - stake a given amount of a native token into the insurance pool
     */
    function stakeNativeTokenIntoInsurancePool() public payable returns (bool) {
        _checkpointOfStaking();
        require(stakers[msg.sender], "You are not registered as a staker");
        require(msg.value > 0, "Amount must be greater than 0");
        require(msg.sender.balance >= msg.value, "Insufficient balance to stake");
        stakedAmounts[msg.sender] = msg.value;
        (bool success, ) = address(this).call{value: msg.value}("");
        require(success, "Stake failed");
        return true;
    }

    /**
     * @notice - unstake a given amount of a native token from the insurance pool
     */
    function unstakeNativeTokenFromInsurancePool() public returns (bool) {
        _checkpointOfStaking();
        require(stakers[msg.sender], "You are not a staker");
        require(stakedAmounts[msg.sender] > 0, "You have no staked amount to withdraw");
        uint256 amount = stakedAmounts[msg.sender];
        address payable staker = payable(msg.sender);
        stakedAmounts[msg.sender] = 0;
        (bool success, ) = staker.call{value: amount}("");
        require(success, "Unstake failed");
        return true;
    }

    /**
     * @notice - Get the contract's native token balance
     */
    function getContractBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @notice - Get the checkpoint of the caller
     */
    function getCheckpoint() public view returns (uint256) {
        return checkpoints[msg.sender];
    }

    /**
     * @notice - Receive function to accept Ether transfers
     */
    receive() external payable {}

    /**
     * @notice - Fallback function
     */
    fallback() external payable {}

}
