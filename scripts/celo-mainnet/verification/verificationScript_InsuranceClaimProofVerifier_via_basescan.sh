# @notice - This script file must be run from the root directory of the project, where is the location of .env file.
echo "Load the environment variables from the .env file..."
source .env
#. ./.env

# @notice - [Result]: Successfully "verified" the InsuranceClaimProofVerifier contract on Celo Mainnet. 
echo "Verifying the InsuranceClaimProofVerifier contract on Celo Mainnet (via CeloScan)..."
forge verify-contract \
    --rpc-url ${CELO_MAINNET_RPC} \
    --chain-id ${CELO_MAINNET_CHAIN_ID} \
    ${INSURANCE_CLAIM_PROOF_VERIFIER_ON_CELO_MAINNET} \
    ./contracts/circuit/InsuranceClaimProofVerifier.sol:InsuranceClaimProofVerifier \
    --etherscan-api-key ${CELOSCAN_API_KEY}


echo "Verifying the InsuranceClaimProofVerifier contract on Celo Mainnet via Curl command..."
curl "https://api.celoscan.org/api?module=contract&action=checkverifystatus&guid=${GUID}&apikey=${CELOSCAN_API_KEY}"