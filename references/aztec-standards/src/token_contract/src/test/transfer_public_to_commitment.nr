use crate::{test::utils::{self, mint_amount}, Token};
use aztec::oracle::random::random;
use std::test::OracleMock;

/// Internal orchestration means that the calls to `initialize_transfer_commitment`
/// and `transfer_public_to_commitment` are done by the TOKEN contract itself.
/// In this test's case this is done by the `Token::transfer_public_to_commitment(...)` function called
/// in `utils::setup_mint_and_transfer_public_to_commitment`.
#[test]
unconstrained fn transfer_public_to_commitment_internal_orchestration() {
    // The transfer to private is done in `utils::setup_and_mint_to_private_without_minter` and for this reason
    // in this test we just call it and check the outcome.
    // Setup without account contracts. We are not using authwits here, so dummy accounts are enough
    let (_, token_contract_address, user, _) =
        utils::setup_and_mint_to_private_without_minter(false);

    // User's private balance should be equal to the amount
    utils::check_private_balance(token_contract_address, user, mint_amount);
}

/// External orchestration means that the calls to prepare and finalize are not done by the Token contract. This flow
/// will typically be used by a DEX.
#[test]
unconstrained fn transfer_public_to_commitment_external_orchestration() {
    // Setup without account contracts. We are not using authwits here, so dummy accounts are enough
    let (env, token_contract_address, owner, recipient) =
        utils::setup_and_mint_to_public_without_minter(false);

    let note_randomness = random();

    // We mock the Oracle to return the note randomness such that later on we can manually add the note
    let _ = OracleMock::mock("getRandomField").returns(note_randomness);

    // We prepare the transfer
    let commitment = Token::at(token_contract_address)
        .initialize_transfer_commitment(owner, recipient)
        .call(&mut env.private());

    // Finalize the transfer of the tokens (message sender owns the tokens in public)
    Token::at(token_contract_address)
        .transfer_public_to_commitment(owner, commitment, mint_amount, 0)
        .call(&mut env.public());

    env.advance_block_by(1);

    // Recipient's private balance should be equal to the amount
    utils::check_private_balance(token_contract_address, recipient, mint_amount);
}

#[test(should_fail_with = "Invalid commitment")]
unconstrained fn transfer_public_to_commitment_transfer_not_initialized() {
    // Setup without account contracts. We are not using authwits here, so dummy accounts are enough
    let (env, token_contract_address, owner, _) =
        utils::setup_and_mint_to_public_without_minter(false);

    // Transfer was not prepared, so we can use a random value for the commitment
    let commitment = random();

    // Try finalizing the transfer without preparing it first
    Token::at(token_contract_address)
        .transfer_public_to_commitment(owner, commitment, mint_amount, 0)
        .call(&mut env.public());
}

#[test(should_fail_with = "attempt to subtract with overflow 'public_balances.at(from).read() - amount'")]
unconstrained fn transfer_public_to_commitment_failure_not_an_owner() {
    // Setup without account contracts. We are not using authwits here, so dummy accounts are enough
    let (env, token_contract_address, owner, not_owner) =
        utils::setup_and_mint_to_public_without_minter(false);

    // (For this specific test we could set a random value for the commitment and not do the call to `prepare...`
    // as the token balance check is before we use the value but that would made the test less robust against changes
    // in the contract.)
    let commitment = Token::at(token_contract_address)
        .initialize_transfer_commitment(owner, not_owner)
        .call(&mut env.private());

    // Try transferring someone else's token balance
    env.impersonate(not_owner);
    Token::at(token_contract_address)
        .transfer_public_to_commitment(not_owner, commitment, mint_amount, 0)
        .call(&mut env.public());
}
