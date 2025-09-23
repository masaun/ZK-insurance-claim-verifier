use crate::test::utils::{self, mint_amount};
use crate::Token;
use authwit::cheatcodes as authwit_cheatcodes;
use aztec::oracle::random::random;

#[test]
unconstrained fn transfer_private_to_commitment() {
    let (env, token_contract_address, owner, recipient) =
        utils::setup_and_mint_to_private_without_minter(false);

    utils::check_private_balance(token_contract_address, owner, mint_amount);
    utils::check_private_balance(token_contract_address, recipient, 0 as u128);

    // Prepare commitment
    env.impersonate(recipient);
    let commitment = Token::at(token_contract_address)
        .initialize_transfer_commitment(recipient, recipient)
        .call(&mut env.private());

    // Transfer tokens
    let transfer_amount = mint_amount;
    env.impersonate(owner);
    Token::at(token_contract_address)
        .transfer_private_to_commitment(owner, commitment, transfer_amount, 0)
        .call(&mut env.private());
    env.advance_block_by(1);

    // Check balances
    utils::check_private_balance(token_contract_address, owner, 0 as u128);
    utils::check_private_balance(token_contract_address, recipient, transfer_amount);
}

#[test]
unconstrained fn transfer_private_to_commitment_on_behalf_of_other() {
    let (env, token_contract_address, owner, recipient) =
        utils::setup_and_mint_to_private_without_minter(true);

    utils::check_private_balance(token_contract_address, owner, mint_amount);
    utils::check_private_balance(token_contract_address, recipient, 0 as u128);

    let transfer_amount = mint_amount;

    // Prepare commitment
    env.impersonate(recipient);
    let commitment = Token::at(token_contract_address)
        .initialize_transfer_commitment(recipient, recipient)
        .call(&mut env.private());
    env.advance_block_by(1);

    let transfer_to_commitment_call_interface = Token::at(token_contract_address)
        .transfer_private_to_commitment(owner, commitment, transfer_amount, 0);

    authwit_cheatcodes::add_private_authwit_from_call_interface(
        owner,
        recipient,
        transfer_to_commitment_call_interface,
    );

    // Transfer tokens
    env.impersonate(recipient);
    transfer_to_commitment_call_interface.call(&mut env.private());
    env.advance_block_by(1);

    // Check balances
    utils::check_private_balance(token_contract_address, owner, 0 as u128);
    utils::check_private_balance(token_contract_address, recipient, transfer_amount);
}
