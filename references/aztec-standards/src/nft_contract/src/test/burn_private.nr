use crate::NFT;
use crate::test::utils;
use authwit::cheatcodes as authwit_cheatcodes;

#[test]
unconstrained fn nft_burn_private_self_success() {
    // Setup and mint NFT to owner in private state
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, _) =
        utils::setup_and_mint_to_private(false, token_id);

    // Verify initial state
    utils::assert_owns_private_nft(nft_contract_address, owner, token_id);
    utils::assert_nft_exists(nft_contract_address, token_id);

    // Burn the NFT
    env.impersonate(owner);
    NFT::at(nft_contract_address).burn_private(owner, token_id, 0).call(&mut env.private());
    env.advance_block_by(1);

    // Verify NFT is burned (no longer in private notes and marked as non-existent)
    utils::assert_private_nft_nullified(nft_contract_address, owner, token_id);
    utils::assert_nft_does_not_exist(nft_contract_address, token_id);
}

#[test]
unconstrained fn nft_burn_private_authorized_success() {
    // Setup with account contracts and mint NFT to owner
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, recipient) =
        utils::setup_and_mint_to_private(true, token_id);

    // Verify initial state
    utils::assert_owns_private_nft(nft_contract_address, owner, token_id);
    utils::assert_nft_exists(nft_contract_address, token_id);

    // Create burn call interface with non-zero nonce
    let burn_call_interface = NFT::at(nft_contract_address).burn_private(owner, token_id, 1);

    // Add authorization witness from owner to recipient
    authwit_cheatcodes::add_private_authwit_from_call_interface(
        owner,
        recipient,
        burn_call_interface,
    );

    // Impersonate recipient to perform the authorized burn
    env.impersonate(recipient);
    burn_call_interface.call(&mut env.private());
    env.advance_block_by(1);

    // Verify NFT is burned
    utils::assert_private_nft_nullified(nft_contract_address, owner, token_id);
    utils::assert_nft_does_not_exist(nft_contract_address, token_id);
}

#[test(should_fail_with = "nft not found in private to public")]
unconstrained fn nft_burn_private_non_existent_fail() {
    // Setup but don't mint any NFT
    let (env, nft_contract_address, owner, _, _) = utils::setup_with_minter(false);
    let non_existent_token_id = 12345;

    // Attempt to burn non-existent NFT
    env.impersonate(owner);
    NFT::at(nft_contract_address).burn_private(owner, non_existent_token_id, 0).call(
        &mut env.private(),
    );
}

#[test(should_fail_with = "Unknown auth witness for message hash")]
unconstrained fn nft_burn_private_unauthorized_fail() {
    // Setup with account contracts
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, recipient) =
        utils::setup_and_mint_to_private(true, token_id);

    // Create burn interface with non-zero nonce
    let burn_call_interface = NFT::at(nft_contract_address).burn_private(owner, token_id, 1);

    // Impersonate recipient but DON'T add authorization witness
    env.impersonate(recipient);
    burn_call_interface.call(&mut env.private());
}

#[test(should_fail_with = "Unknown auth witness for message hash")]
unconstrained fn nft_burn_private_wrong_authwit_fail() {
    // Setup with account contracts
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, recipient) =
        utils::setup_and_mint_to_private(true, token_id);

    // Create burn interface with non-zero nonce
    let burn_call_interface = NFT::at(nft_contract_address).burn_private(owner, token_id, 1);

    // Add authorization witness but to the wrong address (owner instead of recipient)
    authwit_cheatcodes::add_private_authwit_from_call_interface(
        owner,
        owner, // Wrong address - should be recipient
        burn_call_interface,
    );

    // Impersonate recipient
    env.impersonate(recipient);
    burn_call_interface.call(&mut env.private());
}

#[test(should_fail_with = "nft not found in private to public")]
unconstrained fn nft_burn_private_public_nft_fail() {
    // Setup and mint NFT to owner in public state
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, _) = utils::setup_and_mint_to_public(false, token_id);

    // Verify NFT is in public state
    utils::assert_owns_public_nft(env, nft_contract_address, owner, token_id);

    // Attempt to burn from private state when NFT is actually in public state
    env.impersonate(owner);
    NFT::at(nft_contract_address).burn_private(owner, token_id, 0).call(&mut env.private());
}
