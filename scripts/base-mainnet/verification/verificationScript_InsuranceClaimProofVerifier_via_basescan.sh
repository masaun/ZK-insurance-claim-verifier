# @notice - This script file must be run from the root directory of the project, where is the location of .env file.
echo "Load the environment variables from the .env file..."
source .env
#. ./.env

# @notice - [Result]: Successfully "verified" the InsuranceClaimProofVerifier contract on Base Mainnet. 
echo "Verifying the InsuranceClaimProofVerifier contract on Base Mainnet..."
forge verify-contract \
    --rpc-url ${BASE_MAINNET_RPC} \
    --chain-id ${BASE_MAINNET_CHAIN_ID} \
    0x9d04136bEaA01d30Db51BD8F79232633A86E4B80 \
    ./contracts/circuit/InsuranceClaimProofVerifier.sol:InsuranceClaimProofVerifier \
    --etherscan-api-key ${BASESCAN_API_KEY}


echo "Verifying the InsuranceClaimProofVerifier contract on Base Mainnet via Curl command..."
curl "https://api.basescan.org/api?module=contract&action=checkverifystatus&guid=${GUID}&apikey=${BASESCAN_API_KEY}"