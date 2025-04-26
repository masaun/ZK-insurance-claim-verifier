# 【IN PROGRESS】ZK Insurance Claim Verifier on Swell Chain 🛡️

## Tech Stack

- `ZK circuit`: Implemented in [`Noir`](https://noir-lang.org/docs/) powered by [Aztec](https://aztec.network/)) 
- Smart Contract: Implemented in Solidity (Framework: Foundry)
- Blockchain: [`Swell Chain`](https://build.swellnetwork.io/docs/guides/getting-started) (Testnet)

<br>

## Overview

- This is the Zero-Knowledge (ZK) based Insurance Claim protocol, which allow a patient to claim a payout without revealing the sensitive information (i.e. exact treatment, treatment cost, coverage, etc) to a insurer by submitting a hospital bill proof (which is a ZK Proof).

<br>

## Userflow

<br>

## Diagram of Userflow


<br>

## Deployed-smart contracts on [`Swell Chain`](https://build.swellnetwork.io/docs/guides/getting-started) (Testnet)

| Contract Name | Descripttion | Deployed-contract addresses on `Swell Chain` (Testnet) | Contract Source Code Verified |
| ------------- |:------------:|:--------------------------------------------------:|:-----------------------------:|
| UltraVerifier | The UltraPlonk Verifer contract (`./contracts/circuit/ultra-verifier/plonk_vk.sol`), which is generated based on ZK circuit in Noir (`./circuits/src/main.nr`). FYI: To generated this contract, the way of the [Noir's Solidity Verifier generation](https://noir-lang.org/docs/how_to/how-to-solidity-verifier) was used. | [0x68fC0B89aa8591ff49065971ADFECeE42eF4cA36](https://swell-testnet-explorer.alt.technology/address/0x68fc0b89aa8591ff49065971adfecee42ef4ca36) | [Contract Source Code Verified](https://swell-testnet-explorer.alt.technology/address/0x68fc0b89aa8591ff49065971adfecee42ef4ca36?tab=contract) |
| InsuranceClaimProofVerifier | The InsuranceClaimProofVerifier contract, which the validation using the UltraVerifier contract is implemented | [0xE4531177030A7bD88eb58c6ADEe0e4155AfCaeCf](https://swell-testnet-explorer.alt.technology/address/0xe4531177030a7bd88eb58c6adee0e4155afcaecf) | [Contract Source Code Verified](https://swell-testnet-explorer.alt.technology/address/0xe4531177030a7bd88eb58c6adee0e4155afcaecf?tab=contract) |



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

- Run the ZK circuit (`./circuits/src/main.nr`) via the `./circuits/build.sh` to generate a ZKP (Zero-Knowledge Proof), which is called a `ip_nft_ownership` proof:
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

## Smart Contract - Test (NOTE: This is still *in progress*)
- Run the `InsuranceClaimProofVerifier.t.sol` on the Local Network (NOTE: This is still *in progress*)
```bash
sh ./test/circuit/runningTest_InsuranceClaimProofVerifier.sh
```

<br>

## Deployment on Swell Chain testnet
- Run the `DeploymentAllContracts.s.sol` to deploy the `UltraVerifier` contract and the `InsuranceClaimProofVerifier` contract on Swell Chain testnet:
```bash
sh ./scripts/swellchain-testnet/deployment/deploymentScript_AllContracts.sh
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