use crate::NFT;
use crate::test::utils;
use authwit::cheatcodes as authwit_cheatcodes;
use aztec::prelude::AztecAddress;

#[test]
unconstrained fn nft_transfer_public_to_private_success() {
    // Setup and mint NFT to owner in public state
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, recipient) =
        utils::setup_and_mint_to_public(false, token_id);

    // Verify initial ownership state
    utils::assert_owns_public_nft(env, nft_contract_address, owner, token_id);

    // Transfer NFT from public to private state
    env.impersonate(owner);
    NFT::at(nft_contract_address).transfer_public_to_private(owner, recipient, token_id, 0).call(
        &mut env.private(),
    );
    env.advance_block_by(1);

    // Verify the NFT is no longer owned publicly by owner
    utils::assert_owns_public_nft(env, nft_contract_address, AztecAddress::zero(), token_id);
    // Verify the NFT is now owned privately by recipient
    utils::assert_owns_private_nft(nft_contract_address, recipient, token_id);
}

#[test]
unconstrained fn nft_transfer_public_to_private_authorized_success() {
    // Setup with account contracts (needed for authwits) and mint NFT to owner
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, recipient) =
        utils::setup_and_mint_to_public(true, token_id);

    // Create the transfer call interface
    let transfer_call_interface =
        NFT::at(nft_contract_address).transfer_public_to_private(owner, recipient, token_id, 1);

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

    // Verify the NFT is no longer owned publicly by owner
    utils::assert_owns_public_nft(env, nft_contract_address, AztecAddress::zero(), token_id);
    // Verify the NFT is now owned privately by recipient
    utils::assert_owns_private_nft(nft_contract_address, recipient, token_id);
}

#[test(should_fail_with = "caller is not owner")]
unconstrained fn nft_transfer_public_to_private_not_owned_fail() {
    // Setup environment but don't mint the NFT
    let (env, nft_contract_address, owner, _, recipient) = utils::setup_with_minter(false);
    let non_existent_token_id = 12345;

    // Attempt to transfer a token that doesn't exist / isn't owned
    env.impersonate(owner);
    NFT::at(nft_contract_address)
        .transfer_public_to_private(owner, recipient, non_existent_token_id, 0)
        .call(&mut env.private());
}

#[test(should_fail_with = "Unknown auth witness for message hash")]
unconstrained fn nft_transfer_public_to_private_unauthorized_fail() {
    // Setup with account contracts for proper authorization testing
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, recipient) =
        utils::setup_and_mint_to_public(true, token_id);

    // Create transfer interface with non-zero nonce (indicating authorization needed)
    let transfer_call_interface =
        NFT::at(nft_contract_address).transfer_public_to_private(owner, recipient, token_id, 1);

    // Impersonate recipient but DON'T add authorization witness
    // This test verifies that without an authorization witness (authwit),
    // the recipient cannot transfer the NFT on behalf of the owner
    env.impersonate(recipient);
    transfer_call_interface.call(&mut env.private());
}
