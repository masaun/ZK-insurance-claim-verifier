# Safe Anonymization Mail Module Circuits

This repository contains the circuit part of the SAMM project.

## Description

This implementation of the circuits is for the Noir grant.

Our main concept revolves around creating a module for the Safe multisig that ensures the anonymity of all its participants using ZK-SNARK technology.

The details are outlined in:
- [Technical docs](https://www.notion.so/oxorioteam/SAMM-technical-requirements-7c42604654ba408ea68176fb609cf04b)
- [Grant Proposal](https://github.com/orgs/noir-lang/discussions/5813)

## Repository structure

This repository consists of several parts:
- **lib folder** - contains the `samm` Nargo library which implements the main logic of SAMM.
- **builds folder** - contains two Nargo bin projects: `samm_1024`, `samm_2048`. Both projects are built on top of the samm library and differ only in the size of the public key in the DKIM signature.
- **helpers folder** - contains auxiliary scripts needed for preparing data for tests.

## Dependencies

The circuits are written in Noir and use the Barretenberg proving library. To work correctly, the following versions are required:
- Noir v0.35.0
- BB v0.57.0

### Install the required version of Noir 
1. Open a terminal on your machine, and write:
    ```
        curl -L https://raw.githubusercontent.com/noir-lang/noirup/main/install | bash
    ```
2. Close the terminal, open another one, and run:
    ```
        noirup -v v0.35.0
    ```
Done. That's it. You should have the latest version working. You can check with `nargo --version`.
Complete instructions for installing Noir and Nargo can be [found here](https://noir-lang.org/docs/getting_started/installation/).

### Install the required version of Barretenberg (BB)
1. Install bbup the installation script by running this in your terminal:
    ```
        curl -L https://raw.githubusercontent.com/AztecProtocol/aztec-packages/master/barretenberg/cpp/installation/install | bash
    ```
2. Reload your terminal shell environment.
3. Install the version of bb compatible with your Noir version:
    ```
        bbup -v 0.57.0
    ```
4. Check if the installation was successful:
    ```
        bb --version
    ```
Complete instructions for installing Barretenberg can be [found here](https://github.com/AztecProtocol/aztec-packages/blob/master/barretenberg/cpp/src/barretenberg/bb/readme.md#installation).


## Compilation

To compile a nargo project (separately in the folders `./lib`, `./builds/samm_2048`, `./builds/samm_1024`):
```
  nargo compile
```

## Run tests

To run the tests (separately in the folders `./lib`, `./builds/samm_2048`, `./builds/samm_1024`):

```
  nargo test
```

## Generate/verify proof

1. Open one of the builds (1024 or 2048 signature) by running:
    ```
        cd builds/samm_2048
    ```
    or
    ```
        cd builds/samm_1024
    ```

2. Generate a witness for your Noir program by running:
    ```
        nargo execute witness-samm
    ```

3. Prove the valid execution of your Noir program by running:
    ```
        bb prove_ultra_honk -b ./target/samm_2048.json -w ./target/witness-samm.gz -o ./target/proof
    ```
    For the Solidity Verifier, run:
    ```
        bb prove_ultra_keccak_honk -b ./target/samm_2048.json -w ./target/witness-samm.gz -o ./target/proof2048
    ```
    Or for the 1024 signature:
    ```
        bb prove_ultra_honk -b ./target/samm_1024.json -w ./target/witness-samm.gz -o ./target/proof
    ```
    and
    ```
        bb prove_ultra_keccak_honk -b ./target/samm_1024.json -w ./target/witness-samm.gz -o ./target/proof1024
    ```

4. Compute the verification key for your Noir program by running:
    ```
        bb write_vk_ultra_honk -b ./target/samm_2048.json -o ./target/vk
    ```
    Or for the 1024 signature:
    ```
        bb write_vk_ultra_honk -b ./target/samm_1024.json -o ./target/vk
    ```

5. Verify your proof by running:
    ```
        bb verify_ultra_honk -k ./target/vk -p ./target/proof
    ```
    If successful, the verification will complete silently; if unsuccessful, the command will trigger logging of the corresponding error.

6. Generate the Solidity Verifier contract:
    ```
        bb contract_ultra_honk -k ./target/vk -c $CRS_PATH -b ./target/samm_2048.json -o ./target/Verifier2048.sol
    ```
    Or for the 1024 signature:
    ```
        bb contract_ultra_honk -k ./target/vk -c $CRS_PATH -b ./target/samm_1024.json -o ./target/Verifier1024.sol
    ```

## Helpers

The helpers folder contains auxiliary scripts needed for preparing data for tests, specifically for generating a custom `Prover.toml` file. Note that the prepared `Prover.toml` files are already located in the folders `./builds/samm_2048` and `./builds/samm_1024`, so this step is optional.

**Disclaimer**: The code in the `Helpers` folder was only used for development and should never be run in production. Also, this code should not be subject to an audit.

### Parse email

The `email_parser` project allows you to extract part of the public signals for the `Prover.toml` file from an email.

To do this, go to the necessary folder:
``` 
    cd helpers/email_parser
```
and run the script:
```
    cargo run --release
```
As a result, you will get a `Prover_email.toml` file with circuit's input signals inside. This file should be combined with the `Prover_tree.toml` from the `member_tree_generator` to compile the resulting `Prover.toml`.

### Generate Merkle Tree

The `member_tree_generator` project allows generating a Merkle tree proof for a specific member of SAMM.

To run this, go to the necessary folder:
``` 
    cd helpers/member_tree_generator
```
Install the dependencies:
```
    npm install
```
And run the script:
```
    npx run scripts/generateDataForTest.js
```
As a result, you will get a `Prover_tree.toml` file with a Merkle proof (circuit's input signal) inside. This file should be combined with the `Prover_email.toml` from the `email_parser` to compile the resulting `Prover.toml`.

### Prepare proof for smart contract tests

[Get proof](https://noir-lang.org/docs/how_to/how-to-solidity-verifier#step-4---verifying) for SC part tests:
```
  cat ./target/proof2048 | od -An -v -t x1 | tr -d $' \n' | sed 's/^.\{8\}//' | (read hex; echo "${hex:0:192}${hex:12864}")
```
Where `192 + 198 * 64 = 12864`. 198 - number of public inputs.

Commit and pubkeyHash for SC part tests:
```
  cat ./target/proof2048 | od -An -v -t x1 | tr -d $' \n' | sed 's/^.\{8\}//' | (read hex; echo "${hex:12736:128}")
```

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.