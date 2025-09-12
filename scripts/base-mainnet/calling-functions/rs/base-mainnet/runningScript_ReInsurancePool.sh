echo "Load the environment variables from the .env file..."
source .env

echo "Running ReInsurancePool contract interactions..."
cargo run --bin reinsurance_pool_on_base_mainnet -- --show-output any_network