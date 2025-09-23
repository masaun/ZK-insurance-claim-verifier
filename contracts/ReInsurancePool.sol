pragma solidity ^0.8.25;

import { IERC20 } from "./interfaces/IERC20.sol";

/**
 * @notice - The ReInsurancePool contract
 */
contract ReInsurancePool {
    IERC20 public usdc; // USDC token contract instance
    address public USDC_ADDRESS_ON_BASE_MAINNET;

    mapping(address => mapping(uint256 => string)) public checkpoints;
    mapping(address user => uint256 checkpointCount) public checkpointCounts;

    mapping(address => bool) public depositers;
    mapping(address => uint256) public depositedAmounts;

    string public version;

    constructor() {
        version = "0.51.88";
        USDC_ADDRESS_ON_BASE_MAINNET = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913; // USDC token on BASE Mainnet
        usdc = IERC20(USDC_ADDRESS_ON_BASE_MAINNET); // USDC token on BASE Mainnet
    }

    /**
     * @notice - Register as a staker
     */
    function registerAsDepositer() public returns (bool) {
        require(!depositers[msg.sender], "You have already registered as a depositer");
        depositers[msg.sender] = true;
        checkpoints[msg.sender][block.timestamp] = "registerAsDepositer";
        checkpointCounts[msg.sender]++;
        return true;
    }

    function deregisterAsDepositer() public returns (bool) {
        require(depositers[msg.sender], "You are not registered as a depositer");
        depositers[msg.sender] = false;
        checkpoints[msg.sender][block.timestamp] = "deregisterAsDepositer";
        checkpointCounts[msg.sender]++;
        return true;
    }

    /**
     * @notice - Get the rewards based on the count of a caller's checkpoints
     */
    function getRewards() public view returns (bool) {
        uint256 rewardAmount = checkpointCounts[msg.sender] * 1;  // 1 wei reward per checkpoint
        require(rewardAmount > 0, "No rewards available");
        return true;
    }

    /**
     * @notice - checkpoint function
     */
    function checkpoint(string memory methodName) public returns (bool) {
        checkpoints[msg.sender][block.timestamp] = methodName;
        checkpoints[msg.sender][block.timestamp] = "checkpoints";
        checkpointCounts[msg.sender]++;
        return true;
    }

    function testFunctionForCheckPoint() public returns (bool) {
        checkpoints[msg.sender][block.timestamp] = "testFunctionForCheckPoint";
        checkpointCounts[msg.sender]++;
        return true;
    }

    /**
     * @notice - distribute a given amount of a native token into the insurance pool
     */
    function distributeNativeTokenIntoInsurancePool(address insurancePool, uint256 amount) public payable returns (bool) {
        require(amount > 0, "Amount must be greater than 0");
        require(address(this).balance >= amount, "Insufficient balance to deposit");
        (bool success, ) = insurancePool.call{value: amount}("");
        require(success, "Distribution to the insurance pool failed");

        checkpoints[msg.sender][block.timestamp] = "distributeNativeTokenIntoInsurancePool";
        checkpointCounts[msg.sender]++;
        return true;
    }

    /**
     * @notice - deposit a given amount of a native token
     */
    function depositNativeTokenIntoReInsurancePool() public payable returns (bool) {
        require(msg.value > 0, "Amount must be greater than 0");
        require(msg.sender.balance >= msg.value, "Insufficient balance to deposit");
        depositedAmounts[msg.sender] = msg.value;
        (bool success, ) = address(this).call{value: msg.value}("");
        require(success, "Deposit failed");

        checkpoints[msg.sender][block.timestamp] = "depositNativeTokenIntoReInsurancePool";
        checkpointCounts[msg.sender]++;
        return true;
    }

    /**
     * @notice - deposit a given amount of a ERC20 token
     */
    function depositERC20TokenIntoReInsurancePool() public returns (bool) {
        // [TODO]:
        checkpoints[msg.sender][block.timestamp] = "depositERC20TokenIntoReInsurancePool";
        checkpointCounts[msg.sender]++;
        return true;
    }

    /**
     * @notice - withdraw a given amount of a ERC20 token
     */
    function withdrawERC20TokenFromReInsurancePool() public returns (bool) {
        // [TODO]:
        checkpoints[msg.sender][block.timestamp] = "withdrawERC20TokenFromReInsurancePool";
        checkpointCounts[msg.sender]++;
        return true;
    }

    /**
     * @notice - withdraw a given amount of a native token
     */
    function withdrawNativeTokenFromReInsurancePool() public returns (bool) {
        require(depositers[msg.sender], "You are not a depositer");
        require(depositedAmounts[msg.sender] > 0, "You have no deposited amount to withdraw");
        uint256 amount = depositedAmounts[msg.sender];
        address payable depositer = payable(msg.sender);
        depositedAmounts[msg.sender] = 0;
        (bool success, ) = depositer.call{value: amount}("");
        require(success, "Withdraw failed");

        checkpoints[msg.sender][block.timestamp] = "withdrawNativeTokenFromReInsurancePool";
        checkpointCounts[msg.sender]++;
        return true;
    }

    /**
     * @notice - Get the contract's native token balance
     */
    function getNativeETHBalanceOfContract() public view returns (uint256) {
        return address(this).balance;
    }

    /**
     * @notice - Get the contract's USDC (ERC20) token balance
     */
    function getUSDCBalanceOfContract() public view returns (uint256) {
        return usdc.balanceOf(address(this));
    }

    /**
     * @notice - Get the checkpoint of the caller
     */
    function getCheckpoint(uint256 timestamp) public view returns (string memory _methodName) {
        return checkpoints[msg.sender][timestamp];
    }

    /**
     * @notice - Receive function to accept Ether transfers
     * @dev - Basically, a funds, which directly sent to this contract, is,sending back to a sender.
     */
    receive() external payable {
        //checkpoint();
        require(msg.value > 0, "Must send some Ether");
        depositedAmounts[msg.sender] += msg.value;
        // (bool success, ) = msg.sender.call{value: msg.value}("");
        // require(success, "Transfering back failed");
        checkpoints[msg.sender][block.timestamp] = "receive";
        checkpointCounts[msg.sender]++;
    }

    /**
     * @notice - Fallback function
     * @dev - Basically, a funds, which directly sent to this contract, is,sending back to a sender.
     */
    fallback() external payable {
        //checkpoint();
        require(msg.value > 0, "Must send some Ether");
        depositedAmounts[msg.sender] += msg.value;
        // (bool success, ) = msg.sender.call{value: msg.value}("");
        // require(success, "Transfering back failed");
        checkpoints[msg.sender][block.timestamp] = "fallback";
        checkpointCounts[msg.sender]++;
    }


    function addToFiftyThree(string memory methodName) public returns (bool) {
        checkpoints[msg.sender][block.timestamp] = "addToFiftyThree";
        checkpointCounts[msg.sender]++;
        return true;
    }

}
