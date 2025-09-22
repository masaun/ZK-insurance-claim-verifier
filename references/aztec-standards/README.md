# Aztec Standards

Aztec Standards is a compilation of reusable, standardized contracts for the Aztec Network. It provides a foundation of token primitives and utilities supporting both private and public operations, enabling developers to build privacy-preserving applications.

## Table of Contents
- [Dripper](#dripper)
- [Token Contract](#token-contract)
- [Future Contracts](#future-contracts)

## Dripper
The `Dripper` contract provides a simple faucet for minting tokens into private or public balances. Anyone can invoke the functions below to request tokens for testing or development.

### Public Functions
```rust
/// @notice Mints tokens into the public balance of the caller
/// @dev Caller obtains `amount` tokens in their public balance
/// @param token_address The address of the token contract
/// @param amount The amount of tokens to mint (u64, converted to u128 internally)
#[public]
fn drip_to_public(token_address: AztecAddress, amount: u64) { /* ... */ }
```

### Private Functions
```rust
/// @notice Mints tokens into the private balance of the caller
/// @dev Caller obtains `amount` tokens in their private balance
/// @param token_address The address of the token contract
/// @param amount The amount of tokens to mint (u64, converted to u128 internally)
#[private]
fn drip_to_private(token_address: AztecAddress, amount: u64) { /* ... */ }
```

## Token Contract
The `Token` contract implements an ERC-20-like token with Aztec-specific privacy extensions. It supports transfers and interactions explicitly through private balances and public balances, offering full coverage of Aztec's confidentiality features.

### AIP-20: Aztec Token Standard
We published the AIP-20 Aztec Token Standard in our forum: https://forum.aztec.network/t/request-for-comments-aip-20-aztec-token-standard/7737
Feel free to review and discuss the specification there.

### Storage Fields
- `name: str<31>`: Token name (compressed).
- `symbol: str<31>`: Token symbol (compressed).
- `decimals: u8`: Decimal precision.
- `private_balances: Map<AztecAddress, BalanceSet>`: Private balances per account.
- `public_balances: Map<AztecAddress, u128>`: Public balances per account.
- `total_supply: u128`: Total token supply.
- `minter: AztecAddress`: Authorized minter address (if set).
- `upgrade_authority: AztecAddress`: Address allowed to perform contract upgrades (zero address if not upgradeable).

### Initializer Functions
```rust
/// @notice Initializes the token with an initial supply
/// @dev Since this constructor doesn't set a minter address the mint functions will be disabled
/// @param name The name of the token
/// @param symbol The symbol of the token
/// @param decimals The number of decimals of the token
/// @param initial_supply The initial supply of the token
/// @param to The address to mint the initial supply to
/// @param upgrade_authority The address of the upgrade authority (zero if not upgradeable)
#[public]
#[initializer]
fn constructor_with_initial_supply(
    name: str<31>,
    symbol: str<31>,
    decimals: u8,
    initial_supply: u128,
    to: AztecAddress,
    upgrade_authority: AztecAddress,
) { /* ... */ }
```

```rust
/// @notice Initializes the token with a minter
/// @param name The name of the token
/// @param symbol The symbol of the token
/// @param decimals The number of decimals of the token
/// @param minter The address of the minter
/// @param upgrade_authority The address of the upgrade authority (zero if not upgradeable)
#[public]
#[initializer]
fn constructor_with_minter(
    name: str<31>,
    symbol: str<31>,
    decimals: u8,
    minter: AztecAddress,
    upgrade_authority: AztecAddress,
) { /* ... */ }
```

### View & Utility
```rust
/// @notice Returns the public balance of `owner`
/// @param owner The address of the owner
/// @return The public balance of `owner`
#[public]
#[view]
fn balance_of_public(owner: AztecAddress) -> u128

/// @notice Returns the total supply of the token
/// @return The total supply of the token
#[public]
#[view]
fn total_supply() -> u128

/// @notice Returns the name of the token
/// @return The name of the token
#[public]
#[view]
fn name() -> FieldCompressedString

/// @notice Returns the symbol of the token
/// @return The symbol of the token
#[public]
#[view]
fn symbol() -> FieldCompressedString

/// @notice Returns the decimals of the token
/// @return The decimals of the token
#[public]
#[view]
fn decimals() -> u8

/// @notice Returns the private balance of `owner`
/// @param owner The address of the owner
/// @return The private balance of `owner`
#[utility]
unconstrained fn balance_of_private(owner: AztecAddress) -> u128
```

### Public Functions
```rust
/// @notice Transfers tokens from public balance to public balance
/// @dev Public call to decrease account balance and a public call to increase recipient balance
/// @param from The address of the sender
/// @param to The address of the recipient
/// @param amount The amount of tokens to transfer
/// @param nonce The nonce used for authwitness
#[public]
fn transfer_public_to_public(
    from: AztecAddress,
    to: AztecAddress,
    amount: u128,
    nonce: Field,
) { /* ... */ }

/// @notice Finalizes a transfer of token `amount` from public balance of `from` to a commitment of `to`
/// @dev The transfer must be prepared by calling `initialize_transfer_commitment` first and the resulting
/// `commitment` must be passed as an argument to this function
/// @param from The address of the sender
/// @param commitment The Field representing the commitment (privacy entrance)
/// @param amount The amount of tokens to transfer
/// @param nonce The nonce used for authwitness
#[public]
fn transfer_public_to_commitment(
    from: AztecAddress,
    commitment: Field,
    amount: u128,
    nonce: Field,
) { /* ... */ }

/// @notice Mints tokens to a public balance
/// @dev Increases the public balance of `to` by `amount` and the total supply
/// @param to The address of the recipient
/// @param amount The amount of tokens to mint
#[public]
fn mint_to_public(
    to: AztecAddress,
    amount: u128,
) { /* ... */ }

/// @notice Finalizes a mint to a commitment
/// @dev Finalizes a mint to a commitment and updates the total supply
/// @param commitment The Field representing the mint commitment (privacy entrance)
/// @param amount The amount of tokens to mint
#[public]
fn mint_to_commitment(
    commitment: Field,
    amount: u128,
) { /* ... */ }

/// @notice Burns tokens from a public balance
/// @dev Burns tokens from a public balance and updates the total supply
/// @param from The address of the sender
/// @param amount The amount of tokens to burn
/// @param nonce The nonce used for authwitness
#[public]
fn burn_public(
    from: AztecAddress,
    amount: u128,
    nonce: Field,
) { /* ... */ }

/// @notice Mints tokens into the public balance of `to`
/// @dev Increases public balance and total supply
/// @param to The address of the recipient
/// @param amount The amount of tokens to mint
#[public]
fn mint_to_public(to: AztecAddress, amount: u128) { /* ... */ }

/// @notice Finalizes a mint to a commitment
/// @dev Updates total supply and increases commitment balance
/// @param commitment The commitment note for the mint
/// @param amount The amount of tokens to mint
#[public]
fn mint_to_commitment(commitment: Field, amount: u128) { /* ... */ }

/// @notice Burns tokens from a public balance
/// @dev Decreases public balance and total supply
/// @param from The address of the sender
/// @param amount The amount of tokens to burn
/// @param nonce The nonce used for auth witness
#[public]
fn burn_public(from: AztecAddress, amount: u128, nonce: Field) { /* ... */ }

/// @notice Upgrades the contract to a new contract class id
/// @dev Only callable by the `upgrade_authority` and effective after the upgrade delay
/// @param new_contract_class_id The new contract class id
#[public]
fn upgrade_contract(new_contract_class_id: Field) { /* ... */ }
```

### Private Functions
```rust
/// @notice Transfer tokens from private balance to public balance
/// @dev Spends notes, emits a new note (UintNote) with any remaining change, and enqueues a public call
/// @param from The address of the sender
/// @param to The address of the recipient
/// @param amount The amount of tokens to transfer
/// @param nonce The nonce used for authwitness
#[private]
fn transfer_private_to_public(
    from: AztecAddress,
    to: AztecAddress,
    amount: u128,
    nonce: Field,
) { /* ... */ }

/// @notice Transfer tokens from private balance to public balance with a commitment
/// @dev Spends notes, emits a new note (UintNote) with any remaining change, enqueues a public call, and returns a partial note
/// @param from The address of the sender
/// @param to The address of the recipient
/// @param amount The amount of tokens to transfer
/// @param nonce The nonce used for authwitness
/// @return commitment The partial note utilized for the transfer commitment (privacy entrance)
#[private]
fn transfer_private_to_public_with_commitment(
    from: AztecAddress,
    to: AztecAddress,
    amount: u128,
    nonce: Field,
) -> Field { /* ... */ }

/// @notice Transfer tokens from private balance to private balance
/// @dev Spends notes, emits a new note (UintNote) with any remaining change, and sends a note to the recipient
/// @param from The address of the sender
/// @param to The address of the recipient
/// @param amount The amount of tokens to transfer
/// @param nonce The nonce used for authwitness
#[private]
fn transfer_private_to_private(
    from: AztecAddress,
    to: AztecAddress,
    amount: u128,
    nonce: Field,
) { /* ... */ }

/// @notice Transfer tokens from private balance to the recipient commitment (recipient must create a commitment first)
/// @dev Spends notes, emits a new note (UintNote) with any remaining change, and enqueues a public call
/// @param from The address of the sender
/// @param commitment The Field representing the commitment (privacy entrance that the recipient shares with the sender)
/// @param amount The amount of tokens to transfer
/// @param nonce The nonce used for authwitness
#[private]
fn transfer_private_to_commitment(
    from: AztecAddress,
    commitment: Field,
    amount: u128,
    nonce: Field,
) { /* ... */ }

/// @notice Transfer tokens from public balance to private balance
/// @dev Enqueues a public call to decrease account balance and emits a new note with balance difference
/// @param from The address of the sender
/// @param to The address of the recipient
/// @param amount The amount of tokens to transfer
/// @param nonce The nonce used for authwitness
#[private]
fn transfer_public_to_private(
    from: AztecAddress,
    to: AztecAddress,
    amount: u128,
    nonce: Field,
) { /* ... */ }

/// @notice Initializes a transfer commitment to be used for transfers/mints
/// @dev Returns a partial note that can be used to execute transfers/mints
/// @param from The address of the sender
/// @param to The address of the recipient
/// @return commitment The partial note initialized for the transfer/mint commitment
#[private]
fn initialize_transfer_commitment(from: AztecAddress, to: AztecAddress) -> Field { /* ... */ }

/// @notice Mints tokens into a private balance
/// @dev Requires minter, enqueues supply update
/// @param from The address of the sender
/// @param to The address of the recipient
/// @param amount The amount of tokens to mint
#[private]
fn mint_to_private(from: AztecAddress, to: AztecAddress, amount: u128) { /* ... */ }

/// @notice Burns tokens from a private balance
/// @dev Requires auth witness, enqueues supply update
/// @param from The address of the sender
/// @param amount The amount of tokens to burn
/// @param nonce The nonce used for auth witness
#[private]
fn burn_private(from: AztecAddress, amount: u128, nonce: Field) { /* ... */ }
```

### View Functions
```rust
/// @notice Returns the public balance of `owner`
/// @param owner The address of the owner
/// @return The balance of the public balance of `owner`
#[public]
#[view]
fn balance_of_public(owner: AztecAddress) -> u128 { /* ... */ }

/// @notice Returns the total supply of the token
/// @return The total supply of the token
#[public]
#[view]
fn total_supply() -> u128 { /* ... */ }

/// @notice Returns the name of the token
/// @return The name of the token
#[public]
#[view]
fn name() -> str<31> { /* ... */ }

/// @notice Returns the symbol of the token
/// @return The symbol of the token
#[public]
#[view]
fn symbol() -> str<31> { /* ... */ }

/// @notice Returns the decimals of the token
/// @return The decimals of the token
#[public]
#[view]
fn decimals() -> u8 { /* ... */ }
```

### Utility Functions
```rust
/// @notice Returns the private balance of `owner`
/// @param owner The address of the owner
/// @return The private balance of `owner`
#[utility]
unconstrained fn balance_of_private(owner: AztecAddress) -> u128 { /* ... */ }
```

## Future Contracts
Additional standardized contracts (e.g., staking, governance, pools) will be added under this repository, with descriptions and function lists.