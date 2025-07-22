echo "Load the environment variables from the .env file..."
. ./.env

echo "Deploying the smart contracts (icl. UltraVerifier, InsuranceClaimProofVerifier) on Swell Chain Testnet..."
forge script scripts/base-testnet/deployment/DeploymentAllContracts.s.sol \
    --broadcast \
    --rpc-url ${BASE_TESTNET_RPC} \
    --chain-id ${BASE_TESTNET_CHAIN_ID} \
    --private-key ${BASE_TESTNET_PRIVATE_KEY} \
    --gas-limit 30000000 \
    ./contracts/circuit/ultra-verifier/plonk_vk.sol:UltraVerifier \
    ./contracts/circuit/InsuranceClaimProofVerifier.sol:InsuranceClaimProofVerifier \
    --skip-simulation

echo "Verify the deployed-smart contracts (icl. UltraVerifier, InsuranceClaimProofVerifier) on Base Testnet Explorer..."
forge script scripts/base-testnet/deployment/DeploymentAllContracts.s.sol \
    --rpc-url ${BASE_TESTNET_RPC} \
    --chain-id ${BASE_TESTNET_CHAIN_ID} \
    --private-key ${BASE_TESTNET_PRIVATE_KEY} \
    --gas-limit 30000000 \
    --resume \
    --verify \
    --verifier blockscout \
    --verifier-url https://base-sepolia.blockscout.com/api/