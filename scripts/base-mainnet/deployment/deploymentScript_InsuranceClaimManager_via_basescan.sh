echo "Compile the smart contract files..."
sh buildContract.sh

echo "Load the environment variables from the .env file..."
. ./.env

echo "Deploying & Verifying the InsuranceClaimManager contract on BASE Mainnet (via BaseScan)..."
forge script scripts/base-mainnet/deployment/DeploymentForInsuranceClaimManager_basescan.s.sol --slow --multi --broadcast --private-key ${BASE_MAINNET_PRIVATE_KEY} --verify --etherscan-api-key ${BASESCAN_API_KEY}


#####################
### SC Verfication
#####################

# @notice - [Result]: Successfully "verified" the InsuranceClaimManager contract on Base Mainnet. 
echo "Verifying the InsuranceClaimManager contract on Base Mainnet (via BlockScout)..."
forge verify-contract \
  --rpc-url ${BASE_MAINNET_RPC} \
  --verifier blockscout \
  --verifier-url 'https://base.blockscout.com/api/' \
  ${INSURANCE_CLAIM_MANAGER_ON_BASE_MAINNET} \
  ./contracts/InsuranceClaimManager.sol:InsuranceClaimManager


# @notice - [Result]: Successfully "verified" the ReInsurancePool contract on Base Mainnet. 
echo "Verifying the ReInsurancePool contract on Base Mainnet (via BlockScout)..."
forge verify-contract \
  --rpc-url ${BASE_MAINNET_RPC} \
  --verifier blockscout \
  --verifier-url 'https://base.blockscout.com/api/' \
  ${REINSURANCE_POOL_ON_BASE_MAINNET} \
  ./contracts/ReInsurancePool.sol:ReInsurancePool