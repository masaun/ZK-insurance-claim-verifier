echo "Compile the smart contract files..."
sh buildContract.sh

echo "Load the environment variables from the .env file..."
. ./.env

echo "Deploying & Verifying the InsuranceClaimProofVerifier contract on Base Mainnet (via BaseScan)..."
forge script scripts/base-mainnet/deployment/DeploymentForInsuranceClaimProofVerifier_basescan.s.sol --slow --multi --broadcast --private-key ${BASE_MAINNET_PRIVATE_KEY} --verify --etherscan-api-key ${BASESCAN_API_KEY}

echo "Deploying & Verifying the ReInsurancePool contract on BASE Mainnet (via BaseScan)..."
forge script scripts/base-mainnet/deployment/DeploymentForReInsurancePool_basescan.s.sol \
    --slow \
    --multi \
    --broadcast \
    --rpc-url ${BASE_MAINNET_RPC} \
    --chain-id ${BASE_MAINNET_CHAIN_ID} \
    --private-key ${BASE_MAINNET_PRIVATE_KEY} \
    --verify \
    --etherscan-api-key ${BASESCAN_API_KEY} \
    --gas-limit 10000000