use crate::Token;
use aztec::{
    note::{constants::MAX_NOTES_PER_PAGE, note_getter::view_notes},
    oracle::{
        execution::{get_block_number, get_contract_address},
        random::random,
        storage::storage_read,
    },
    prelude::{AztecAddress, NoteViewerOptions},
    protocol_types::storage::map::derive_storage_slot_in_map,
    test::helpers::{cheatcodes, test_environment::TestEnvironment},
};
use std::test::OracleMock;
use uint_note::uint_note::UintNote;

pub global mint_amount: u128 = 10_000 as u128;

pub unconstrained fn setup_with_initial_supply(
    with_account_contracts: bool,
    initial_supply: u128,
) -> (&mut TestEnvironment, AztecAddress, AztecAddress, AztecAddress) {
    // Setup env, generate keys
    let mut env = TestEnvironment::new();
    let (owner, recipient) = if with_account_contracts {
        let owner = env.create_account_contract(1);
        let recipient = env.create_account_contract(2);
        (owner, recipient)
    } else {
        let owner = env.create_account(1);
        let recipient = env.create_account(2);
        (owner, recipient)
    };

    let token_contract_address =
        deploy_token_with_initial_supply(&mut env, owner, initial_supply, owner);

    (&mut env, token_contract_address, owner, recipient)
}

pub unconstrained fn setup_with_minter(
    with_account_contracts: bool,
) -> (&mut TestEnvironment, AztecAddress, AztecAddress, AztecAddress, AztecAddress) {
    // Setup env, generate keys
    let mut env = TestEnvironment::new();
    let (owner, recipient, minter) = if with_account_contracts {
        let owner = env.create_account_contract(1);
        let recipient = env.create_account_contract(2);
        let minter = env.create_account_contract(3);
        (owner, recipient, minter)
    } else {
        let owner = env.create_account(1);
        let recipient = env.create_account(2);
        let minter = env.create_account(3);
        (owner, recipient, minter)
    };

    let token_contract_address = deploy_token_with_minter(&mut env, owner, minter);

    (&mut env, token_contract_address, owner, recipient, minter)
}

pub unconstrained fn deploy_token_with_initial_supply(
    env: &mut TestEnvironment,
    owner: AztecAddress,
    initial_supply: u128,
    to: AztecAddress,
) -> AztecAddress {
    // Start the test in the account contract address
    env.impersonate(owner);

    // Deploy token contract
    let initializer_call_interface = Token::interface().constructor_with_initial_supply(
        "TestToken0000000000000000000000",
        "TT00000000000000000000000000000",
        18,
        initial_supply,
        to,
        AztecAddress::zero(),
    );
    let token_contract = env.deploy("./@token_contract", "Token").with_public_void_initializer(
        owner,
        initializer_call_interface,
    );
    env.advance_block_by(1);

    token_contract.to_address()
}

pub unconstrained fn deploy_token_with_minter(
    env: &mut TestEnvironment,
    owner: AztecAddress,
    minter: AztecAddress,
) -> AztecAddress {
    // Start the test in the account contract address
    env.impersonate(owner);

    // Deploy token contract
    let initializer_call_interface = Token::interface().constructor_with_minter(
        "TestToken0000000000000000000000",
        "TT00000000000000000000000000000",
        18,
        minter,
        AztecAddress::zero(),
    );
    let token_contract = env.deploy("./@token_contract", "Token").with_public_void_initializer(
        owner,
        initializer_call_interface,
    );
    env.advance_block_by(1);

    token_contract.to_address()
}

pub unconstrained fn setup_and_mint_to_public_with_minter(
    with_account_contracts: bool,
) -> (&mut TestEnvironment, AztecAddress, AztecAddress, AztecAddress, AztecAddress) {
    // Setup
    let (env, token_contract_address, owner, recipient, minter) =
        setup_with_minter(with_account_contracts);

    // Mint some tokens
    env.impersonate(minter);
    Token::at(token_contract_address).mint_to_public(owner, mint_amount).call(&mut env.public());

    env.advance_block_by(1);

    (env, token_contract_address, owner, recipient, minter)
}

pub unconstrained fn setup_and_mint_to_public_without_minter(
    with_account_contracts: bool,
) -> (&mut TestEnvironment, AztecAddress, AztecAddress, AztecAddress) {
    // Setup
    let (env, token_contract_address, owner, recipient) =
        setup_with_initial_supply(with_account_contracts, mint_amount);

    env.advance_block_by(1);

    (env, token_contract_address, owner, recipient)
}

pub unconstrained fn setup_and_mint_to_private_with_minter(
    with_account_contracts: bool,
) -> (&mut TestEnvironment, AztecAddress, AztecAddress, AztecAddress, AztecAddress) {
    let (env, token_contract_address, owner, recipient, minter) =
        setup_with_minter(with_account_contracts);

    // Mint some tokens
    env.impersonate(minter);
    mint_to_private(env, token_contract_address, owner, mint_amount);

    env.advance_block_by(1);

    (env, token_contract_address, owner, recipient, minter)
}

pub unconstrained fn setup_and_mint_to_private_without_minter(
    with_account_contracts: bool,
) -> (&mut TestEnvironment, AztecAddress, AztecAddress, AztecAddress) {
    // Setup
    let (env, token_contract_address, owner, recipient) =
        setup_with_initial_supply(with_account_contracts, mint_amount);

    env.impersonate(owner);
    Token::at(token_contract_address).transfer_public_to_private(owner, owner, mint_amount, 0).call(
        &mut env.private(),
    );
    env.advance_block_by(1);

    (env, token_contract_address, owner, recipient)
}

