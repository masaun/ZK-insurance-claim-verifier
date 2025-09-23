import { type AccountWallet, type ContractFunctionInteraction, type PXE, createPXEClient } from '@aztec/aztec.js';
import { getInitialTestAccountsWallets } from '@aztec/accounts/testing';

// Import the new Benchmark base class and context
import { Benchmark, BenchmarkContext } from '@defi-wonderland/aztec-benchmark';

import { NFTContract } from '../src/artifacts/NFT.js';
import { deployNFTWithMinter } from '../src/ts/test/utils.js';

// Extend the BenchmarkContext from the new package
interface NFTBenchmarkContext extends BenchmarkContext {
  pxe: PXE;
  deployer: AccountWallet;
  accounts: AccountWallet[];
  nftContract: NFTContract;
}

// Use export default class extending Benchmark
export default class NFTContractBenchmark extends Benchmark {
  /**
   * Sets up the benchmark environment for the NFTContract.
   * Creates PXE client, gets accounts, and deploys the contract.
   */
  async setup(): Promise<NFTBenchmarkContext> {
    const { BASE_PXE_URL = 'http://localhost' } = process.env;
    const pxe = createPXEClient(`${BASE_PXE_URL}:8080`);
    const accounts = await getInitialTestAccountsWallets(pxe);
    const deployer = accounts[0]!;
    const deployedBaseContract = await deployNFTWithMinter(deployer);
    const nftContract = await NFTContract.at(deployedBaseContract.address, deployer);
    return { pxe, deployer, accounts, nftContract };
  }

  /**
   * Returns the list of NFTContract methods to be benchmarked.
   */
  getMethods(context: NFTBenchmarkContext): ContractFunctionInteraction[] {
    const { nftContract, deployer, accounts } = context;
    const alice = deployer;
    const owner = alice.getAddress();

    const methods: ContractFunctionInteraction[] = [
      // Mint methods
      nftContract.withWallet(alice).methods.mint_to_private(owner, 1),
      nftContract.withWallet(alice).methods.mint_to_public(owner, 2),

      // Transfer methods
      nftContract.withWallet(alice).methods.transfer_private_to_public(owner, owner, 1, 0),
      nftContract.withWallet(alice).methods.transfer_public_to_private(owner, owner, 1, 0),
      nftContract.withWallet(alice).methods.transfer_private_to_private(owner, owner, 1, 0),
      nftContract.withWallet(alice).methods.transfer_public_to_public(owner, owner, 2, 0),

      // NOTE: don't have enough private NFT's to burn_private
      // nftContract.withWallet(alice).methods.transfer_private_to_public_with_commitment(owner, owner, 1, 0),

      // Burn methods
      nftContract.withWallet(alice).methods.burn_private(owner, 1, 0),
      nftContract.withWallet(alice).methods.burn_public(owner, 2, 0),
    ];

    return methods.filter(Boolean);
  }
}
