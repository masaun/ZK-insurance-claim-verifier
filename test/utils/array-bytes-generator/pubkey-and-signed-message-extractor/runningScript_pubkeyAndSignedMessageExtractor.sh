echo "Load the environment variables from the .env file..."
#source .env
. ./.env

echo "Run the pubkeyAndSignedMessageExtractor.ts with the async mode..."
npx tsx scripts/utils/array-bytes-generator/pubkey-and-signed-message-extractor/pubkeyAndSignedMessageExtractor.ts

# See the detail of how to run a Typescript (Node.js) file in shell script: https://nodejs.org/en/learn/typescript/run#running-typescript-with-a-runner