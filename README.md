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

<br>

<hr>

# Installation

## SC - script
- Run the `Verify.s.sol`
```bash
sh ./scripts/runningScript_Verify.sh
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