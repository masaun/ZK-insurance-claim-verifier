use crate::NFT;
use crate::test::utils;
use compressed_string::FieldCompressedString;

#[test]
unconstrained fn nft_name_is_set() {
    let (env, nft_contract_address, _, _, _) = utils::setup_with_minter(false);

    let name = NFT::at(nft_contract_address).public_get_name().view(&mut env.public());
    let expected_name = FieldCompressedString::from_string("TestNFT000000000000000000000000");
    assert(name == expected_name, "name is not set correctly");
}

#[test]
unconstrained fn nft_symbol_is_set() {
    let (env, nft_contract_address, _, _, _) = utils::setup_with_minter(false);

    let symbol = NFT::at(nft_contract_address).public_get_symbol().view(&mut env.public());
    let expected_symbol = FieldCompressedString::from_string("TNFT000000000000000000000000000");
    assert(symbol == expected_symbol, "symbol is not set correctly");
}
