mod types;
mod test;

use aztec::macros::aztec;

#[aztec]
pub contract NFT {
    // aztec library
    use aztec::{
        context::PrivateContext,
        macros::{
            functions::{initializer, internal, private, public, utility, view},
            storage::storage,
        },
        messages::logs::note::encode_and_encrypt_note,
        note::{constants::MAX_NOTES_PER_PAGE, note_interface::NoteProperties},
        prelude::{
            AztecAddress, Map, NoteGetterOptions, NoteViewerOptions, PrivateSet, PublicContext,
            PublicImmutable, PublicMutable,
        },
        protocol_types::{
            constants::DEPLOYER_CONTRACT_ADDRESS, contract_class_id::ContractClassId,
            traits::FromField,
        },
        utils::comparison::Comparator,
    };
    // authorized witness library
    use authwit::auth::{
        assert_current_call_valid_authwit, assert_current_call_valid_authwit_public,
    };
    // compression library
    use compressed_string::FieldCompressedString;
    // contract instance deployer
    use contract_instance_deployer::ContractInstanceDeployer;
    // nft note structs
    use crate::types::nft_note::{NFTNote, PartialNFTNote};

    /// @param symbol The symbol of the NFT
    /// @param name The name of the NFT
    /// @param private_nfts A map from address to a private set of NFTNotes owned by that address
    /// @param nft_exists A map from token ID to a boolean indicating if the NFT exists
    /// @param public_owners A map from token ID to the public owner of the NFT
    /// @param minter The address that can mint
    #[storage]
    struct Storage<Context> {
        symbol: PublicImmutable<FieldCompressedString, Context>,
        name: PublicImmutable<FieldCompressedString, Context>,
        private_nfts: Map<AztecAddress, PrivateSet<NFTNote, Context>, Context>,
        nft_exists: Map<Field, PublicMutable<bool, Context>, Context>,
        public_owners: Map<Field, PublicMutable<AztecAddress, Context>, Context>,
        minter: PublicImmutable<AztecAddress, Context>,
        upgrade_authority: PublicImmutable<AztecAddress, Context>,
    }

    /// @dev Initializes the token with a minter
    /// @param name The name of the NFT
    /// @param symbol The symbol of the NFT
    /// @param minter The address of the minter
    #[public]
    #[initializer]
    fn constructor_with_minter(
        name: str<31>,
        symbol: str<31>,
        minter: AztecAddress,
        upgrade_authority: AztecAddress,
    ) {
        storage.name.initialize(FieldCompressedString::from_string(name));
        storage.symbol.initialize(FieldCompressedString::from_string(symbol));
        storage.minter.initialize(minter);
        storage.upgrade_authority.initialize(upgrade_authority);
    }

    /** ==========================================================
     * ========================= PRIVATE =========================
     * ======================================================== */

    /// @notice Transfers token by id from private owner to a public owner
    /// @dev Removes token from private owner, and enqueues a public call to update the public owner
    /// @param from The address of the sender
    /// @param to The address of the recipient
    /// @param token_id The id of the token to transfer
    /// @param _nonce The nonce used for authwitness
    #[private]
    fn transfer_private_to_public(
        from: AztecAddress,
        to: AztecAddress,
        token_id: Field,
        _nonce: Field,
    ) {
        _validate_from_private(&mut context, from);

        _remove_private_token_owner(storage.private_nfts.at(from), token_id);
        NFT::at(context.this_address())
            .update_public_token_owner_from_zero_internal(to, token_id)
            .enqueue(&mut context);
    }

    /// @notice Transfers token by id from private owner to a public owner with a commitment
    /// @dev Removes token from private owner, enqueues a public call to update the public owner, and returns a commitment
    /// @param from The address of the sender
    /// @param to The address of the recipient
    /// @param token_id The id of the token to transfer
    /// @param _nonce The nonce used for authwitness
    /// @return commitment The partial nft note utilized for the transfer commitment (privacy entrance)
    #[private]
    fn transfer_private_to_public_with_commitment(
        from: AztecAddress,
        to: AztecAddress,
        token_id: Field,
        _nonce: Field,
    ) -> Field {
        _validate_from_private(&mut context, from);

        _remove_private_token_owner(storage.private_nfts.at(from), token_id);
        NFT::at(context.this_address())
            .update_public_token_owner_from_zero_internal(to, token_id)
            .enqueue(&mut context);
        let commitment =
            _initialize_transfer_commitment(&mut context, storage.private_nfts, from, to);
        commitment.commitment()
    }

    /// @notice Transfers token by id from private owner to another private owner
    /// @dev Removes token by id from private owner, and sends a nft note with id to the recipient
    /// @param from The address of the sender
    /// @param to The address of the recipient
    /// @param token_id The id of the token to transfer
    /// @param _nonce The nonce used for authwitness
    #[private]
    fn transfer_private_to_private(
        from: AztecAddress,
        to: AztecAddress,
        token_id: Field,
        _nonce: Field,
    ) {
        _validate_from_private(&mut context, from);

        _remove_private_token_owner(storage.private_nfts.at(from), token_id);
        _update_private_token_owner(
            &mut context,
            storage.private_nfts.at(to),
            from,
            to,
            token_id,
        );
    }

    /// @notice Transfers token by id from private owner to the recipient commitment (recipient must create a commitment first)
    /// @dev Removes token by id from private owner, and enqueues a public call to complete the commitment
    /// @param from The address of the sender
    /// @param token_id The id of the token to transfer
    /// @param commitment The commitment to use for the transfer
    /// @param _nonce The nonce used for authwitness
    #[private]
    fn transfer_private_to_commitment(
        from: AztecAddress,
        token_id: Field,
        commitment: Field,
        _nonce: Field,
    ) {
        _validate_from_private(&mut context, from);

        _remove_private_token_owner(storage.private_nfts.at(from), token_id);
        NFT::at(context.this_address())
            .transfer_token_to_commitment_internal(PartialNFTNote { commitment }, token_id)
            .enqueue(&mut context);
    }

    /// @notice Transfers token by id from public owner to private owner
    /// @dev Enqueues a public call to remove the public owner, and emits a nft note with id to the recipient
    /// @param from The address of the sender
    /// @param to The address of the recipient
    /// @param token_id The id of the token to transfer
    /// @param _nonce The nonce used for authwitness
    #[private]
    fn transfer_public_to_private(
        from: AztecAddress,
        to: AztecAddress,
        token_id: Field,
        _nonce: Field,
    ) {
        _validate_from_private(&mut context, from);

        NFT::at(context.this_address())
            .update_public_token_owner_internal(from, AztecAddress::zero(), token_id)
            .enqueue(&mut context);
        _update_private_token_owner(
            &mut context,
            storage.private_nfts.at(to),
            from,
            to,
            token_id,
        );
    }

    /// @notice Initializes a transfer commitment to be used for transfers
    /// @dev Returns a partial nft note that can be used to execute transfers
    /// @param from The address of the sender
    /// @param to The address of the recipient
    /// @return commitment The partial nft note utilized for the transfer commitment (privacy entrance)
    #[private]
    fn initialize_transfer_commitment(from: AztecAddress, to: AztecAddress) -> Field {
        let commitment =
            _initialize_transfer_commitment(&mut context, storage.private_nfts, from, to);
        commitment.commitment()
    }

    /** ==========================================================
     * ========================= PUBLIC ==========================
     * ======================================================== */

    /// @notice Transfers a token from one public owner to another public owner
    /// @dev Public call that asserts that the caller is the token owner, and updates the public owner
    /// @param from The address of the sender
    /// @param to The address of the recipient
    /// @param token_id The id of the token to transfer
    /// @param _nonce The nonce used for authwitness
    #[public]
    fn transfer_public_to_public(
        from: AztecAddress,
        to: AztecAddress,
        token_id: Field,
        _nonce: Field,
    ) {
        _validate_from_public(&mut context, from);
        _validate_public_token_owner(storage.public_owners, from, token_id);

        _update_public_token_owner(storage.public_owners, to, token_id);
    }

    /// @notice Transfers a token to a commitment
    /// @dev Public call that asserts that the caller is the token owner, and updates the public owner, and completes the commitment
    /// @param from The address of the sender
    /// @param token_id The id of the token to transfer
    /// @param commitment The commitment to use for the transfer
    /// @param _nonce The nonce used for authwitness
    #[public]
    fn transfer_public_to_commitment(
        from: AztecAddress,
        token_id: Field,
        commitment: Field,
        _nonce: Field,
    ) {
        _validate_from_public(&mut context, from);
        _validate_public_token_owner(storage.public_owners, from, token_id);

        _update_public_token_owner(storage.public_owners, AztecAddress::zero(), token_id);
        _transfer_token_to_commitment(&mut context, PartialNFTNote { commitment }, token_id);
    }

    /// @notice Stores a commitment in storage
    /// @param commitment The commitment to store
    #[public]
    #[internal]
    fn store_commitment_in_storage_internal(commitment: PartialNFTNote) {
        _store_commitment_in_storage(&mut context, commitment);
    }

    /// @notice Transfers a token to a commitment
    /// @param commitment The commitment to transfer
    /// @param token_id The id of the token to transfer
    #[public]
    #[internal]
    fn transfer_token_to_commitment_internal(commitment: PartialNFTNote, token_id: Field) {
        _transfer_token_to_commitment(&mut context, commitment, token_id);
    }

    /// @notice Updates the public token owner
    /// @param from The address of the sender
    /// @param to The address of the recipient
    /// @param token_id The id of the token to update
    #[public]
    #[internal]
    fn update_public_token_owner_internal(from: AztecAddress, to: AztecAddress, token_id: Field) {
        _validate_public_token_owner(storage.public_owners, from, token_id);
        _update_public_token_owner(storage.public_owners, to, token_id);
    }

    /// @notice Initializes the public token owner from zero address
    /// @param token_id The id of the token to update
    /// @param exists The new exists value
    #[public]
    #[internal]
    fn update_public_token_owner_from_zero_internal(to: AztecAddress, token_id: Field) {
        _update_public_token_owner(storage.public_owners, to, token_id);
    }

    /// @notice Sets the existence of a token
    /// @dev Asserts token does not exist when setting `exists` to true (minting) and that token exist when setting `exists` to false (burning)
    /// @param token_id The id of the token to set
    /// @param exists The new exists value
    #[public]
    #[internal]
    fn set_nft_exists_internal(token_id: Field, exists: bool) {
        if exists {
            assert(!storage.nft_exists.at(token_id).read(), "token already exists");
        } else {
            assert(storage.nft_exists.at(token_id).read(), "token does not exist");
        }
        storage.nft_exists.at(token_id).write(exists);
    }

    /** ==========================================================
     * ====================== VIEW FUNCTIONS =====================
     * ======================================================== */

    /// @return name The name of the NFT collection
    #[public]
    #[view]
    fn public_get_name() -> pub FieldCompressedString {
        storage.name.read()
    }

    /// @return symbol The symbol of the NFT collection
    #[public]
    #[view]
    fn public_get_symbol() -> pub FieldCompressedString {
        storage.symbol.read()
    }

    /// @return owner The owner of a token by id
    #[public]
    #[view]
    fn public_owner_of(token_id: Field) -> pub AztecAddress {
        storage.public_owners.at(token_id).read()
    }

    /** ==========================================================
     * ===================== UNCONSTRAINED =======================
     * ======================================================== */

    /// @notice Returns an array of token IDs owned by `owner` in private and a flag indicating whether a page limit was reached
    /// @dev Starts getting the notes from page with index `page_index`
    /// @dev Zero values in the array are placeholder values for non-existing notes
    /// @param owner The address of the owner
    /// @param page_index The index of the page to start getting notes from
    /// @return owned_nft_ids An array of token IDs owned by `owner`
    /// @return page_limit_reached A flag indicating whether a page limit was reached
    #[utility]
    pub unconstrained fn get_private_nfts(
        owner: AztecAddress,
        page_index: u32,
    ) -> pub ([Field; MAX_NOTES_PER_PAGE], bool) {
        let offset = page_index * MAX_NOTES_PER_PAGE;
        let mut options = NoteViewerOptions::new();
        let nfts = storage.private_nfts.at(owner).view_notes(options.set_offset(offset));

        let mut owned_nft_ids = [0; MAX_NOTES_PER_PAGE];
        for i in 0..options.limit {
            if i < nfts.len() {
                owned_nft_ids[i] = nfts.get_unchecked(i).token_id;
            }
        }
        let page_limit_reached = nfts.len() == options.limit;
        (owned_nft_ids, page_limit_reached)
    }

    /** ==========================================================
    * ======================= MINTABLE ==========================
    * ======================================================== */

    /// @notice Mints a token to a private address
    /// @dev Asserts that the caller is an authorized minter
    /// @param to The address of the recipient
    /// @param token_id The id of the token to mint
    #[private]
    fn mint_to_private(to: AztecAddress, token_id: Field) {
        assert(token_id != 0, "zero token ID not supported");
        _validate_minter(context.msg_sender(), storage.minter.read());

        NFT::at(context.this_address()).set_nft_exists_internal(token_id, true).enqueue(&mut context);
        storage.private_nfts.at(to).insert(NFTNote::new(token_id, to)).emit(encode_and_encrypt_note(
            &mut context,
            to,
            to,
        ));
    }

    /// @notice Mints a token to a public address
    /// @dev Asserts that the caller is an authorized minter
    /// @param to The address of the recipient
    /// @param token_id The id of the token to mint
    #[public]
    fn mint_to_public(to: AztecAddress, token_id: Field) {
        assert(token_id != 0, "zero token ID not supported");
        _validate_minter(context.msg_sender(), storage.minter.read());
        assert(!storage.nft_exists.at(token_id).read(), "token already exists");

        storage.nft_exists.at(token_id).write(true);
        storage.public_owners.at(token_id).write(to);
    }

    /** ==========================================================
     * ======================= BURNABLE ==========================
     * ======================================================== */

    /// @notice Burns a token from a private address
    /// @dev Asserts that the caller is token owner, removes private token owner, and enqueues a public call to burn token
    /// @param from The address of the owner
    /// @param token_id The id of the token to burn
    /// @param _nonce The nonce used for authwitness
    #[private]
    fn burn_private(from: AztecAddress, token_id: Field, _nonce: Field) {
        _validate_from_private(&mut context, from);

        _remove_private_token_owner(storage.private_nfts.at(from), token_id);
        NFT::at(context.this_address()).set_nft_exists_internal(token_id, false).enqueue(
            &mut context,
        );
    }

    /// @notice Burns a token from a public address
    /// @dev Asserts that token exists and that the caller is token owner, removes public token owner, and burns token
    /// @param from The address of the owner
    /// @param token_id The id of the token to burn
    /// @param _nonce The nonce used for authwitness
    #[public]
    fn burn_public(from: AztecAddress, token_id: Field, _nonce: Field) {
        _validate_from_public(&mut context, from);

        _validate_public_token_owner(storage.public_owners, from, token_id);
        _update_public_token_owner(storage.public_owners, AztecAddress::zero(), token_id);
        storage.nft_exists.at(token_id).write(false);
    }

    /** ==========================================================
     * ===================  UPGRADEABLE  =========================
     * ======================================================== */

    /// @notice Upgrades the contract to a new contract class id
    /// @dev The upgrade authority must be set
    /// @dev The upgrade will only be effective after the upgrade delay has passed
    /// @param new_contract_class_id The new contract class id
    #[public]
    fn upgrade_contract(new_contract_class_id: Field) {
        let upgrade_authority = storage.upgrade_authority.read();

        assert(!upgrade_authority.eq(AztecAddress::zero()), "upgrade authority not set");
        assert(context.msg_sender().eq(upgrade_authority), "caller is not upgrade authority");

        ContractInstanceDeployer::at(DEPLOYER_CONTRACT_ADDRESS)
            .update(ContractClassId::from_field(new_contract_class_id))
            .call(&mut context);
    }

    /** ==========================================================
     * ================= TOKEN LIBRARIES =========================
     * ======================================================== */

    /// @notice Stores a commitment in storage
    /// @param context The context of the public call
    /// @param commitment The commitment to store
    #[contract_library_method]
    fn _store_commitment_in_storage(context: &mut PublicContext, commitment: PartialNFTNote) {
        context.storage_write(commitment.commitment(), true);
    }

    /// @notice Initializes a transfer commitment
    /// @param context The context of the private call
    /// @param private_nfts The private owner
    /// @param from The address of the sender
    /// @param to The address of the recipient
    /// @return commitment The partial nft note utilized for the transfer commitment (privacy entrance)
    #[contract_library_method]
    fn _initialize_transfer_commitment(
        context: &mut PrivateContext,
        private_nfts: Map<AztecAddress, PrivateSet<NFTNote, &mut PrivateContext>, &mut PrivateContext>,
        from: AztecAddress,
        to: AztecAddress,
    ) -> PartialNFTNote {
        let commitment = NFTNote::partial(to, private_nfts.at(to).storage_slot, context, to, from);
        NFT::at(context.this_address()).store_commitment_in_storage_internal(commitment).enqueue(
            context,
        );
        commitment
    }

    /// @notice Updates the private token owner
    /// @param context The context of the private call
    /// @param private_nft_set The private owner
    /// @param from The address of the sender
    /// @param to The address of the recipient
    /// @param token_id The id of the token to update
    #[contract_library_method]
    fn _update_private_token_owner(
        context: &mut PrivateContext,
        private_nft_set: PrivateSet<NFTNote, &mut PrivateContext>,
        from: AztecAddress,
        to: AztecAddress,
        token_id: Field,
    ) {
        let new_note = NFTNote::new(token_id, to);
        private_nft_set.insert(new_note).emit(encode_and_encrypt_note(context, to, from));
    }

    /// @notice Removes the private token owner
    /// @param private_nft_set The private owner
    /// @param token_id The id of the token to remove
    #[contract_library_method]
    fn _remove_private_token_owner(
        private_nft_set: PrivateSet<NFTNote, &mut PrivateContext>,
        token_id: Field,
    ) {
        let notes = private_nft_set.pop_notes(NoteGetterOptions::new()
            .select(NFTNote::properties().token_id, Comparator.EQ, token_id)
            .set_limit(1));
        assert(notes.len() == 1, "nft not found in private to public");
    }

    /// @notice Updates the public token owner
    /// @param public_owners The public owners map
    /// @param to The address of the recipient
    /// @param token_id The id of the token to update
    #[contract_library_method]
    fn _update_public_token_owner(
        public_owners: Map<Field, PublicMutable<AztecAddress, &mut PublicContext>, &mut PublicContext>,
        to: AztecAddress,
        token_id: Field,
    ) {
        public_owners.at(token_id).write(to);
    }

    /// @notice Transfers a token to a commitment
    /// @dev Asserts that a commitment is valid, and completes it
    /// @param context The context of the public call
    /// @param commitment The commitment to complete
    /// @param token_id The id of the token to transfer
    #[contract_library_method]
    fn _transfer_token_to_commitment(
        context: &mut PublicContext,
        commitment: PartialNFTNote,
        token_id: Field,
    ) {
        // We verify that the commitment we're completing is valid (i.e. it uses the correct state variable's storage
        // slot, and it is internally consistent). We *could* clear the storage since each commitment should only be
        // used once, but since the AVM offers no gas refunds for doing so this would just make the transaction be more
        // expensive.
        assert(context.storage_read(commitment.commitment()), "invalid commitment");
        commitment.complete(token_id, context);
    }

    /// @notice Validates that the caller is the owner of a token
    /// @param public_owners The public owners map
    /// @param from The address of the sender
    /// @param token_id The id of the token to validate
    #[contract_library_method]
    fn _validate_public_token_owner(
        public_owners: Map<Field, PublicMutable<AztecAddress, &mut PublicContext>, &mut PublicContext>,
        from: AztecAddress,
        token_id: Field,
    ) {
        let owner = public_owners.at(token_id).read();
        assert(owner.eq(from), "caller is not owner");
    }

    /// @notice Validates that the caller is an authorized minter
    /// @param sender The address of the caller
    /// @param minter The address of the minter
    #[contract_library_method]
    fn _validate_minter(sender: AztecAddress, minter: AztecAddress) {
        assert(minter.eq(sender), "caller is not minter");
    }

    /** ==========================================================
     * ================== AUTH LIBRARIES =========================
     * ======================================================== */

    /// @notice Validates that the caller possesses authwit from the `from` address or the caller is the `from` address
    /// @param context The context of the private call
    /// @param from The address of the sender
    #[contract_library_method]
    fn _validate_from_private(context: &mut PrivateContext, from: AztecAddress) {
        if (!from.eq(context.msg_sender())) {
            assert_current_call_valid_authwit(context, from);
        }
    }

    /// @notice Validates that the caller possesses authwit from the `from` address or the caller is the `from` address
    /// @param context The context of the public call
    /// @param from The address of the sender
    #[contract_library_method]
    unconstrained fn _validate_from_public(context: &mut PublicContext, from: AztecAddress) {
        if (!from.eq(context.msg_sender())) {
            assert_current_call_valid_authwit_public(context, from);
        }
    }
}
