echo "Load the environment variables from the .env file..."
#source .env
. ./.env

echo "Verifying a proof via the InsuranceClaimProofVerifier (icl. UltraVerifier) contract on Base Testnet..."
forge script scripts/base-testnet/Verify_onBaseTestnet.s.sol --broadcast --private-key ${BASE_TESTNET_PRIVATE_KEY} --rpc-url ${BASE_TESTNET_RPC} --skip-simulation
