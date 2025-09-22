use crate::NFT;
use crate::test::utils;

#[test]
unconstrained fn nft_initialize_transfer_commitment_success() {
    // Setup with NFT in private state
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, recipient) =
        utils::setup_and_mint_to_private(false, token_id);

    // Initialize transfer commitment
    env.impersonate(owner);
    let commitment = NFT::at(nft_contract_address)
        .initialize_transfer_commitment(owner, recipient)
        .call(&mut env.private());
    env.advance_block_by(1);

    // Verify commitment is stored
    assert(utils::get_commitment_stored(nft_contract_address, commitment), "Commitment not stored");
}

#[test]
unconstrained fn nft_initialize_transfer_commitment_by_recipient_success() {
    // Setup with NFT in private state
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, recipient) =
        utils::setup_and_mint_to_private(false, token_id);

    // Initialize transfer commitment as recipient
    env.impersonate(recipient);
    let commitment = NFT::at(nft_contract_address)
        .initialize_transfer_commitment(owner, recipient)
        .call(&mut env.private());
    env.advance_block_by(1);

    // Verify commitment is stored
    assert(utils::get_commitment_stored(nft_contract_address, commitment), "Commitment not stored");
}

#[test]
unconstrained fn nft_initialize_transfer_commitment_self_success() {
    // Setup with NFT in private state
    let token_id = 10000;
    let (env, nft_contract_address, owner, _, _) =
        utils::setup_and_mint_to_private(false, token_id);

    // Initialize transfer commitment to self
    env.impersonate(owner);
    let commitment = NFT::at(nft_contract_address)
        .initialize_transfer_commitment(owner, owner)
        .call(&mut env.private());
    env.advance_block_by(1);

    // Verify commitment is stored
    assert(utils::get_commitment_stored(nft_contract_address, commitment), "Commitment not stored");
}

#[test]
unconstrained fn nft_initialize_transfer_commitment_by_third_party_success() {
    // Setup with NFT in private state
    let token_id = 10000;
    let (env, nft_contract_address, owner, minter, recipient) =
        utils::setup_and_mint_to_private(false, token_id);

    // Initialize transfer commitment as minter (third party)
    env.impersonate(minter);
    let commitment = NFT::at(nft_contract_address)
        .initialize_transfer_commitment(owner, recipient)
        .call(&mut env.private());
    env.advance_block_by(1);

    // Verify commitment is stored
    assert(utils::get_commitment_stored(nft_contract_address, commitment), "Commitment not stored");
}
