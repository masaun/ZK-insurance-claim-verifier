echo "Load the environment variables from the .env file..."
#source .env
. ./.env

echo "Verifying a proof via the InsuranceClaimProofVerifier (icl. UltraVerifier) contract on Swell Chain testnet..."
forge script scripts/swellchain-testnet/Verify_onSwellChainTestnet.s.sol --broadcast --private-key ${SWELL_CHAIN_TESTNET_PRIVATE_KEY} --rpc-url ${SWELL_CHAIN_TESTNET_RPC} --skip-simulation
