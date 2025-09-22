use crate::test::utils::{self, mint_amount};
use crate::Token;
use authwit::cheatcodes as authwit_cheatcodes;
use aztec::{note::constants::MAX_NOTES_PER_PAGE, oracle::random::random};
use uint_note::uint_note::UintNote;

#[test]
unconstrained fn transfer_private_to_public_on_behalf_of_self() {
    // Setup without account contracts. We are not using authwits here, so dummy accounts are enough
    let (env, token_contract_address, owner, _) =
        utils::setup_and_mint_to_private_without_minter(false);

    let transfer_private_to_public_amount = mint_amount / (10 as u128);
    Token::at(token_contract_address)
        .transfer_private_to_public(owner, owner, transfer_private_to_public_amount, 0)
        .call(&mut env.private());
    utils::check_private_balance(
        token_contract_address,
        owner,
        mint_amount - transfer_private_to_public_amount,
    );
    utils::check_public_balance(
        token_contract_address,
        owner,
        transfer_private_to_public_amount,
    );
}

#[test]
unconstrained fn transfer_private_to_public_on_behalf_of_other() {
    let (env, token_contract_address, owner, recipient) =
        utils::setup_and_mint_to_private_without_minter(true);

    let transfer_private_to_public_amount = mint_amount / (10 as u128);
    let transfer_private_to_public_call_interface = Token::at(token_contract_address)
        .transfer_private_to_public(owner, recipient, transfer_private_to_public_amount, 0);
    authwit_cheatcodes::add_private_authwit_from_call_interface(
        owner,
        recipient,
        transfer_private_to_public_call_interface,
    );
    // Impersonate recipient
    env.impersonate(recipient);
    // transfer_private_to_public tokens
    transfer_private_to_public_call_interface.call(&mut env.private());
    utils::check_private_balance(
        token_contract_address,
        owner,
        mint_amount - transfer_private_to_public_amount,
    );
    utils::check_public_balance(
        token_contract_address,
        recipient,
        transfer_private_to_public_amount,
    );
}

// TODO: Can't figure out why this test is failing
// #[test]
unconstrained fn transfer_private_to_public_multiple_notes_recursively() {
    // Setup with account contracts. Slower since we actually deploy them, but needed for authwits.
    let (env, token_contract_address, owner, recipient, minter) = utils::setup_with_minter(true);

    let notes_amount = 1000 as u128;
    let notes_count = 12;
    let total_amount = notes_amount * notes_count;
    env.impersonate(minter);
    for _ in 0..notes_count {
        utils::mint_to_private(env, token_contract_address, owner, notes_amount);
    }

    // Transfer tokens
    // Transfer will require 11 notes with change, which requires 2 recursive calls: 2 + 8 + 1
    env.impersonate(owner);
    let transfer_amount = total_amount - notes_amount - (1 as u128);
    let transfer_private_from_call_interface = Token::at(token_contract_address)
        .transfer_private_to_public(owner, recipient, transfer_amount, 0);
    transfer_private_from_call_interface.call(&mut env.private());
    env.advance_block_by(1);

    // Check that the notes still owned by the owner are correct
    let final_owner_notes: BoundedVec<UintNote, MAX_NOTES_PER_PAGE> =
        utils::get_private_balance_notes(token_contract_address, owner, 0);

    assert(final_owner_notes.len() == 2, "Incorrect note count"); // 1000 UintNote x1 and 1 UintNote x1
    assert(final_owner_notes.get(0).get_value() == notes_amount, "Incorrect note amount");
    assert(final_owner_notes.get(1).get_value() == 1 as u128, "Incorrect note change amount");

    // Check that the notes generated to the recipient are correct
    let recipient_notes: BoundedVec<UintNote, MAX_NOTES_PER_PAGE> =
        utils::get_private_balance_notes(token_contract_address, recipient, 0);
    assert(recipient_notes.len() == 0, "Incorrect transferred note count");

    // Check balances
    utils::check_private_balance(
        token_contract_address,
        owner,
        total_amount - transfer_amount,
    );
    utils::check_public_balance(token_contract_address, recipient, transfer_amount);
}

#[test(should_fail_with = "Balance too low")]
unconstrained fn transfer_private_to_public_failure_more_than_balance() {
    // Setup without account contracts. We are not using authwits here, so dummy accounts are enough
    let (env, token_contract_address, owner, _) =
        utils::setup_and_mint_to_private_without_minter(false);

    let transfer_private_to_public_amount = mint_amount + (1 as u128);
    Token::at(token_contract_address)
        .transfer_private_to_public(owner, owner, transfer_private_to_public_amount, 0)
        .call(&mut env.private());
}

#[test(should_fail_with = "Balance too low")]
unconstrained fn transfer_private_to_public_failure_on_behalf_of_other_more_than_balance() {
    let (env, token_contract_address, owner, recipient) =
        utils::setup_and_mint_to_private_without_minter(true);

    let transfer_private_to_public_amount = mint_amount + (1 as u128);
    let transfer_private_to_public_call_interface = Token::at(token_contract_address)
        .transfer_private_to_public(owner, recipient, transfer_private_to_public_amount, 0);
    authwit_cheatcodes::add_private_authwit_from_call_interface(
        owner,
        recipient,
        transfer_private_to_public_call_interface,
    );
    // Impersonate recipient
    env.impersonate(recipient);
    // transfer_private_to_public tokens
    transfer_private_to_public_call_interface.call(&mut env.private());
}

#[test(should_fail_with = "Unknown auth witness for message hash")]
unconstrained fn transfer_private_to_public_failure_on_behalf_of_other_invalid_designated_caller() {
    let (env, token_contract_address, owner, recipient) =
        utils::setup_and_mint_to_private_without_minter(true);

    let transfer_private_to_public_amount = mint_amount + (1 as u128);
    let transfer_private_to_public_call_interface = Token::at(token_contract_address)
        .transfer_private_to_public(owner, recipient, transfer_private_to_public_amount, 0);
    authwit_cheatcodes::add_private_authwit_from_call_interface(
        owner,
        owner,
        transfer_private_to_public_call_interface,
    );
    // Impersonate recipient
    env.impersonate(recipient);
    // transfer_private_to_public tokens
    transfer_private_to_public_call_interface.call(&mut env.private());
}

#[test(should_fail_with = "Unknown auth witness for message hash")]
unconstrained fn transfer_private_to_public_failure_on_behalf_of_other_no_approval() {
    let (env, token_contract_address, owner, recipient) =
        utils::setup_and_mint_to_private_without_minter(true);

    let transfer_private_to_public_amount = mint_amount + (1 as u128);
    let transfer_private_to_public_call_interface = Token::at(token_contract_address)
        .transfer_private_to_public(owner, recipient, transfer_private_to_public_amount, 0);
    // Impersonate recipient
    env.impersonate(recipient);
    // transfer_private_to_public tokens
    transfer_private_to_public_call_interface.call(&mut env.private());
}
