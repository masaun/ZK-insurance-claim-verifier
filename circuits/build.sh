echo "Load the environment variables from the .env file..."
source ../.env
#. ./.env

echo "Compiling circuit..."
nargo compile
if [ $? -ne 0 ]; then
  exit 1
fi

echo "Generate witness..."
nargo execute

echo "Proving and generating a ZK Proof..."
bb prove -b ./target/insurance_claim.json -w ./target/insurance_claim.gz -o ./target/insurance_claim_proof.bin

echo "Generating vkey..."
bb write_vk -b ./target/insurance_claim.json -o ./target/insurance_claim_vk.bin

echo "Link vkey to the zkProof"
bb verify -k ./target/insurance_claim_vk.bin -p ./target/insurance_claim_proof.bin

echo "Check a zkProof"
head -c 32 ./target/insurance_claim_proof.bin | od -An -v -t x1 | tr -d $' \n'

echo "Copy and paste vk for generating a Solidity Verifier contract"
cp ./target/insurance_claim_vk.bin ./target/vk

echo "Generate a Solidity Verifier contract"
bb contract

echo "Copy a Solidity Verifier contract-generated into the ./contracts/circuit/ultra-verifier directory"
cp ./target/contract.sol ../contracts/circuit/ultra-verifier

echo "Rename the contract.sol with the plonk_vk.sol in the ./contracts/circuit/ultra-verifier directory"
mv ../contracts/circuit/ultra-verifier/contract.sol ../contracts/circuit/ultra-verifier/plonk_vk.sol

echo "Done"