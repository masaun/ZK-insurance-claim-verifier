echo "Load the environment variables from the .env file..."
. ./.env

echo "Deploying & Verifying the HonkVerifier contract on BASE Mainnet (via BaseScan)..."
forge script scripts/base-mainnet/deployment/DeploymentForHonkVerifier_basescan.s.sol \
    --slow \
    --multi \
    --broadcast \
    --rpc-url ${BASE_MAINNET_RPC} \
    --chain-id ${BASE_MAINNET_CHAIN_ID} \
    --private-key ${BASE_MAINNET_PRIVATE_KEY} \
    --verify \
    --etherscan-api-key ${BASESCAN_API_KEY} \
    --gas-limit 10000000