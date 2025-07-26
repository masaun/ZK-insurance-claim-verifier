# @notice - This script file must be run from the root directory of the project, where is the location of .env file.
echo "Load the environment variables from the .env file..."
source .env
#. ./.env

# @notice - [Result]: Successfully "verified" the InsuranceClaimProofVerifier contract on Base Mainnet. 
echo "Verifying the InsuranceClaimProofVerifier contract on Base Mainnet (via BaseScan)..."
forge verify-contract \
    --rpc-url ${BASE_MAINNET_RPC} \
    --chain-id ${BASE_MAINNET_CHAIN_ID} \
    ${INSURANCE_CLAIM_PROOF_VERIFIER_ON_BASE_MAINNET} \
    ./contracts/circuit/InsuranceClaimProofVerifier.sol:InsuranceClaimProofVerifier \
    --etherscan-api-key ${BASESCAN_API_KEY}


echo "Verifying the InsuranceClaimProofVerifier contract on Base Mainnet via Curl command..."
curl "https://api.basescan.org/api?module=contract&action=checkverifystatus&guid=${GUID}&apikey=${BASESCAN_API_KEY}"