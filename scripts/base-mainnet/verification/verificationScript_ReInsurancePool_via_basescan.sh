# @notice - This script file must be run from the root directory of the project, where is the location of .env file.
echo "Load the environment variables from the .env file..."
source .env
#. ./.env

# @notice - [Result]: Successfully "verified" the ReInsurancePool contract on Celo Mainnet. 
echo "Verifying the ReInsurancePool contract on BASE Mainnet (via BaseScan)..."
forge verify-contract \
    --rpc-url ${BASE_MAINNET_RPC} \
    --chain-id ${BASE_MAINNET_CHAIN_ID} \
    ${REINSURANCE_POOL_ON_BASE_MAINNET} \
    ./contracts/ReInsurancePool.sol:ReInsurancePool \
    --etherscan-api-key ${BASESCAN_API_KEY}


echo "Verifying the ReInsurancePool contract on BASE Mainnet via Curl command..."
curl "https://api.basescan.org/api?module=contract&action=checkverifystatus&guid=${GUID}&apikey=${BASESCAN_API_KEY}"