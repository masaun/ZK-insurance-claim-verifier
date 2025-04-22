import { decodeBase64 } from 'ethers/utils';  // ethers.js v6
//import { arrayify } from "ethers/utils";    // ethers.js v5


/**
 * @notice - Generate a random array of bytes /w ethers.js v6
 */
async function generateRandomArrayBytesWithWithEthersjs() {
    const bytes32 = "0x68656c6c6f000000000000000000000000000000000000000000000000000000"; // "hello" padded
    const randomUint8ArrayBytes = decodeBase64(bytes32);                                  // Lenght of 32 bytes (ethers.js v6)
    //const randomUint8ArrayBytes = ethers.utils.decodeBase64(bytes32);                   // Lenght of 32 bytes
    //const randomUint8ArrayBytes = arrayify(bytes32);                                    // Lenght of 32 bytes (ethers.js v5)

    return { randomUint8ArrayBytes };
}

/**
 * @notice - The main function
 */
async function main() { // Mark the function as async
    const { randomUint8ArrayBytes } = await generateRandomArrayBytesWithWithEthersjs();
    console.log(`randomUint8ArrayBytes (via ethers.utils.decodeBase64()): ${ randomUint8ArrayBytes }`); // [Log]: 211,30,188,235,158,156,233,206,159,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211
}

/**
 * @notice - Execute the main function
 */
main().then((result) => {
    console.log(`Result: ${result}`);
  }).catch((error) => {
    console.error(`Error: ${error}`);
  });