use crate::NFT;
use crate::test::utils;
use aztec::{
    oracle::{execution::get_block_number, storage::storage_read},
    prelude::AztecAddress,
    test::helpers::cheatcodes,
};

#[test]
unconstrained fn nft_minter_is_set() {
    let (_, nft_contract_address, _, minter, _) = utils::setup_with_minter(false);
    cheatcodes::set_contract_address(nft_contract_address);
    let minter_slot = NFT::storage_layout().minter.slot;
    let minter_address: AztecAddress =
        storage_read(nft_contract_address, minter_slot, get_block_number());
    assert(minter_address == minter, "minter is not set");
}
