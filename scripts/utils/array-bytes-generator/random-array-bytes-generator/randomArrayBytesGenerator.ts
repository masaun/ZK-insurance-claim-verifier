/**
 * @notice - Generate a random array of bytes
 */
async function generateRandomArrayBytes() {
    const randomUint8ArrayBytes = new Uint8Array(10); // Lenght of 10 bytes
    const randomArrayBytes = Array(64).fill(0);       // Length of 64 bytes

    return { randomUint8ArrayBytes, randomArrayBytes };
}

/**
 * @notice - The main function
 */
async function main() { // Mark the function as async
    const { randomUint8ArrayBytes, randomArrayBytes } = await generateRandomArrayBytes();
    console.log(`randomUint8ArrayBytes (via Uint8Array(10) + Lenght of 10 bytes): ${ randomUint8ArrayBytes }`);
    console.log(`randomArrayBytes (via Array(64).fill(0) + Length of 64 bytes): ${ randomArrayBytes }`);
}

/**
 * @notice - Execute the main function
 */
main().then((result) => {
    console.log(`Result: ${result}`);
  }).catch((error) => {
    console.error(`Error: ${error}`);
  });