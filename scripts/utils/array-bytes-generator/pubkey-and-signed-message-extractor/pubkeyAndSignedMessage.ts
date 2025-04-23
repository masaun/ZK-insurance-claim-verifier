import { ethers, SigningKey } from "ethers"; // ethers.js v6


/**
 * @notice - [IN PROGRESS]: Extract the public key and signed message
 */
async function extractPubkeyAndSignedMessage() {
    // hardhat wallet 0
    const sender = new ethers.Wallet(
        "ac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
    );

    const message = "Hello, Ethereum!"; // @dev - Added
    console.log("\x1b[34m%s\x1b[0m", "signing message 🖋: ", message);

    const digest = ethers.hashMessage(message); // @dev - Added
    console.log("digest: ", digest); // @dev - Added

    const signature = await sender.signMessage(message); // get the signature of the message, this will be 130 bytes (concatenated r, s, and v)

    console.log("signature 📝: ", signature);

    let pubKey_uncompressed = ethers.SigningKey.recoverPublicKey(digest, signature);
    console.log("uncompressed pubkey: ", pubKey_uncompressed);

    // recoverPublicKey returns `0x{hex"4"}{pubKeyXCoord}{pubKeyYCoord}` - so slice 0x04 to expose just the concatenated x and y
    //    see https://github.com/indutny/elliptic/issues/86 for a non-explanation explanation 😂
    let pubKey = pubKey_uncompressed.slice(4);

    let pub_key_x = pubKey.substring(0, 64);
    console.log("public key x coordinate 📊: ", pub_key_x);

    let pub_key_y = pubKey.substring(64);
    console.log("public key y coordinate 📊: ", pub_key_y);

    return { signature, pubKey, pubKey_uncompressed, pub_key_x, pub_key_y };
}

/**
 * @notice - The main function
 */
async function main() { // Mark the function as async
    const { signature, pubKey, pubKey_uncompressed, pub_key_x, pub_key_y } = await extractPubkeyAndSignedMessage();
    console.log(`signature: ${ signature }`); // [Log]: 
}

/**
 * @notice - Execute the main function
 */
main().then((result) => {
    console.log(`Result: ${result}`);
  }).catch((error) => {
    console.error(`Error: ${error}`);
  });