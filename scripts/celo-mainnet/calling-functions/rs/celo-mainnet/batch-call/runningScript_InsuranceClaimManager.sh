echo "Load the environment variables from the .env file..."
source .env

echo "Running the InsuranceClaimManager contract interactions..."
cargo run --bin insurance_claim_manager_on_celo_mainnet -- --show-output any_network