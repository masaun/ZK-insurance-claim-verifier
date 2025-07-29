echo "Load the environment variables from the .env file..."
. ./.env

echo "Deploying & Verifying the InsuranceClaimProofVerifier contract on Celo Mainnet (via CeloScan)..."
forge script scripts/celo-mainnet/deployment/DeploymentForInsuranceClaimProofVerifier_celoscan.s.sol --slow --multi --broadcast --private-key ${CELO_MAINNET_PRIVATE_KEY} --verify --etherscan-api-key ${CELOSCAN_API_KEY}
