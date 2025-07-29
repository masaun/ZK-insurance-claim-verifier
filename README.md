# ZK (Zero-Knowledge) Insurance Claim Verifier contract

## Tech Stack

- `ZK circuit`: Implemented in [`Noir`](https://noir-lang.org/docs/), which is powered by [Aztec](https://aztec.network/)
- Smart Contract: Implemented in Solidity (Framework: Foundry)
- Blockchain: [`Swell Chain`](https://build.swellnetwork.io/docs/guides/getting-started) (Testnet)

<br>

## Overview

- Currently, there are two problems in the system of Insurance (Payout) Claim:
  - In Web2 based system (Traditional system), it takes long time to validate whether or not an insurance claim from a patient is valid. Because a Web2 based system is essencially `"mutable"` and therefore an insurer must carefully check every evidence documents every time, which is inefficient. (Particulary, in the case that a insurer must collect evidence documents from multiple third parties and they need to get approval from them, it takes more time to vaildate an insurance claim)

  - In Web3 based system, every informations must be `"public"` - even if these informations includes a lot of sensitive data.


- The **`Zero-Knowledge` (`ZK`) based Insurance Claim Verifier** contract can resolve the problems above by combination of a `ZK Proof` and a **Smart Contract**:
  - The ZK Insurance Claim Verifier contract allow a patient to claim a payout **without revealing** the **sensitive informations** (icl. patient name, patient age, treatment details, treatment cost, coverage, etc) to a insurer by submitting a `insurance claim proof` (which is a `ZK Proof`).
      - In other words, this protocol allow a patient to claim a payout in a `privacy-preserving` way thanks to using `Zero-Knowledge Proof` (`ZK Proof`).

  - Also, the ZK Insurance Claim Verifier contract would enable a insurer to prevent from a fake insurance claim and consuming a lot of time to validate whether or not an insurance claim is valid claim.

<br>

## Userflow

- 0/ A **patient** took a treatment, which is provided by a **hospital** (Healthcare Provider).
- 1/ The patient would send the **input data**, which includes the sensitive data (i.e. biographical data, hostital bill data, insurance policy data) to the **ZK circuit**-written in `Noir`.
- 2/ A new **ZK (Zero-Knowledge) Proof** would be generated via **ZK circuit** and then the patient would receive it /w **public inputs** (by downloading them in the form of a plain text file).
   - NOTE: This *public inputs* would includes only data, which can be disclosed as a public data. (The sensitive data is **not** included)
- 3/ The patient would call the `submitInsuranceClaim()` in the `InsuranceClaim.sol` with a `ZK Proof` and `public inputs`.
- 4/ The `InsuranceClaim.sol` would call the `verify()` in the `UltraVerifier.sol` via the `verifyInsuranceClaimProof()` in the `InsuranceClaimProofVerifier.sol` in order to validate whether or not a given `ZK Proof` and `public inputs` is a valid proof and public inputs.
  - Then, the `verify()` in the `UltraVerifier.sol` would return the result of validation to the `InsuranceClaim.sol` via the `verifyInsuranceClaimProof()` in the `InsuranceClaimProofVerifier.sol`.

- 5/ If the result (return value) of ZK proof (icl. public inputs) validation from the step 4/ above would be `true`, the `InsuranceClaim.sol` will send an insurance **payout** (i.e. via the `sendPayout()`).


- NOTE: 
  - The `InsuranceClaim.sol` (icl. `submitInsuranceClaim()`, `sendPayout()`) in the userflow above is an example smart contract/function. (Not implemented yet)
  - Any project, which hope to integrate the `InsuranceClaimProofVerifier.sol`, can freely implement an **custom contract** like `InsuranceClaim.sol` in the userflow above that handle a insurance payout

<br>

## Diagram of Architecure
- Diagram of Architecure: https://github.com/masaun/ZK-insurance-claim/tree/main/doc/diagram-of-architecture

- NOTE: 
  - The `InsuranceClaim.sol` (icl. `submitInsuranceClaim()`, `sendPayout()`) in the diagram above is an example smart contract. (Not implemented yet)
  - Any project, which hope to integrate the `InsuranceClaimProofVerifier.sol`, can freely implement an **custom contract** like `InsuranceClaim.sol` in the diagram above that handle a insurance payout

<br>

## DEMO Video
- https://vimeo.com/1086225058/fa74b2fad2

<br>

## Deployed-smart contracts on [`Swell Chain`](https://build.swellnetwork.io/docs/guides/getting-started) (Testnet)

| Contract Name | Descripttion | Deployed-contract addresses on `Swell Chain` (Testnet) | Contract Source Code Verified |
| ------------- |:------------:|:--------------------------------------------------:|:-----------------------------:|
| UltraVerifier | The UltraPlonk Verifer contract (`./contracts/circuit/ultra-verifier/plonk_vk.sol`), which is generated based on ZK circuit in Noir (`./circuits/src/main.nr`). FYI: To generated this contract, the way of the [Noir's Solidity Verifier generation](https://noir-lang.org/docs/how_to/how-to-solidity-verifier) was used. | [0x68fC0B89aa8591ff49065971ADFECeE42eF4cA36](https://swell-testnet-explorer.alt.technology/address/0x68fc0b89aa8591ff49065971adfecee42ef4ca36) | [Contract Source Code Verified](https://swell-testnet-explorer.alt.technology/address/0x68fc0b89aa8591ff49065971adfecee42ef4ca36?tab=contract) |
| InsuranceClaimProofVerifier | The InsuranceClaimProofVerifier contract, which the validation using the UltraVerifier contract is implemented | [0xE4531177030A7bD88eb58c6ADEe0e4155AfCaeCf](https://swell-testnet-explorer.alt.technology/address/0xe4531177030a7bd88eb58c6adee0e4155afcaecf) | [Contract Source Code Verified](https://swell-testnet-explorer.alt.technology/address/0xe4531177030a7bd88eb58c6adee0e4155afcaecf?tab=contract) |


<br>

## Future plan

- Implement the standard `InsuranceClaim` contract (`InsuranceClaim.sol`).

- Implement two more `ZK circuits`:
  - One is a ZK circuit that a hospital (healthcare provider) can generate a hostital bill proof. And then, a generated-ZK proof should be sent to a patient.
  - Another is a ZK circuit that an insurer can generate a insurance policy proof. And then, a generated-ZK proof should be sent to a patient.
   
- Modify the current main ZK circuit to a new main ZK circuit like this:
  - A patient will send the input data, which includes the two ZK proof-generated the two new ZK circuits above.
    - a new main ZK circuit will create an `recurcive proof`, including the two ZK Proofs above.

<br>

<br>

<hr>


<br>

## Installation - Noir and Foundry

Install [noirup](https://noir-lang.org/docs/getting_started/noir_installation) with

1. Install [noirup](https://noir-lang.org/docs/getting_started/noir_installation):

   ```bash
   curl -L https://raw.githubusercontent.com/noir-lang/noirup/main/install | bash
   ```

2. Install Nargo:

   ```bash
   noirup
   ```

3. Install foundryup and follow the instructions on screen. You should then have all the foundry
   tools like `forge`, `cast`, `anvil` and `chisel`.

```bash
curl -L https://foundry.paradigm.xyz | bash
```

4. Install foundry dependencies by running `forge install 0xnonso/foundry-noir-helper --no-commit`.

5. Install `bbup`, the tool for managing Barretenberg versions, by following the instructions
   [here](https://github.com/AztecProtocol/aztec-packages/blob/master/barretenberg/bbup/README.md#installation).

6. Then run `bbup`.

<br>

## Set the environment file (`env`)

- Create the `env` file:
  - Then, please add a `<Private Key>` of your wallet address to the `"SWELL_CHAIN_TESTNET_PRIVATE_KEY"` in the `.env`.
```bash
cp .env.example .env
```

<br>

## ZK circuit - Test

- Run the test of the ZK circuit (`./circuits/src/tests/mod.nr`) via the `./circuits/circuit_test.sh`:
```bash
cd circuits
sh circuit_test.sh
```

<br>

## ZK circuit - Generate a ZKP (Zero-Knowledge Proof)

- Create the `Prover.toml` by copying the `Prover.example.toml`. Then, appropreate values should be stored into there.
```bash
cd circuits
cp Prover.example.toml Prover.toml
```

- Run the ZK circuit (`./circuits/src/main.nr`) via the `./circuits/build.sh` to generate a ZKP (Zero-Knowledge Proof), which is called a `insurance_claim_proof` proof:
```bash
cd circuits
sh build.sh
```

<br>

## Smart Contract - Compile
- Compile the smart contracts:
```bash
sh buildContract.sh
```

<br>

## Smart Contract - Script
- Install `npm` modules - if it's first time to run this script. (From the second time, this installation step can be skipped):
```bash
cd script/utils/poseidon2-hash-generator
npm i
```

<br>

- Run the `Verify.s.sol` on Local Network
```bash
sh ./scripts/runningScript_Verify.sh
```

<br>

- Run the `Verify.s.sol` on `Swell Chain (Testnet)`
```bash
sh ./scripts/swellchain-testnet/runningScript_Verify_onSwellChainTestnet.sh
```

<br>

- NOTE: The ProofConverter#`sliceAfter192Bytes()` would be used in the both script file above.
  - The reason is that the number of public inputs is `6` (`bytes32 * 6 = 192 bytes`), meaning that the proof file includes `192 bytes` of the public inputs **at the beginning**. 
     - Hence it should be removed by using the `sliceAfter192Bytes()` 

<br>

## Smart Contract - Test
- Run the `InsuranceClaimProofVerifier.t.sol` on the Local Network:
```bash
sh ./test/circuit/runningTest_InsuranceClaimProofVerifier.sh
```

- Run the `InsuranceClaimProofVerifier_onSwellChainTestnet.t.sol` on the `Swell Chain` Testnet:
```bash
sh ./test/swellchain-testnet/circuit/runningTest_InsuranceClaimProofVerifier_onSwellChainTestnet.sh
```

<br>

## Deployment on Swell Chain testnet
- Run the `DeploymentAllContracts.s.sol` to deploy the `UltraVerifier` contract and the `InsuranceClaimProofVerifier` contract on Swell Chain testnet:
```bash
sh ./scripts/swellchain-testnet/deployment/deploymentScript_AllContracts.sh
```

<br>

## Deployment on BASE testnet
- Run the `DeploymentAllContracts.s.sol` to deploy the `UltraVerifier` contract and the `InsuranceClaimProofVerifier` contract on BASE testnet:
  - NOTE: The smart contract is verified in `BlockScount` of Base Testnet (https://base-sepolia.blockscout.com)
```bash
sh ./scripts/base-testnet/deployment/deploymentScript_AllContracts.sh
```

<br>

## Deployment on BASE mainnet (`All`)
- Run the `DeploymentAllContracts.s.sol` to deploy the `UltraVerifier` contract and the `InsuranceClaimProofVerifier` contract on BASE mainnet:
  - NOTE: The smart contract is verified in `BlockScount` of Base Mainnet (https://base.blockscout.com)
```bash
sh ./scripts/base-mainnet/deployment/deploymentScript_AllContracts.sh
```

<br>

## Deployment on BASE mainnet (`Each SC`)
- Run the `DeploymentForInsuranceClaimProofVerifier_blockscout.s.sol` to deploy the  `InsuranceClaimProofVerifier` contract on BASE mainnet:
  - NOTE: The smart contract is verified via the `BlockScount` of Base Mainnet (https://base.blockscout.com)
```bash
sh ./scripts/base-mainnet/deployment/deploymentScript_InsuranceClaimProofVerifier_via_blockscout.sh
```

<br>

- Run the `DeploymentForInsuranceClaimProofVerifier_basescan.s.sol` to deploy the  `InsuranceClaimProofVerifier` contract on BASE mainnet:
  - NOTE: The smart contract is verified via the `BaseScan` of Base Mainnet (https://basescan.org)
```bash
sh ./scripts/base-mainnet/deployment/deploymentScript_InsuranceClaimProofVerifier_via_basescan.sh
```

<br>

## Deployment on Celo mainnet (`Each SC`)
- Run the `DeploymentForInsuranceClaimProofVerifier_blockscout.s.sol` to deploy the  `InsuranceClaimProofVerifier` contract on Celo mainnet:
  - NOTE: The smart contract is verified via the `BlockScount` of Celo Mainnet (https://celo.blockscout.com)
```bash
sh ./scripts/celo-mainnet/deployment/deploymentScript_InsuranceClaimProofVerifier_via_blockscout.sh
```

<br>

- Run the `DeploymentForInsuranceClaimProofVerifier_celoscan.s.sol` to deploy the  `InsuranceClaimProofVerifier` contract on BASE mainnet:
  - NOTE: The smart contract is verified via the `CeloScan` of Celo Mainnet (https://celoscan.io)
```bash
sh ./scripts/base-mainnet/deployment/deploymentScript_InsuranceClaimProofVerifier_via_celoscan.sh
```

<br>

## Verification on BASE mainnet (`Each SC`)
- Run for verifying the  `InsuranceClaimProofVerifier` contract on BASE mainnet:
  - NOTE: The smart contract is verified in `BaseScan` of Base Mainnet ()
```bash
sh ./scripts/base-mainnet/verification/verificationScript_InsuranceClaimProofVerifier_via_basescan.sh
```

<br>

- Run for verifying the  `InsuranceClaimProofVerifier` contract on BASE mainnet:
  - NOTE: The smart contract is verified in `BlockScout` of Base Mainnet ()
```bash
sh ./scripts/base-mainnet/verification/verificationScript_InsuranceClaimProofVerifier_via_blockscout.sh
```

<br>

## Verification on Celo mainnet (`Each SC`)
- Run for verifying the  `InsuranceClaimProofVerifier` contract on Celo mainnet:
  - NOTE: The smart contract is verified in `CeloScan` of Celo Mainnet ()
```bash
sh ./scripts/celo-mainnet/verification/verificationScript_InsuranceClaimProofVerifier_via_celoscan.sh
```

<br>

- Run for verifying the  `InsuranceClaimProofVerifier` contract on Celo mainnet:
  - NOTE: The smart contract is verified in `BlockScout` of Celo Mainnet ()
```bash
sh ./scripts/celo-mainnet/verification/verificationScript_InsuranceClaimProofVerifier_via_blockscout.sh
```

<br>

## Utils - Array Bytes generator

- Run the `randomArrayBytesGenerator.ts`
```bash
sh ./scripts/utils/array-bytes-generator/random-array-bytes-generator/runningScript_randomArrayBytesGenerator.sh
```

- Run the `randomArrayBytesGeneratorWithEthersjs.ts`
```bash
sh ./scripts/utils/array-bytes-generator/random-array-bytes-generator/runningScript_randomArrayBytesGeneratorWithEthersjs.sh
```

- Run the `pubkeyAndSignedMessageExtractor.ts`
```bash
sh ./scripts/utils/array-bytes-generator/pubkey-and-signed-message-extractor/runningScript_pubkeyAndSignedMessageExtractor.sh
```

<br>

## References and Resources

- Noir:
  - Doc: https://noir-lang.org/docs/getting_started/quick_start


- Swell Chain testnet: 
  - Block Explorer: https://edu-chain-testnet.blockscout.com
  - Network Info (icl. RPC, etc): https://build.swellnetwork.io/docs/guides/getting-started#network-configuration
  - Chainlist：https://chainlist.org/?search=swell&testnets=true
  - How to get ETH on Swell Chain testnet: https://build.swellnetwork.io/docs/guides/getting-started#obtaining-test-eth


- Node.js:  
  - How to run a Typescript (Node.js) file in shell script: https://nodejs.org/en/learn/typescript/run#running-typescript-with-a-runner