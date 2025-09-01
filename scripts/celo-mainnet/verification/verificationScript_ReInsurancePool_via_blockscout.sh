# @notice - This script file must be run from the root directory of the project, where is the location of .env file.
echo "Load the environment variables from the .env file..."
source .env
#. ./.env

# @notice - [Result]: Successfully "verified" the ReInsurancePool contract on Celo Mainnet. 
echo "Verifying the ReInsurancePool contract on Celo Mainnet (via BlockScout)..."
forge verify-contract \
  --rpc-url ${CELO_MAINNET_RPC} \
  --verifier blockscout \
  --verifier-url 'https://celo.blockscout.com/api/' \
  ${REINSURANCE_POOL_ON_CELO_MAINNET} \
  ./contracts/ReInsurancePool.sol:ReInsurancePool