echo "Compile the smart contract files..."
sh buildContract.sh

echo "Load the environment variables from the .env file..."
. ./.env

echo "Deploying & Verifying the InsuranceClaimProofVerifier contract on Celo Mainnet (via CeloScan)..."
forge script scripts/celo-mainnet/deployment/DeploymentForInsuranceClaimProofVerifier_celoscan.s.sol --slow --multi --broadcast --private-key ${BASE_MAINNET_PRIVATE_KEY} --verify --etherscan-api-key ${BASESCAN_API_KEY}

echo "Deploying & Verifying the ReInsurancePool contract on Celo Mainnet (via CeloScan)..."
forge script scripts/celo-mainnet/deployment/DeploymentForReInsurancePool_celoscan.s.sol \
    --slow \
    --multi \
    --broadcast \
    --rpc-url ${CELO_MAINNET_RPC} \
    --chain-id ${CELO_MAINNET_CHAIN_ID} \
    --private-key ${CELO_MAINNET_PRIVATE_KEY} \
    --verify \
    --etherscan-api-key ${CELOSCAN_API_KEY} \
    --gas-limit 10000000