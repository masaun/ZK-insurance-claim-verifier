/**
 * @notice - Generate a random array of bytes
 */
async function generateRandomArrayBytes() {
    const randomBytes = new Uint8Array(10);
    const randomArrayBytes = Array(64).fill(0);
    return { randomBytes, randomArrayBytes };
}

/**
 * @notice - The main function
 */
async function main() { // Mark the function as async
    const { randomBytes, randomArrayBytes } = await generateRandomArrayBytes();
    console.log(`randomBytes (via Uint8Array(10)): ${ randomBytes }`);
    console.log(`randomArrayBytes (via Array(64).fill(0)): ${ randomArrayBytes }`);
}

/**
 * @notice - Execute the main function
 */
main().then((result) => {
    console.log(`Result: ${result}`);
  }).catch((error) => {
    console.error(`Error: ${error}`);
  });