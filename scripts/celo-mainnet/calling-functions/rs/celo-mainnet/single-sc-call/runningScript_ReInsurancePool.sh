echo "Load the environment variables from the .env file..."
source .env

echo "Running ReInsurancePool contract interactions with a single smart contract call..."
cargo run --bin reinsurance_pool_on_celo_mainnet_with_single_sc_call -- --show-output any_network