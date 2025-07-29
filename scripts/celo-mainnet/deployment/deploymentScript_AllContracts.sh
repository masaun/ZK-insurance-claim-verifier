echo "Load the environment variables from the .env file..."
. ./.env

echo "Deploying the smart contracts (icl. UltraVerifier, InsuranceClaimProofVerifier) on Celo Mainnet + Gas Cost Simulation..."
forge script scripts/celo-mainnet/deployment/DeploymentAllContracts.s.sol \
    --broadcast \
    --rpc-url ${CELO_MAINNET_RPC} \
    --chain-id ${CELO_MAINNET_CHAIN_ID} \
    --private-key ${CELO_MAINNET_PRIVATE_KEY} \
    --gas-limit 10000000 \
    ./contracts/circuit/ultra-verifier/plonk_vk.sol:UltraVerifier \
    ./contracts/circuit/InsuranceClaimProofVerifier.sol:InsuranceClaimProofVerifier \
    #./contracts/InsuranceClaim.sol:InsuranceClaim \
    #--skip-simulation

echo "Verify the deployed-smart contracts (icl. UltraVerifier, InsuranceClaimProofVerifier) on Celo Mainnet Explorer..."
forge script scripts/celo-mainnet/deployment/DeploymentAllContracts.s.sol \
    --rpc-url ${CELO_MAINNET_RPC} \
    --chain-id ${CELO_MAINNET_CHAIN_ID} \
    --private-key ${CELO_MAINNET_PRIVATE_KEY} \
    --gas-limit 10000000 \
    --resume \
    --verify \
    --verifier blockscout \
    --verifier-url https://celo.blockscout.com/api/