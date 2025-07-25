echo "Load the environment variables from the .env file..."
. ./.env

echo "Deploying the InsuranceClaimProofVerifier SC on BASE Mainnet + Gas Cost Simulation..."
forge script scripts/base-mainnet/deployment/DeploymentForInsuranceClaimProofVerifier.s.sol \
    --broadcast \
    --rpc-url ${BASE_MAINNET_RPC} \
    --chain-id ${BASE_MAINNET_CHAIN_ID} \
    --private-key ${BASE_MAINNET_PRIVATE_KEY} \
    --gas-limit 10000000 \
    #./contracts/circuit/ultra-verifier/plonk_vk.sol:UltraVerifier \
    ./contracts/circuit/InsuranceClaimProofVerifier.sol:InsuranceClaimProofVerifier \
    #./contracts/InsuranceClaim.sol:InsuranceClaim \
    #--skip-simulation

echo "Verify the InsuranceClaimProofVerifier SC on BASE Mainnet Explorer..."
forge script scripts/base-mainnet/deployment/DeploymentForInsuranceClaimProofVerifier.s.sol \
    --rpc-url ${BASE_MAINNET_RPC} \
    --chain-id ${BASE_MAINNET_CHAIN_ID} \
    --private-key ${BASE_MAINNET_PRIVATE_KEY} \
    --gas-limit 10000000 \
    --resume \
    --verify \
    --verifier blockscout \
    --verifier-url https://base.blockscout.com/api/