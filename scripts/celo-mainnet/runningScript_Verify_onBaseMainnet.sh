echo "Load the environment variables from the .env file..."
#source .env
. ./.env

echo "Verifying a proof via the InsuranceClaimProofVerifier (icl. UltraVerifier) contract on Celo Mainnet..."
forge script scripts/celo-mainnet/Verify_onCeloMainnet.s.sol --broadcast --private-key ${CELO_MAINNET_PRIVATE_KEY} --rpc-url ${CELO_MAINNET_RPC} --skip-simulation
