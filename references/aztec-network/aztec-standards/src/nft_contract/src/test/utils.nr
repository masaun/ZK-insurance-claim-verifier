use crate::NFT;
use aztec::{
    oracle::{execution::{get_block_number, get_contract_address}, storage::storage_read},
    prelude::AztecAddress,
    protocol_types::storage::map::derive_storage_slot_in_map,
    test::helpers::{cheatcodes, test_environment::TestEnvironment},
};

pub unconstrained fn setup_with_minter(
    with_account_contracts: bool,
) -> (&mut TestEnvironment, AztecAddress, AztecAddress, AztecAddress, AztecAddress) {
    // Setup env, generate keys
    let mut env = TestEnvironment::new();
    let (owner, minter, recipient) = if with_account_contracts {
        let owner = env.create_account_contract(1);
        let minter = env.create_account_contract(2);
        let recipient = env.create_account_contract(3);
        env.advance_block_by(1); // Ensure contracts are deployed before proceeding
        (owner, minter, recipient)
    } else {
        // For simple tests without authorization, use regular accounts
        let owner = env.create_account(1);
        let minter = env.create_account(2);
        let recipient = env.create_account(3);
        (owner, minter, recipient)
    };

    let nft_contract_address = deploy_nft_with_minter(&mut env, owner, minter);
    env.advance_block_by(1); // Ensure NFT contract is deployed before returning

    (&mut env, nft_contract_address, owner, minter, recipient)
}

pub unconstrained fn deploy_nft_with_minter(
    env: &mut TestEnvironment,
    owner: AztecAddress,
    minter: AztecAddress,
) -> AztecAddress {
    // Start the test in the account contract address
    env.impersonate(owner);

    // Deploy token contract
    let initializer_call_interface = NFT::interface().constructor_with_minter(
        "TestNFT000000000000000000000000",
        "TNFT000000000000000000000000000",
        minter,
        AztecAddress::zero(),
    );
    let nft_contract = env.deploy("./@nft_contract", "NFT").with_public_void_initializer(
        owner,
        initializer_call_interface,
    );
    env.advance_block_by(1);

    nft_contract.to_address()
}

/// @dev Setup and mint to owner in public
pub unconstrained fn setup_and_mint_to_public(
    with_account_contracts: bool,
    token_id: Field,
) -> (&mut TestEnvironment, AztecAddress, AztecAddress, AztecAddress, AztecAddress) {
    let (env, nft_contract_address, owner, minter, recipient) =
        setup_with_minter(with_account_contracts);

    env.impersonate(minter);
    NFT::at(nft_contract_address).mint_to_public(owner, token_id).call(&mut env.public());
    env.advance_block_by(1);

    (env, nft_contract_address, owner, minter, recipient)
}

pub unconstrained fn setup_and_mint_to_private(
    with_account_contracts: bool,
    token_id: Field,
) -> (&mut TestEnvironment, AztecAddress, AztecAddress, AztecAddress, AztecAddress) {
    let (env, nft_contract_address, owner, minter, recipient) =
        setup_with_minter(with_account_contracts);

    env.impersonate(minter);
    NFT::at(nft_contract_address).mint_to_private(owner, token_id).call(&mut env.private());
    env.advance_block_by(1);

    (env, nft_contract_address, owner, minter, recipient)
}

pub unconstrained fn get_nft_exists(nft_contract_address: AztecAddress, token_id: Field) -> bool {
    let current_contract_address = get_contract_address();
    cheatcodes::set_contract_address(nft_contract_address);
    let block_number = get_block_number();

    let nft_exists_slot = NFT::storage_layout().nft_exists.slot;
    let nft_slot = derive_storage_slot_in_map(nft_exists_slot, token_id);
    let exists: bool = storage_read(nft_contract_address, nft_slot, block_number);

    cheatcodes::set_contract_address(current_contract_address);
    exists
}

pub unconstrained fn assert_nft_exists(nft_contract_address: AztecAddress, token_id: Field) {
    assert(get_nft_exists(nft_contract_address, token_id), "NFT does not exist");
}

pub unconstrained fn assert_nft_does_not_exist(
    nft_contract_address: AztecAddress,
    token_id: Field,
) {
    assert(!get_nft_exists(nft_contract_address, token_id), "NFT exists when it should not");
}

pub unconstrained fn assert_owns_public_nft(
    env: &mut TestEnvironment,
    nft_contract_address: AztecAddress,
    owner: AztecAddress,
    token_id: Field,
) {
    let obtained_owner =
        NFT::at(nft_contract_address).public_owner_of(token_id).view(&mut env.public());
    assert(owner == obtained_owner, "incorrect NFT owner");
}

pub unconstrained fn assert_owns_private_nft(
    nft_contract_address: AztecAddress,
    owner: AztecAddress,
    token_id: Field,
) {
    let nft_found = owns_private_nft(nft_contract_address, owner, token_id);
    assert(nft_found, "NFT not found in private nfts");
}

pub unconstrained fn assert_private_nft_nullified(
    nft_contract_address: AztecAddress,
    owner: AztecAddress,
    token_id: Field,
) {
    let nft_found = owns_private_nft(nft_contract_address, owner, token_id);
    assert(!nft_found, "NFT found in private notes when it should have been nullified");
}

pub unconstrained fn owns_private_nft(
    nft_contract_address: AztecAddress,
    owner: AztecAddress,
    token_id: Field,
) -> bool {
    let current_contract_address = get_contract_address();
    cheatcodes::set_contract_address(nft_contract_address);
    // Direct call to unconstrained
    let (private_nfts, _) = NFT::get_private_nfts(owner, 0);

    let mut nft_found = false;
    for obtained_token_id in private_nfts {
        if obtained_token_id == token_id {
            nft_found = true;
        }
    }
    cheatcodes::set_contract_address(current_contract_address);
    nft_found
}

pub unconstrained fn get_commitment_stored(
    nft_contract_address: AztecAddress,
    commitment: Field,
) -> bool {
    let current_contract_address = get_contract_address();
    cheatcodes::set_contract_address(nft_contract_address);
    let block_number = get_block_number();

    let stored: bool = storage_read(nft_contract_address, commitment, block_number);

    cheatcodes::set_contract_address(current_contract_address);
    stored
}
