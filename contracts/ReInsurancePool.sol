pragma solidity ^0.8.25;

/**
 * @notice - The ReInsurancePool contract
 */
contract ReInsurancePool {
    mapping(address => mapping(uint256 => string)) public checkpoints;
    mapping(address => bool) public depositers;
    mapping(address => uint256) public depositedAmounts;

    string public version;

    constructor() {
        version = "0.2.4";
    }

    /**
     * @notice - Register as a staker
     */
    function registerAsDepositer() public returns (bool) {
        require(!depositers[msg.sender], "You have already registered as a depositer");
        depositers[msg.sender] = true;
        return true;
    }

    function deregisterAsDepositer() public returns (bool) {
        require(depositers[msg.sender], "You are not registered as a depositer");
        depositers[msg.sender] = false;
        return true;
    }

    /**
     * @notice - checkpoint function
     */
    function checkpoint(string memory methodName) public returns (bool) {
        checkpoints[msg.sender][block.timestamp] = methodName;
        return true;
    }

    function testFunction() public returns (bool) {
        checkpoints[msg.sender][block.timestamp] = "testFunction";
        return true;
    }

    /**
     * @notice - deposit a given amount of a native token
     */
    function depositNativeTokenIntoReInsurancePool() public payable returns (bool) {
        //checkpoint();
        require(msg.value > 0, "Amount must be greater than 0");
        require(msg.sender.balance >= msg.value, "Insufficient balance to deposit");
        depositedAmounts[msg.sender] = msg.value;
        (bool success, ) = address(this).call{value: msg.value}("");
        require(success, "Deposit failed");
        return true;
    }

    /**
     * @notice - withdraw a given amount of a native token
     */
    function withdrawNativeTokenFromReInsurancePool() public returns (bool) {
        //checkpoint();
        require(depositers[msg.sender], "You are not a depositer");
        require(depositedAmounts[msg.sender] > 0, "You have no deposited amount to withdraw");
        uint256 amount = depositedAmounts[msg.sender];
        address payable depositer = payable(msg.sender);
        depositedAmounts[msg.sender] = 0;
        (bool success, ) = depositer.call{value: amount}("");
        require(success, "Withdraw failed");
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
    // function getCheckpoint() public view returns (uint256) {
    //     return checkpoints[msg.sender];
    // }

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
    }
}
