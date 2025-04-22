import { decodeBase64 } from 'ethers/utils';  // ethers.js v6
//import { arrayify } from "ethers/utils"; // ethers.js v6


/**
 * @notice - Generate a random array of bytes /w ethers.js
 */
async function generateRandomArrayBytesWithWithEthersjs() {
    const bytes32 = "0x68656c6c6f000000000000000000000000000000000000000000000000000000"; // "hello" padded
    const randomUint8ArrayBytes = decodeBase64(bytes32); // Lenght of 10 bytes
    //const randomUint8ArrayBytes = ethers.utils.decodeBase64(bytes32); // Lenght of 10 bytes
    //const randomUint8ArrayBytes = arrayify(bytes32);

    return { randomUint8ArrayBytes };
}

/**
 * @notice - The main function
 */
async function main() { // Mark the function as async
    const { randomUint8ArrayBytes } = await generateRandomArrayBytesWithWithEthersjs();
    console.log(`randomUint8ArrayBytes (via Uint8Array(10) + Lenght of 10 bytes): ${ randomUint8ArrayBytes }`);
}

/**
 * @notice - Execute the main function
 */
main().then((result) => {
    console.log(`Result: ${result}`);
  }).catch((error) => {
    console.error(`Error: ${error}`);
  });