# @notice - This script file must be run from the root directory of the project, where is the location of .env file.
echo "Load the environment variables from the .env file..."
source .env
#. ./.env

# @notice - [Result]: Successfully "verified" the ReInsurancePool contract on Base Mainnet. 
echo "Verifying the ReInsurancePool contract on Base Mainnet (via BlockScout)..."
forge verify-contract \
  --rpc-url ${BASE_MAINNET_RPC} \
  --verifier blockscout \
  --verifier-url 'https://base.blockscout.com/api/' \
  ${REINSURANCE_POOL_ON_BASE_MAINNET} \
  ./contracts/ReInsurancePool.sol:ReInsurancePool