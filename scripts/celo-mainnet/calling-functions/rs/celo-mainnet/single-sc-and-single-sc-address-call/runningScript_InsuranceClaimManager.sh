echo "Load the environment variables from the .env file..."
source .env

echo "Running the InsuranceClaimManager contract interactions with a single smart contract call..."
cargo run --bin insurance_claim_manager_on_base_mainnet_with_single_sc_call -- --show-output any_network