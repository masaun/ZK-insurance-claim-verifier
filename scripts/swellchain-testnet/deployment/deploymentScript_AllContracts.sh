echo "Load the environment variables from the .env file..."
. ./.env

echo "Deploying the smart contracts (icl. UltraVerifier, InsuranceClaimProofVerifier) on Swell Chain Testnet..."
forge script scripts/swellchain-testnet/deployment/DeploymentAllContracts.s.sol \
    --broadcast \
    --rpc-url ${SWELL_CHAIN_TESTNET_RPC} \
    --chain-id ${SWELL_CHAIN_CHAIN_ID} \
    --private-key ${SWELL_CHAIN_TESTNET_PRIVATE_KEY} \
    ./contracts/circuit/ultra-verifier/plonk_vk.sol:UltraVerifier \
    ./contracts/circuit/InsuranceClaimProofVerifier.sol:InsuranceClaimProofVerifier \
    --skip-simulation

echo "Verify the deployed-smart contracts (icl. UltraVerifier, InsuranceClaimProofVerifier) on Swell Chain Testnet Explorer..."
forge script scripts/swellchain-testnet/deployment/DeploymentAllContracts.s.sol \
    --rpc-url ${SWELL_CHAIN_TESTNET_RPC} \
    --chain-id ${SWELL_CHAIN_CHAIN_ID} \
    --private-key ${SWELL_CHAIN_TESTNET_PRIVATE_KEY} \
    --resume \
    --verify \
    --verifier blockscout \
    --verifier-url https://swell-testnet-explorer.alt.technology/api/