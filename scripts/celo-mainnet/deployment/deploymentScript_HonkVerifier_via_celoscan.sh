echo "Load the environment variables from the .env file..."
. ./.env

echo "Deploying & Verifying the HonkVerifier contract on Celo Mainnet (via CeloScan)..."
forge script scripts/celo-mainnet/deployment/DeploymentForHonkVerifier_celoscan.s.sol \
    --slow \
    --multi \
    --broadcast \
    --rpc-url ${CELO_MAINNET_RPC} \
    --chain-id ${CELO_MAINNET_CHAIN_ID} \
    --private-key ${CELO_MAINNET_PRIVATE_KEY} \
    --verify \
    --etherscan-api-key ${CELOSCAN_API_KEY} \
    --gas-limit 10000000