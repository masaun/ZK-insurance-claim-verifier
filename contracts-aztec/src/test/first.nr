use crate::test::utils;
use dep::aztec::oracle::{execution::get_block_number, storage::storage_read};
use dep::aztec::protocol_types::storage::map::derive_storage_slot_in_map;

use crate::ConfidentialPayrollManagement;
//use crate::EasyPrivateVoting;

// @dev - Import the token_contract
use token::Token;

#[test]
unconstrained fn test_initializer() {
    let with_account_contracts = false; // @dev - For the token_contract's test setup function

    let (_, confidential_payroll_management_contract_address, admin, token_contract_address, owner, recipient) = utils::setup(with_account_contracts);

    let block_number = get_block_number();
    let admin_slot = ConfidentialPayrollManagement::storage_layout().admin.slot;
    //let admin_slot = EasyPrivateVoting::storage_layout().admin.slot;
    let admin_storage_value = storage_read(confidential_payroll_management_contract_address, admin_slot, block_number);
    assert(admin_storage_value == admin, "Vote ended should be false");
}

#[test]
unconstrained fn test_check_vote_status() {
     let with_account_contracts = false; // @dev - For the token_contract's test setup function
     let (_, confidential_payroll_management_contract_address, _, token_contract_address, owner, recipient) = utils::setup(with_account_contracts);

    let vote_ended_expected: bool = false;

    let block_number = get_block_number();
    let status_slot = ConfidentialPayrollManagement::storage_layout().vote_ended.slot;
    //let status_slot = EasyPrivateVoting::storage_layout().vote_ended.slot;
    let vote_ended_read: bool = storage_read(confidential_payroll_management_contract_address, status_slot, block_number);
    assert(vote_ended_expected == vote_ended_read, "Vote ended should be false");
}

#[test]
unconstrained fn test_end_vote() {
    let with_account_contracts = false; // @dev - For the token_contract's test setup function
    let (env, confidential_payroll_management_contract_address, admin, token_contract_address, owner, recipient) = utils::setup(with_account_contracts);

    env.impersonate(admin);
    ConfidentialPayrollManagement::at(confidential_payroll_management_contract_address).end_vote().call(&mut env.public());
    //EasyPrivateVoting::at(confidential_payroll_management_contract_address).end_vote().call(&mut env.public());

    let vote_ended_expected = true;

    let block_number = get_block_number();
    let status_slot = ConfidentialPayrollManagement::storage_layout().vote_ended.slot;
    //let status_slot = EasyPrivateVoting::storage_layout().vote_ended.slot;
    let vote_ended_read: bool = storage_read(confidential_payroll_management_contract_address, status_slot, block_number);
    assert(vote_ended_expected == vote_ended_read, "Vote ended should be true");
}

#[test(should_fail)]
unconstrained fn test_fail_end_vote_by_non_admin() {
    let with_account_contracts = false; // @dev - For the token_contract's test setup function

    let (env, confidential_payroll_management_contract_address, _, token_contract_address, owner, recipient) = utils::setup(with_account_contracts);
    let alice = env.create_account(2);

    env.impersonate(alice);
    ConfidentialPayrollManagement::at(confidential_payroll_management_contract_address).end_vote().call(&mut env.public());
    //EasyPrivateVoting::at(confidential_payroll_management_contract_address).end_vote().call(&mut env.public());
}

#[test]
unconstrained fn test_cast_vote() {
    let with_account_contracts = false; // @dev - For the token_contract's test setup function

    let (env, confidential_payroll_management_contract_address, _, token_contract_address, owner, recipient) = utils::setup(with_account_contracts);
    let alice = env.create_account(2);
    env.impersonate(alice);

    let candidate = 1;
    env.advance_block_by(6);
    ConfidentialPayrollManagement::at(confidential_payroll_management_contract_address).cast_vote(candidate).call(&mut env.private());
    //EasyPrivateVoting::at(confidential_payroll_management_contract_address).cast_vote(candidate).call(&mut env.private());

    // Read vote count from storage
    let block_number = get_block_number();
    let tally_slot = ConfidentialPayrollManagement::storage_layout().tally.slot;
    //let tally_slot = EasyPrivateVoting::storage_layout().tally.slot;
    let candidate_tally_slot = derive_storage_slot_in_map(tally_slot, candidate);
    let vote_count: u32 = storage_read(confidential_payroll_management_contract_address, candidate_tally_slot, block_number);

    assert(vote_count == 1, "vote tally should be incremented");
}

#[test]
unconstrained fn test_cast_vote_with_separate_accounts() {
    let with_account_contracts = false; // @dev - For the token_contract's test setup function

    let (env, confidential_payroll_management_contract_address, _, token_contract_address, owner, recipient) = utils::setup(with_account_contracts);
    let alice = env.create_account(2);
    let bob = env.create_account(3);

    let candidate = 101;

    env.impersonate(alice);
    env.advance_block_by(1);
    ConfidentialPayrollManagement::at(confidential_payroll_management_contract_address).cast_vote(candidate).call(&mut env.private());
    //EasyPrivateVoting::at(confidential_payroll_management_contract_address).cast_vote(candidate).call(&mut env.private());

    env.impersonate(bob);
    env.advance_block_by(1);
    ConfidentialPayrollManagement::at(confidential_payroll_management_contract_address).cast_vote(candidate).call(&mut env.private());
    //EasyPrivateVoting::at(confidential_payroll_management_contract_address).cast_vote(candidate).call(&mut env.private());

    // Read vote count from storage
    let block_number = get_block_number();
    let tally_slot = ConfidentialPayrollManagement::storage_layout().tally.slot;
    //let tally_slot = EasyPrivateVoting::storage_layout().tally.slot;
    let candidate_tally_slot = derive_storage_slot_in_map(tally_slot, candidate);
    let vote_count: u32 = storage_read(confidential_payroll_management_contract_address, candidate_tally_slot, block_number);

    assert(vote_count == 2, "vote tally should be 2");
}

#[test(should_fail)]
unconstrained fn test_fail_vote_twice() {
    let with_account_contracts = false; // @dev - For the token_contract's test setup function

    let (env, confidential_payroll_management_contract_address, _, token_contract_address, owner, recipient) = utils::setup(with_account_contracts);
    let alice = env.create_account(2);

    let candidate = 101;

    env.impersonate(alice);
    env.advance_block_by(1);
    ConfidentialPayrollManagement::at(confidential_payroll_management_contract_address).cast_vote(candidate).call(&mut env.private());
    //EasyPrivateVoting::at(confidential_payroll_management_contract_address).cast_vote(candidate).call(&mut env.private());

    // Vote again as alice
    env.advance_block_by(1);
    ConfidentialPayrollManagement::at(confidential_payroll_management_contract_address).cast_vote(candidate).call(&mut env.private());
    //EasyPrivateVoting::at(confidential_payroll_management_contract_address).cast_vote(candidate).call(&mut env.private());
}
