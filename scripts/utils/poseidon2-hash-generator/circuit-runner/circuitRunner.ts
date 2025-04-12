import { Noir } from "@noir-lang/noir_js";
import { UltraHonkBackend } from "@aztec/bb.js";
//import circuitArtifact from "../../../../circuits/target/ip_nft_ownership.json";

import { ProofData, CompiledCircuit } from "@noir-lang/types";
import { compile, createFileManager } from '@noir-lang/noir_wasm';
import { join, resolve } from 'path';
  
/**
 * @notice - Generate a proof using the Noir circuit
 */
export async function generateProof() {
    // Get the input data for the circuit
    const input_data = getInputDataForCircuit();
  
    // Get the circuit artifact
    const circuitArtifact = await getCircuit('/'); // [NOTE]: This is the path to the Nargo.toml in the ./circuits directory
  
    // Create a Noir instance and UltraHonkBackend instance
    const noir = new Noir(circuitArtifact as CompiledCircuit);
    const backend = new UltraHonkBackend(circuitArtifact.bytecode);
  
    // Generate witness and prove
    const startTime = performance.now();
    const { witness } = await noir.execute(input_data);
    const proof = await backend.generateProof(witness); // This "proof" generated would includes both the "proof.proof" and "proof.publicInputs"
    const provingTime = performance.now() - startTime;
  
    return { 
        proof: proof.proof,
        publicInputs: proof.publicInputs, 
        provingTime,
        input_data
    };  // The "public input" data can be retrieved via the "proof.publicInputs"
}
  
/**
 * @notice - Compile the Noir circuit
 */
async function getCircuit(name: string): Promise<CompiledCircuit> {
    const basePath = resolve(join("circuits", name)); // [NOTE]: This is the path to the Nargo.toml in the ./circuits directory
    const fm = createFileManager(basePath);
    const compiled = await compile(fm, basePath);
    if (!("program" in compiled)) {
      throw new Error("Compilation failed");
    }
    const compiledCircuit = compiled.program;
    return compiledCircuit;
  }

  function getInputDataForCircuit() {
    //const mainInput = { x: 1, y: 2 };
    const input_data = {
      root: "0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629",
      hash_path: [
          "0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8", 
          "0x2a653551d87767c545a2a11b29f0581a392b4e177a87c8e3eb425c51a26a8c77"
      ],
      index: 0,
      secret: 1,
      expected_nullifier: "0x26df0d347e961cb94e1cc6d2ad8558696de8c1964b30e26f2ec8b926cbbbf862",
      //expected_nullifier: "10190015755989328289879378487807721086446093622177241109507523918927702106995",
      //expected_nullifier: "0x168758332d5b3e2d13be8048c8011b454590e06c44bce7f702f09103eef5a373"
      expected_nft_metadata_cid_hash: "0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0",

      //[ip_nft_data]
      ip_nft_data: {
        nft_owner: "0xC6093Fd9cc143F9f058938868b2df2daF9A91d28",
        nft_token_id: "1",
        nft_metadata_cid: "QmYwAPJzv5CZsnAzt8auVZRn5W4mBkpLsD4HaBFN6r5y6F"
        //nft_metadata_hash: "0x1efa9d6bb4dfdf86063cc77efdec90eb9262079230f1898049efad264835b6c8"
      }
    }
  
    return input_data;
    //return { root, hash_path, index, secret, expected_nullifier, ip_nft_data };
  }