use crate::NFT;
use crate::test::utils;
use authwit::cheatcodes as authwit_cheatcodes;

#[test]
unconstrained fn nft_transfer_private_to_private_success() {
    // Setup and mint NFT to owner in private state
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, recipient) =
        utils::setup_and_mint_to_private(false, token_id);

    // Verify initial ownership
    utils::assert_owns_private_nft(nft_contract_address, owner, token_id);

    // Transfer NFT from owner to recipient
    env.impersonate(owner);
    NFT::at(nft_contract_address).transfer_private_to_private(owner, recipient, token_id, 0).call(
        &mut env.private(),
    );
    env.advance_block_by(1);

    // Verify ownership transfer
    utils::assert_private_nft_nullified(nft_contract_address, owner, token_id);
    utils::assert_owns_private_nft(nft_contract_address, recipient, token_id);
}

#[test]
unconstrained fn nft_transfer_private_to_private_self_success() {
    // Setup and mint NFT to owner in private state
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, _) =
        utils::setup_and_mint_to_private(false, token_id);

    // Verify initial ownership
    utils::assert_owns_private_nft(nft_contract_address, owner, token_id);

    // Transfer NFT from owner to self
    env.impersonate(owner);
    NFT::at(nft_contract_address).transfer_private_to_private(owner, owner, token_id, 0).call(
        &mut env.private(),
    );
    env.advance_block_by(1);

    // Verify owner still owns the NFT
    utils::assert_owns_private_nft(nft_contract_address, owner, token_id);
}

#[test]
unconstrained fn nft_transfer_private_to_private_authorized_success() {
    // Setup with account contracts and mint NFT to owner
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, recipient) =
        utils::setup_and_mint_to_private(true, token_id);

    // Verify initial ownership
    utils::assert_owns_private_nft(nft_contract_address, owner, token_id);

    // Create transfer call interface with non-zero nonce
    let transfer_call_interface =
        NFT::at(nft_contract_address).transfer_private_to_private(owner, recipient, token_id, 1);

    // Add authorization witness from owner to recipient
    authwit_cheatcodes::add_private_authwit_from_call_interface(
        owner,
        recipient,
        transfer_call_interface,
    );

    // Impersonate recipient to perform the authorized transfer
    env.impersonate(recipient);
    transfer_call_interface.call(&mut env.private());
    env.advance_block_by(1);

    // Verify ownership transfer
    utils::assert_private_nft_nullified(nft_contract_address, owner, token_id);
    utils::assert_owns_private_nft(nft_contract_address, recipient, token_id);
}

#[test(should_fail_with = "nft not found in private to public")]
unconstrained fn nft_transfer_private_to_private_non_existent_fail() {
    // Setup but don't mint any NFT
    let (env, nft_contract_address, owner, _, recipient) = utils::setup_with_minter(false);
    let non_existent_token_id = 12345;

    // Attempt to transfer non-existent NFT
    env.impersonate(owner);
    NFT::at(nft_contract_address)
        .transfer_private_to_private(owner, recipient, non_existent_token_id, 0)
        .call(&mut env.private());
}

#[test(should_fail_with = "Unknown auth witness for message hash")]
unconstrained fn nft_transfer_private_to_private_unauthorized_fail() {
    // Setup with account contracts
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, recipient) =
        utils::setup_and_mint_to_private(true, token_id);

    // Create transfer interface with non-zero nonce
    let transfer_call_interface =
        NFT::at(nft_contract_address).transfer_private_to_private(owner, recipient, token_id, 1);

    // Impersonate recipient but DON'T add authorization witness
    env.impersonate(recipient);
    transfer_call_interface.call(&mut env.private());
}

#[test(should_fail_with = "Unknown auth witness for message hash")]
unconstrained fn nft_transfer_private_to_private_wrong_authwit_fail() {
    // Setup with account contracts
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, recipient) =
        utils::setup_and_mint_to_private(true, token_id);

    // Create transfer interface with non-zero nonce
    let transfer_call_interface =
        NFT::at(nft_contract_address).transfer_private_to_private(owner, recipient, token_id, 1);

    // Add authorization witness but to the wrong address (owner instead of recipient)
    authwit_cheatcodes::add_private_authwit_from_call_interface(
        owner,
        owner, // Wrong address - should be recipient
        transfer_call_interface,
    );

    // Impersonate recipient
    env.impersonate(recipient);
    transfer_call_interface.call(&mut env.private());
}

#[test(should_fail_with = "nft not found in private to public")]
unconstrained fn nft_transfer_private_to_private_public_nft_fail() {
    // Setup and mint NFT to owner in public state
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, recipient) =
        utils::setup_and_mint_to_public(false, token_id);

    // Verify NFT is in public state
    utils::assert_owns_public_nft(env, nft_contract_address, owner, token_id);

    // Attempt to transfer from private state when NFT is actually in public state
    env.impersonate(owner);
    NFT::at(nft_contract_address).transfer_private_to_private(owner, recipient, token_id, 0).call(
        &mut env.private(),
    );
}
