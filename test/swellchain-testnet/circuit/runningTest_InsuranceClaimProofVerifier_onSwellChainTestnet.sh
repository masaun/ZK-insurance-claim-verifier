echo "Load the environment variables from the .env file..."
source .env
#. ./.env

echo "Running the test of the InsuranceClaimProofVerifier contract on Swell Chain Testnet..."
forge test --optimize --optimizer-runs 5000 --evm-version cancun --match-contract InsuranceClaimProofVerifierTest_OnSwellChainTestnet --rpc-url ${SWELL_CHAIN_TESTNET_RPC} -vvv
