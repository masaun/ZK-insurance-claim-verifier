use crate::test::utils;
use crate::Token;

#[test]
unconstrained fn initialize_transfer_commitment() {
    let (env, token_contract_address, owner, recipient) =
        utils::setup_and_mint_to_private_without_minter(false);

    // Transfer tokens
    env.impersonate(owner);
    let commitment = Token::at(token_contract_address)
        .initialize_transfer_commitment(owner, recipient)
        .call(&mut env.private());
    env.advance_block_by(1);

    // Check that the commitment has been stored
    assert(
        utils::_commitment_storage_read(token_contract_address, commitment.commitment()),
        "Commitment not stored",
    );
}
