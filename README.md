# 【IN PROGRESS】ZK Insurance Claim on Swell Chain 🛡️

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

# Installation

## SC - script
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

## SC - test

```bash
sh ./test/circuit/runningTest_InsuranceClaimProofVerifier.sh
```

<br>

## Deployment
- Run the `DeploymentAllContracts.s.sol`
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