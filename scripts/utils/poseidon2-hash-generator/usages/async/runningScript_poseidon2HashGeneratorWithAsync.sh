echo "Load the environment variables from the .env file..."
#source .env
. ./.env

echo "Run the poseidon2HashGeneratorWithAsync.ts with the async mode..."
npx tsx scripts/utils/poseidon2-hash-generator/usages/async/poseidon2HashGeneratorWithAsync.ts  # Success
#npx ts-node scripts/utils/poseidon2-hash-generator/usages/async/poseidon2HashGeneratorWithAsync.ts

# See the detail of how to run a Typescript (Node.js) file in shell script: https://nodejs.org/en/learn/typescript/run#running-typescript-with-a-runner