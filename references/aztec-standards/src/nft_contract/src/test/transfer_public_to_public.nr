use crate::NFT;
use crate::test::utils;
use authwit::cheatcodes as authwit_cheatcodes;

#[test]
unconstrained fn nft_transfer_public_to_public_success() {
    // Setup and mint NFT to owner
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, recipient) =
        utils::setup_and_mint_to_public(false, token_id);

    // Transfer NFT from owner to recipient
    env.impersonate(owner);
    NFT::at(nft_contract_address).transfer_public_to_public(owner, recipient, token_id, 0).call(
        &mut env.public(),
    );
    env.advance_block_by(1);

    // Verify recipient now owns the NFT
    utils::assert_owns_public_nft(env, nft_contract_address, recipient, token_id);
}

#[test]
unconstrained fn nft_transfer_public_to_public_self_success() {
    // Setup and mint NFT to owner
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, _) = utils::setup_and_mint_to_public(false, token_id);

    // Transfer NFT from owner to self
    env.impersonate(owner);
    NFT::at(nft_contract_address).transfer_public_to_public(owner, owner, token_id, 0).call(
        &mut env.public(),
    );
    env.advance_block_by(1);

    // Verify owner still owns the NFT
    utils::assert_owns_public_nft(env, nft_contract_address, owner, token_id);
}

#[test]
unconstrained fn nft_transfer_public_to_public_authorized_success() {
    // Setup with account contracts (needed for authwits) and mint NFT to owner
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, recipient) =
        utils::setup_and_mint_to_public(true, token_id);

    // Create the transfer call interface
    let transfer_call_interface =
        NFT::at(nft_contract_address).transfer_public_to_public(owner, recipient, token_id, 1);

    // Add authorization witness from owner to recipient
    authwit_cheatcodes::add_public_authwit_from_call_interface(
        owner,
        recipient,
        transfer_call_interface,
    );

    // Impersonate recipient to perform the authorized transfer
    env.impersonate(recipient);
    transfer_call_interface.call(&mut env.public());
    env.advance_block_by(1);

    // Verify recipient now owns the NFT
    utils::assert_owns_public_nft(env, nft_contract_address, recipient, token_id);
    // Verify the NFT is no longer owned by the previous owner
    let cur_owner = NFT::at(nft_contract_address).public_owner_of(token_id).view(&mut env.public());
    assert(owner != cur_owner, "incorrect NFT owner");
}

#[test(should_fail_with = "caller is not owner")]
unconstrained fn nft_transfer_public_to_public_non_existent_fail() {
    // Setup environment but don't mint the NFT
    let (env, nft_contract_address, owner, _, recipient) = utils::setup_with_minter(false);
    let non_existent_token_id = 12345;

    // Attempt to transfer a non-existent NFT
    env.impersonate(owner);
    NFT::at(nft_contract_address)
        .transfer_public_to_public(owner, recipient, non_existent_token_id, 0)
        .call(&mut env.public());
}

#[test(should_fail_with = "unauthorized")]
unconstrained fn nft_transfer_public_to_public_unauthorized_fail() {
    // Setup with account contracts for proper authorization testing
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, recipient) =
        utils::setup_and_mint_to_public(true, token_id);

    // Create transfer interface with non-zero nonce (indicating authorization needed)
    let transfer_call_interface =
        NFT::at(nft_contract_address).transfer_public_to_public(owner, recipient, token_id, 1);

    // Impersonate recipient but DON'T add authorization witness
    // This test verifies that without an authorization witness (authwit),
    // the recipient cannot transfer the NFT on behalf of the owner
    env.impersonate(recipient);

    // Should fail because recipient has no authorization witness from owner
    transfer_call_interface.call(&mut env.public());
}

#[test(should_fail_with = "unauthorized")]
unconstrained fn nft_transfer_public_to_public_wrong_authwit_fail() {
    // Setup with account contracts for proper authorization testing
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, recipient) =
        utils::setup_and_mint_to_public(true, token_id);

    // Create transfer interface with non-zero nonce (indicating authorization needed)
    let transfer_call_interface =
        NFT::at(nft_contract_address).transfer_public_to_public(owner, recipient, token_id, 1);

    // Add authorization witness but to the OWNER instead of the recipient
    // This simulates giving authorization to the wrong address
    authwit_cheatcodes::add_public_authwit_from_call_interface(
        owner,
        owner, // Wrong address - should be recipient
        transfer_call_interface,
    );

    // Impersonate recipient
    env.impersonate(recipient);

    // Should fail because the authorization witness was given to the wrong address
    transfer_call_interface.call(&mut env.public());
}
