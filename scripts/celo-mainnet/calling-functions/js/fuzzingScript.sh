echo "Load the environment variables from the .env file..."
#source .env
#. ./.env

echo "Run the fuzzing.ts with the async mode..."
npx tsx script/fuzzing/fuzzing/fuzzing.ts  # Success
#npx ts-node script/fuzzing/fuzzing/fuzzing.ts

# See the detail of how to run a Typescript (Node.js) file in shell script: https://nodejs.org/en/learn/typescript/run#running-typescript-with-a-runner