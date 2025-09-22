use dep::aztec::{prelude::AztecAddress, test::helpers::test_environment::TestEnvironment};

use crate::ConfidentialPayrollManagement;
//use crate::EasyPrivateVoting;

// @dev - Import the token_contract
use dep::token::Token;

pub unconstrained fn setup(
    with_account_contracts: bool // @dev - [NOTE]: This parameter is from the token_contract's test setup function
) -> (&mut TestEnvironment, AztecAddress, AztecAddress, AztecAddress, AztecAddress, AztecAddress) {
    let mut env = TestEnvironment::new();

    let admin: AztecAddress = env.create_account(1);

    // Setup env, generate keys and accounts
    let (owner, recipient) = if with_account_contracts {
        let owner = env.create_account_contract(1);
        let recipient = env.create_account_contract(2);
        (owner, recipient)
    } else {
        let owner = env.create_account(1);
        let recipient = env.create_account(2);
        (owner, recipient)
    };

    // Start the test in the account contract address
    env.impersonate(owner);

    // @dev - Deploy a token contract (as a "USDC" stablecoin mock token contract)
    // @dev - ref.token_contract's test: https://github.com/AztecProtocol/aztec-packages/blob/v1.2.0/noir-projects/noir-contracts/contracts/app/token_contract/src/test/utils.nr#L28-L34
    let initializer_call_interface = Token::interface().constructor(
        owner,
        "USDCToken0000000000000000000000",
        "USDC000000000000000000000000000", // 31 chars
        18,
    );

    let token_contract = env.deploy_self("Token").with_public_void_initializer(
        admin, // @dev - [NOTE]: This is a deployer address, not a constructor argument.
        initializer_call_interface
    );
    //let token_contract = env.deploy_self("Token").with_public_void_initializer(owner, initializer_call_interface);
    let token_contract_address = token_contract.to_address();
    //env.advance_block_by(1);
    //(&mut env, token_contract_address, owner, recipient)
    println(f"Token contract address: {token_contract_address}\n");
    //println(f"ConfidentialPayrollManagement contract address: {confidential_payroll_management_contract.to_address()}\n");

    let usdc_token_address: AztecAddress = token_contract_address;

    // @dev - Deploy the ConfidentialPayrollManagement contract
    let initializer_call_interface = ConfidentialPayrollManagement::interface().constructor(admin, usdc_token_address);
    //let initializer_call_interface = EasyPrivateVoting::interface().constructor(admin);

    let confidential_payroll_management_contract = env.deploy_self("ConfidentialPayrollManagement").with_public_void_initializer(
        admin, // @dev - [NOTE]: This is a deployer address, not a constructor argument.
        initializer_call_interface,
    );

    env.advance_block_by(1);

    // @dev - Return values
    (&mut env, confidential_payroll_management_contract.to_address(), admin, token_contract_address, owner, recipient)
}
