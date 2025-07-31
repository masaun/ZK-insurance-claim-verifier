# @notice - This script file must be run from the root directory of the project, where is the location of .env file.
echo "Load the environment variables from the .env file..."
source .env
#. ./.env

# @notice - [Result]: Successfully "verified" the InsuranceClaimManager contract on Celo Mainnet. 
echo "Verifying the InsuranceClaimManager contract on BASE Mainnet (via BaseScan)..."
forge verify-contract \
    --rpc-url ${BASE_MAINNET_RPC} \
    --chain-id ${BASE_MAINNET_CHAIN_ID} \
    ${INSURANCE_CLAIM_MANAGER_ON_BASE_MAINNET} \
    ./contracts/InsuranceClaimManager.sol:InsuranceClaimManager \
    --etherscan-api-key ${BASESCAN_API_KEY}


echo "Verifying the InsuranceClaimManager contract on BASE Mainnet via Curl command..."
curl "https://api.basescan.org/api?module=contract&action=checkverifystatus&guid=${GUID}&apikey=${BASESCAN_API_KEY}"