pub unconstrained fn mint_to_private(
    env: &mut TestEnvironment,
    token_contract_address: AztecAddress,
    recipient: AztecAddress,
    amount: u128,
) {
    let note_randomness = random();
    let _ = OracleMock::mock("getRandomField").returns(note_randomness);

    let from = recipient; // we are setting from to recipient because of TODO(#9887)
    Token::at(token_contract_address).mint_to_private(from, recipient, amount).call(
        &mut env.private(),
    );

    env.advance_block_by(1);
}

pub unconstrained fn transfer_in_private(
    env: &mut TestEnvironment,
    from: AztecAddress,
    token_contract_address: AztecAddress,
    recipient: AztecAddress,
    amount: u128,
) {
    let note_randomness = random();
    let _ = OracleMock::mock("getRandomField").returns(note_randomness);

    env.impersonate(from);
    Token::at(token_contract_address).transfer_private_to_private(from, recipient, amount, 0).call(
        &mut env.private(),
    );

    env.advance_block_by(1);
}

pub unconstrained fn check_public_balance(
    token_contract_address: AztecAddress,
    address: AztecAddress,
    address_amount: u128,
) {
    let amount: u128 = get_public_balance(token_contract_address, address);
    assert(amount == address_amount, "Public balance is not correct");
}

pub unconstrained fn get_public_balance(
    token_contract_address: AztecAddress,
    address: AztecAddress,
) -> u128 {
    let current_contract_address = get_contract_address();
    cheatcodes::set_contract_address(token_contract_address);
    let block_number = get_block_number();

    let balances_slot = Token::storage_layout().public_balances.slot;
    let address_slot = derive_storage_slot_in_map(balances_slot, address);
    let amount: u128 = storage_read(token_contract_address, address_slot, block_number);
    cheatcodes::set_contract_address(current_contract_address);
    amount
}

pub unconstrained fn check_total_supply(
    token_contract_address: AztecAddress,
    expected_total_supply: u128,
) {
    let total_supply: u128 = get_total_supply(token_contract_address);
    assert(total_supply == expected_total_supply, "Total supply is not correct");
}

pub unconstrained fn get_total_supply(token_contract_address: AztecAddress) -> u128 {
    let current_contract_address = get_contract_address();
    cheatcodes::set_contract_address(token_contract_address);
    let block_number = get_block_number();

    let total_supply_slot = Token::storage_layout().total_supply.slot;
    let total_supply: u128 = storage_read(token_contract_address, total_supply_slot, block_number);
    cheatcodes::set_contract_address(current_contract_address);
    total_supply
}

pub unconstrained fn check_private_balance(
    token_contract_address: AztecAddress,
    address: AztecAddress,
    address_amount: u128,
) {
    let balance_of_private = get_private_balance(token_contract_address, address);
    assert(balance_of_private == address_amount, "Private balance is not correct");
}

pub unconstrained fn get_private_balance(
    token_contract_address: AztecAddress,
    address: AztecAddress,
) -> u128 {
    let current_contract_address = get_contract_address();
    cheatcodes::set_contract_address(token_contract_address);
    // Direct call to unconstrained
    let amt = Token::balance_of_private(address);
    cheatcodes::set_contract_address(current_contract_address);
    amt
}

// TODO: I think we don't need this anymore.
// This is used if we need to add a token note manually, in the case where the note is not emitted in logs.
pub unconstrained fn add_token_note(
    env: &mut TestEnvironment,
    token_contract_address: AztecAddress,
    owner: AztecAddress,
    amount: u128,
    note_randomness: Field,
) {
    let balances_owner_slot =
        derive_storage_slot_in_map(Token::storage_layout().private_balances.slot, owner);

    env.add_note(
        UintNote { value: amount, owner: owner, randomness: note_randomness },
        balances_owner_slot,
        token_contract_address,
    );
}

pub unconstrained fn get_private_balance_notes(
    token_contract_address: AztecAddress,
    account: AztecAddress,
    offset: u32,
) -> BoundedVec<UintNote, MAX_NOTES_PER_PAGE> {
    let current_contract_address = get_contract_address();
    cheatcodes::set_contract_address(token_contract_address);
    let mut options = NoteViewerOptions::new();
    let private_balances_slot = Token::storage_layout().private_balances.slot;
    let private_balance_slot = derive_storage_slot_in_map(private_balances_slot, account);
    let notes: BoundedVec<UintNote, MAX_NOTES_PER_PAGE> =
        view_notes(private_balance_slot, options.set_offset(offset));
    cheatcodes::set_contract_address(current_contract_address);
    notes
}

/// @notice Retrieves whether a commitment has been stored in the storage of the target contract
pub unconstrained fn _commitment_storage_read(
    target_contract_address: AztecAddress,
    commitment: Field,
) -> bool {
    // store current contract address
    let current_contract_address = get_contract_address();
    // set target contract address
    cheatcodes::set_contract_address(target_contract_address);
    let block_number = get_block_number();
    let value: bool = storage_read(target_contract_address, commitment, block_number);
    // restore current contract address
    cheatcodes::set_contract_address(current_contract_address);
    value
}
