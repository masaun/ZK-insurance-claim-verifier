echo "Load the environment variables from the .env file..."
#source .env
. ./.env

echo "Verifying a proof via the InsuranceClaimProofVerifier (icl. UltraVerifier) contract on BASE Mainnet..."
forge script scripts/base-mainnet/Verify_onBaseMainnet.s.sol --broadcast --private-key ${BASE_MAINNET_PRIVATE_KEY} --rpc-url ${BASE_MAINNET_RPC} --skip-simulation
