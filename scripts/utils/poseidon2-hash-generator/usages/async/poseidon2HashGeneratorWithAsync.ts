import * as fs from "fs";

import { poseidon2HashAsync } from "@zkpassport/poseidon2"
import { generateProof } from "../../circuit-runner/circuitRunner";

/** 
 * @notice - Get the poseidon hash from the specified data asynchronously
 */
async function computePoseidon2Hash() {
  // @dev - Generate a proof using the Noir circuit and NoirJS and retrieve the "public inputs".
  const { proof, publicInputs, provingTime, input_data } = await generateProof();
  console.log(`publicInputs (proof.publicInputs): ${ publicInputs }`);
  console.log(`root (proof.publicInputs[0])): ${ publicInputs[0] }`);      // [Log]: 0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629
  console.log(`nullifier (proof.publicInputs[1])): ${ publicInputs[1] }`); // [Log]: 0x168758332d5b3e2d13be8048c8011b454590e06c44bce7f702f09103eef5a373
  console.log(`nft_metadata_cid_hash (proof.publicInputs[2])): ${ publicInputs[2] }`); // [Log]: 0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0
  console.log(`provingTime (ms): ${ provingTime }`); // [Log]: 0.
  console.log(`input_data: ${ input_data }`); // [Log]: 0.0000000000000001
  const merkleRoot = publicInputs[0];
  const nullifier = publicInputs[1];
  const nft_metadata_cid_hash = publicInputs[2];

  // Hash an array of bigints asynchronously
  const input_for_nullifier = getInputData(input_data);
  //const input = [1n, 2n, 3n]
  const hash = await poseidon2HashAsync(input_for_nullifier) // Using the asynchronous function
  console.log(hash) // Returns a single bigint hash value
  console.log(`hash (Poseidon2 hash): ${ hash }`); // Returns a single bigint hash value -> [Log]: 16068223842875184682212183064520144190817798559788034419026031423767658184152

  return { hash, nullifier, nft_metadata_cid_hash, merkleRoot };
}

/** 
 * @notice - Get the input data for the poseidon hash
 */
function getInputData(input_data: any) {

  input_data.root = BigInt(input_data.root);

  const root = BigInt(input_data.root);
  const secret = BigInt(input_data.secret);
  const nft_owner = BigInt(input_data.ip_nft_data.nft_owner);
  const nft_token_id = BigInt(input_data.ip_nft_data.nft_token_id);
  const nft_metadata_cid = String(input_data.ip_nft_data.nft_metadata_cid);
  //const root = BigInt(0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629);
  //const secret = BigInt(1);
  //const nft_owner = BigInt(0xC6093Fd9cc143F9f058938868b2df2daF9A91d28);
  //const nft_token_id = BigInt(1);
  //const nft_metadata_hash = BigInt(0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8);

  console.log(`nft_metadata_cid: ${nft_metadata_cid}`);
  const expected_nft_metadata_cid_hash = BigInt(input_data.expected_nft_metadata_cid_hash); // [NOTE]: This is the Poseidon Hash, which is converted from the "nft_metadata_cid" (CID)

  //const inputs_for_nullifier = [nft_token_id];
  const inputs_for_nullifier = [root, secret, nft_owner, nft_token_id, expected_nft_metadata_cid_hash];
  return inputs_for_nullifier;
}

/**
 * @notice - The function to export JSON file
 */
function exportJSON(data: object, filename: string = "output.json") {
  fs.writeFileSync(filename, JSON.stringify(data, null, 2), "utf-8");
  console.log(`JSON saved to ${filename}`);
}

/**
 * @notice - The main function
 */
async function main(): Promise<bigint> { // Mark the function as async
  const { hash, nullifier, nft_metadata_cid_hash, merkleRoot } = await computePoseidon2Hash(); // Await the promise
  console.log(`hash (Poseidon2 hash): ${ hash }`); // Returns a single BigInt hash value -> [Log]: 16068223842875184682212183064520144190817798559788034419026031423767658184152
  console.log(`nullifier: ${ hash }`);
  console.log(`nft_metadata_cid_hash: ${ nft_metadata_cid_hash }`); // [Log]: 0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0

  /// @dev - Export a return value (= hash) as a JSON file
  const result = {
    hash: String(hash),
    nullifier: String(nullifier),
    nftMetadataCidHash: String(nft_metadata_cid_hash),
    merkleRoot: String(merkleRoot),
    //message: "Poseidon2 hash-generated is successfully exported",
  };
  exportJSON(result, "scripts/utils/poseidon2-hash-generator/usages/async/output/output.json");

  return hash; // Return the resolved value
}

/**
 * @notice - Execute the main function
 */
main().then((result) => {
  console.log(`Result: ${result}`);
}).catch((error) => {
  console.error(`Error: ${error}`);
});