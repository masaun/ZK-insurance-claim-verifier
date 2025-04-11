echo "Load the environment variables from the .env file..."
source .env
#. ./.env

echo "Running the test of the StarterTest..."
forge test --optimize --optimizer-runs 5000 --evm-version cancun --match-contract StarterTest -vvv
