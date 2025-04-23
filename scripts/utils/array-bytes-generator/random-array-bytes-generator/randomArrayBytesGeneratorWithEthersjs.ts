import { decodeBase64 } from 'ethers/utils';  // ethers.js v6
//import { arrayify } from "ethers/utils";    // ethers.js v5


/**
 * @notice - Generate a random array of bytes /w ethers.js v6
 */
async function generateRandomArrayBytesWithWithEthersjs() {
    const bytes64 = "0xf875be44b382147d14f23ae10a3cd544e54996013ea390cef46c215f063862760011cd83eee30440d9dd72aa4a0c401d8ef014efd1c34b983217616bef8fbd401b"
    const randomUint8ArrayBytes_64 = decodeBase64(bytes64);                               // Lenght of 64 bytes (ethers.js v6)

    const bytes32 = "0x68656c6c6f000000000000000000000000000000000000000000000000000000"; // "hello" padded
    const randomUint8ArrayBytes_32 = decodeBase64(bytes32);                               // Lenght of 32 bytes (ethers.js v6)
    //const randomUint8ArrayBytes = ethers.utils.decodeBase64(bytes32);                   // Lenght of 32 bytes
    //const randomUint8ArrayBytes = arrayify(bytes32);                                    // Lenght of 32 bytes (ethers.js v5)

    return { randomUint8ArrayBytes_32, randomUint8ArrayBytes_64 }; // Return the random array of bytes
}

/**
 * @notice - The main function
 */
async function main() { // Mark the function as async
    const { randomUint8ArrayBytes_32, randomUint8ArrayBytes_64 } = await generateRandomArrayBytesWithWithEthersjs();
    console.log(`randomUint8ArrayBytes /w bytes32 value (via ethers.utils.decodeBase64()): ${ randomUint8ArrayBytes_32 }`); // [Log]: 211,30,188,235,158,156,233,206,159,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211
    console.log(`randomUint8ArrayBytes /w bytes64 value (via ethers.utils.decodeBase64()): ${ randomUint8ArrayBytes_64 }`); // [Log]: 211,30,188,235,158,156,233,206,159,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211,77,52,211
  }

/**
 * @notice - Execute the main function
 */
main().then((result) => {
    console.log(`Result: ${result}`);
  }).catch((error) => {
    console.error(`Error: ${error}`);
  });