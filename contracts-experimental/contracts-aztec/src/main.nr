mod test;

use dep::aztec::macros::aztec;

/**
 * @title - Confidential Payroll Management Contract
 * @dev - ref.token_contract: https://github.com/AztecProtocol/aztec-packages/blob/v1.2.0/noir-projects/noir-contracts/contracts/app/token_contract/src/test/utils.nr#L144
 */
#[aztec]
pub contract ConfidentialPayrollManagement {
//pub contract EasyPrivateVoting {
    use dep::aztec::{
        keys::getters::get_public_keys,
        macros::{functions::{initializer, internal, private, public, utility}, storage::storage},
    };
    use dep::aztec::prelude::{AztecAddress, Map, PublicImmutable, PublicMutable};
    use dep::aztec::protocol_types::traits::{Hash, ToField};
    
    use token::Token; // @dev - Import the Token contract

    #[storage]
    struct Storage<Context> {
        admin: PublicMutable<AztecAddress, Context>, // admin can end vote
        tally: Map<Field, PublicMutable<Field, Context>, Context>, // we will store candidate as key and number of votes as value
        vote_ended: PublicMutable<bool, Context>, // vote_ended is boolean
        active_at_block: PublicImmutable<u32, Context>, // when people can start voting
        usdc_token_address: PublicImmutable<AztecAddress, Context>, // USDC token address
    }

    #[public]
    #[initializer]
    // annotation to mark function as a constructor
    fn constructor(admin: AztecAddress, usdc_token_address: AztecAddress) {
        storage.admin.write(admin);
        storage.vote_ended.write(false);
        storage.active_at_block.initialize(context.block_number());
        storage.usdc_token_address.initialize(usdc_token_address);
    }

    /**
     * @notice - Transfer the Confidential Token to an employer
     * @dev - ref.token_contract: https://github.com/AztecProtocol/aztec-packages/blob/v1.2.0/noir-projects/noir-contracts/contracts/app/token_contract/src/test/utils.nr#L144
     */
    #[private]
    fn transfer_confidential_token(employer: AztecAddress) -> Field {
    //fn get_confidential_token_balance_of_contract(employer: AztecAddress) -> Field {
        // [TODO]:balance_of_private(owner: AztecAddress)
        let usdc_token = Token::at(storage.usdc_token_address.read());
        let _udsc_balance_of_contract = usdc_token.transfer(employer, 1).call(&mut context);
        //let usdc_balance_of_contract = _udsc_balance_of_contract as Field;
        //let usdc_balance_of_contract = usdc_token.balance_of_private(employer);
        //println(f"Confidential Token balance of contract: {usdc_balance_of_contract}\n");
        //usdc_balance_of_contract
        1
    }

    #[private]
    // annotation to mark function as private and expose private context
    fn cast_vote(candidate: Field) {
        let msg_sender_npk_m_hash = get_public_keys(context.msg_sender()).npk_m.hash();

        let secret = context.request_nsk_app(msg_sender_npk_m_hash); // get secret key of caller of function
        let nullifier = std::hash::pedersen_hash([context.msg_sender().to_field(), secret]); // derive nullifier from sender and secret
        context.push_nullifier(nullifier);
        ConfidentialPayrollManagement::at(context.this_address()).add_to_tally_public(candidate).enqueue(
        //EasyPrivateVoting::at(context.this_address()).add_to_tally_public(candidate).enqueue(
            &mut context,
        );
    }

    #[public]
    #[internal]
    fn add_to_tally_public(candidate: Field) {
        assert(storage.vote_ended.read() == false, "Vote has ended"); // assert that vote has not ended
        let new_tally = storage.tally.at(candidate).read() + 1;
        storage.tally.at(candidate).write(new_tally);
    }

    #[public]
    fn end_vote() {
        assert(storage.admin.read().eq(context.msg_sender()), "Only admin can end votes"); // assert that caller is admin
        storage.vote_ended.write(true);
    }
    #[utility]
    unconstrained fn get_vote(candidate: Field) -> Field {
        storage.tally.at(candidate).read()
    }
}
