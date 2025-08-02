# @notice - This script file must be run from the root directory of the project, where is the location of .env file.
echo "Load the environment variables from the .env file..."
source .env
#. ./.env

# @notice - [Result]: Successfully "verified" the InsuranceClaimManager contract on Celo Mainnet. 
echo "Verifying the InsuranceClaimManager contract on Celo Mainnet (via BlockScout)..."
forge verify-contract \
  --rpc-url ${CELO_MAINNET_RPC} \
  --verifier blockscout \
  --verifier-url 'https://celo.blockscout.com/api/' \
  ${INSURANCE_CLAIM_MANAGER_ON_CELO_MAINNET} \
  ./contracts/InsuranceClaimManager.sol:InsuranceClaimManager