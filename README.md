# ZK Insurance Claim on Swell Chain 🛡️

## Tech Stack

- `ZK circuit`: Written in [`Noir`](https://noir-lang.org/docs/) powered by [Aztec](https://aztec.network/)) 
- Smart Contract: Written in Solidity (Framework: Foundry)
- Blockchain: [`Swell Chain`](https://build.swellnetwork.io/docs/guides/getting-started) (Testnet)

<br>

## Overview

<br>

## Userflow

<br>

## Diagram of Userflow


<br>

## Deployed-smart contracts on [`Swell Chain`](https://build.swellnetwork.io/docs/guides/getting-started) (Testnet)

| Contract Name | Descripttion | Deployed-contract addresses on `Swell Chain` (Testnet) | Contract Source Code Verified |
| ------------- |:------------:|:--------------------------------------------------:|:-----------------------------:|

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

## ZK circuit - Test

```bash
cd circuits
sh circuit_test.sh
```

<br>

## SC - Script
- Install `npm` modules - if it's first time to run this script. (From the second time, this installation step can be skipped):
```bash
cd script/utils/poseidon2-hash-generator
npm i
```

- Run the `Verify.s.sol` on the Local Network
```bash
sh ./scripts/runningScript_Verify.sh
```

- Run the `Verify_onSwellChainTestnet.s.sol` on the Swell Chain Testnet
```bash
sh ./scripts/swellchain-testnet/runningScript_Verify_onSwellChainTestnet.sh
```

- NOTE: The ProofConverter#`sliceAfter96Bytes()` would be used in the both script file above.
  - The reason is that the number of public inputs is `3` (`bytes32 * 3 = 96 bytes`), meaning that the proof file includes `96 bytes` of the public inputs **at the beginning**. 
     - Hence it should be removed by using the `sliceAfter96Bytes()` 


<br>

## SC - Test
- Run the `Starter.t.sol` on the Local Network
```bash
sh ./test/circuit/runningTest_Starter.sh
```

- Run the `Starter_onSwellChainTestnet.t.sol` on the Swell Chain Testnet
```bash
sh ./test/swellchain-testnet/runningTest_Starter_onSwellChainTestnet.sh
```


<br>

## Deployment
- Run the `DeploymentAllContracts.s.sol`
```bash
sh ./script/swellchain-testnet/deployment/deploymentScript_AllContracts.sh
```


<br>

## Utils

### Hashing with Poseidon2 Hash (Async)
- Run the `poseidon2HashGeneratorWithAsync.ts`
```bash
sh script/utils/poseidon2-hash-generator/usages/async/runningScript_poseidon2HashGeneratorWithAsync.sh
```
↓
- By running the script above, an `output.json` file like below would be exported and saved to the `script/utils/poseidon2-hash-generator/usages/async/output` directory:
```json
{
  "hash": "17581986279560538761428021143884026167649881764772625124550680138044361406562",
  "nullifier": "0x26df0d347e961cb94e1cc6d2ad8558696de8c1964b30e26f2ec8b926cbbbf862",
  "nftMetadataCidHash": "0x0c863c512eaa011ffa5d0f8b8cfe26c5dfa6c0e102a4594a3e40af8f68d86dd0",
  "merkleRoot": "0x215597bacd9c7e977dfc170f320074155de974be494579d2586e5b268fa3b629"
}
```
(NOTE: To generate a **Poseidon Hash** (`hash`), the [`@zkpassport/poseidon2`](https://github.com/zkpassport/poseidon2/tree/main) library would be used)

<br>


## References

- Noir:
  - Doc: https://noir-lang.org/docs/getting_started/quick_start

<br>

- Swell Chain:
  - Doc: https://build.swellnetwork.io/docs/guides/getting-started



<br>

<hr>

# Noir with Foundry

This example uses Foundry to deploy and test a verifier.

## Getting Started

Want to get started in a pinch? Start your project in a free Github Codespace!

[![Start your project in a free Github Codespace!](https://github.com/codespaces/badge.svg)](https://codespaces.new/noir-lang/noir-starter)

In the meantime, follow these simple steps to work on your own machine:

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

## Generate verifier contract and proof

### Contract

The deployment assumes a verifier contract has been generated by nargo. In order to do this, run:

```bash
cd circuits
nargo compile
bb write_vk -b ./target/insurance_claim.json
bb contract
```

A file named `contract.sol` should appear in the `circuits/target` folder.

### Test with Foundry

We're ready to test with Foundry. There's a basic test inside the `test` folder that deploys the
verifier contract, the `Starter` contract and two bytes32 arrays correspondent to good and bad
solutions to your circuit.

By running the following command, forge will compile the contract with 5000 rounds of optimization
and the London EVM version. **You need to use these optimizer settings to suppress the "stack too
deep" error on the solc compiler**. Then it will run the test, expecting it to pass with correct
inputs, and fail with wrong inputs:

```bash
forge test --optimize --optimizer-runs 5000 --evm-version cancun
```

#### Testing On-chain

You can test that the Noir Solidity verifier contract works on a given chain by running the
`Verify.s.sol` script against the appropriate RPC endpoint.

```bash
forge script script/Verify.s.sol --rpc-url $RPC_ENDPOINT  --broadcast
```

If that doesn't work, you can add the network to Metamask and deploy and test via
[Remix](https://remix.ethereum.org/).

Note that some EVM network infrastructure may behave differently and this script may fail for
reasons unrelated to the compatibility of the verifier contract.

### Deploy with Foundry

This template also has a script to help you deploy on your own network. But for that you need to run
your own node or, alternatively, deploy on a testnet.

#### (Option 1) Run a local node

If you want to deploy locally, run a node by opening a terminal and running

```bash
anvil
```

This should start a local node listening on `http://localhost:8545`. It will also give you many
private keys.

Edit your `.env` file to look like:

```
ANVIL_RPC=http://localhost:8545
LOCALHOST_PRIVATE_KEY=<the private key you just got from anvil>
```

#### (Option 2) Prepare for testnet

Pick a testnet like Sepolia or Goerli. Generate a private key and use a faucet (like
[this one for Sepolia](https://sepoliafaucet.com/)) to get some coins in there.

Edit your `.env` file to look like:

```env
SEPOLIA_RPC=https://rpc2.sepolia.org
LOCALHOST_PRIVATE_KEY=<the private key of the account with your coins>
```

#### Run the deploy script

You need to source your `.env` file before deploying. Do that with:

```bash
source .env
```

Then run the deployment with:

```bash
forge script script/Starter.s.sol --rpc-url $ANVIL_RPC --broadcast --verify
```

Replace `$ANVIL_RPC` with the testnet RPC, if you're deploying on a testnet.

## Developing on this template

This template doesn't include settings you may need to deal with syntax highlighting and
IDE-specific settings (i.e. VScode). Please follow the instructions on the
[Foundry book](https://book.getfoundry.sh/config/vscode) to set that up.

It's **highly recommended** you get familiar with [Foundry](https://book.getfoundry.sh) before
developing on this template.
