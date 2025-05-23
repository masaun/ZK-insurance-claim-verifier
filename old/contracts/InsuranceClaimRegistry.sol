// SPDX-License-Identifier: MIT
pragma solidity ^0.8.29;


/**
 * @notice - This is the InsuranceClaimRegistry Registry contract
 * @dev - This contract is used by hospitals and insurers to register and verify their public keys.
 */
contract InsuranceClaimRegistry {

    mapping(address => bool) public hospitalPubkeys;
    mapping(address => bool) public insurerPubkeys;

    constructor() {}

    /**
     * @dev - A hospital would register on-Chain.
     * @dev - Only hispital can call this function.
     */
    function registerHospital(address hospitalPubKey) public returns (address _hospitalPubKey) {
        require(hospitalPubkeys[hospitalPubKey] = false, "This hospital pubKey has already been registered");
        hospitalPubkeys[hospitalPubKey] = true;
    }

    /**
     * @dev - A insurer would register on-Chain.
     * @dev - Only insurer can call this function.
     */
    function registerInsurer(address insurerPubKey) public returns (address _insurerPubKey) {
        require(insurerPubkeys[insurerPubKey] = false, "This insurer pubKey has already been registered");
        insurerPubkeys[insurerPubKey] = true;
    }

    /**
     * @dev - Verify whether or not a given hospitalPubKey is registered.
     */
    function isHospitalPubkeyRegistered(address hospitalPubKey) public view returns (bool _isHospitalPubkeyRegistered) {
        return hospitalPubkeys[hospitalPubKey];
    }

    /**
     * @dev - Verify whether or not a given insurerPubKey is registered.
     */
    function isInsurerPubkeyRegistered(address insurerPubKey) public view returns (bool _isInsurerPubkeyRegistered) {
        return insurerPubkeys[insurerPubKey];
    }
}