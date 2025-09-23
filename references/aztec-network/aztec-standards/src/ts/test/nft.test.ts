import { NFTContract, NFTContractArtifact } from '../../artifacts/NFT.js';
import {
  AccountWallet,
  CompleteAddress,
  Fr,
  PXE,
  TxStatus,
  getContractInstanceFromDeployParams,
  Contract,
  ContractDeployer,
  AccountWalletWithSecretKey,
  IntentAction,
  AztecAddress,
} from '@aztec/aztec.js';
import { getInitialTestAccountsWallets } from '@aztec/accounts/testing';
import { createPXE, setupSandbox } from './utils.js';

// Deploy NFT contract with a minter
async function deployNFTWithMinter(deployer: AccountWallet) {
  const contract = await Contract.deploy(
    deployer,
    NFTContractArtifact,
    ['TestNFT', 'TNFT', deployer.getAddress(), deployer.getAddress()],
    'constructor_with_minter',
  )
    .send()
    .deployed();
  return contract;
}

// Check if an address owns a specific NFT in public state
async function assertOwnsPublicNFT(
  nft: NFTContract,
  tokenId: bigint,
  expectedOwner: AztecAddress,
  caller?: AccountWallet,
) {
  const n = caller ? nft.withWallet(caller) : nft;
  const owner = await n.methods.public_owner_of(tokenId).simulate();
  expect(owner.equals(expectedOwner)).toBe(true);
}

// Check if an address owns a specific NFT in private state
async function assertOwnsPrivateNFT(nft: NFTContract, tokenId: bigint, owner: AztecAddress, caller?: AccountWallet) {
  const n = caller ? nft.withWallet(caller) : nft;
  const [nfts, _] = await n.methods.get_private_nfts(owner, 0).simulate();
  const hasNFT = nfts.some((id: bigint) => id === tokenId);
  expect(hasNFT).toBe(true);
}

// Check if an NFT has been nullified (no longer owned) in private state
async function assertPrivateNFTNullified(
  nft: NFTContract,
  tokenId: bigint,
  owner: AztecAddress,
  caller?: AccountWallet,
) {
  const n = caller ? nft.withWallet(caller) : nft;
  const [nfts, _] = await n.methods.get_private_nfts(owner, 0).simulate();
  const hasNFT = nfts.some((id: bigint) => id === tokenId);
  expect(hasNFT).toBe(false);
}

describe('NFT - Single PXE', () => {
  let pxe: PXE;
  let wallets: AccountWalletWithSecretKey[] = [];
  let accounts: CompleteAddress[] = [];

  let alice: AccountWallet;
  let bob: AccountWallet;
  let carl: AccountWallet;

  let nft: NFTContract;

  beforeAll(async () => {
    pxe = await setupSandbox();

    wallets = await getInitialTestAccountsWallets(pxe);
    accounts = wallets.map((w) => w.getCompleteAddress());

    alice = wallets[0];
    bob = wallets[1];
    carl = wallets[2];

    console.log({
      alice: alice.getAddress(),
      bob: bob.getAddress(),
    });
  });

  beforeEach(async () => {
    nft = (await deployNFTWithMinter(alice)) as NFTContract;
  });

  it('deploys the contract with minter', async () => {
    const salt = Fr.random();
    const [deployerWallet] = wallets; // using first account as deployer

    const deploymentData = await getContractInstanceFromDeployParams(NFTContractArtifact, {
      constructorArtifact: 'constructor_with_minter',
      constructorArgs: ['TestNFT', 'TNFT', deployerWallet.getAddress(), deployerWallet.getAddress()],
      salt,
      deployer: deployerWallet.getAddress(),
    });

    const deployer = new ContractDeployer(NFTContractArtifact, deployerWallet, undefined, 'constructor_with_minter');

    const tx = deployer
      .deploy('TestNFT', 'TNFT', deployerWallet.getAddress(), deployerWallet.getAddress())
      .send({ contractAddressSalt: salt });

    const receipt = await tx.getReceipt();

    expect(receipt).toEqual(
      expect.objectContaining({
        status: TxStatus.PENDING,
        error: '',
      }),
    );

    const receiptAfterMined = await tx.wait({ wallet: deployerWallet });

    const contractMetadata = await pxe.getContractMetadata(deploymentData.address);
    expect(contractMetadata).toBeDefined();
    expect(contractMetadata.isContractPubliclyDeployed).toBeTruthy();
    expect(receiptAfterMined).toEqual(
      expect.objectContaining({
        status: TxStatus.SUCCESS,
      }),
    );

    expect(receiptAfterMined.contract.instance.address).toEqual(deploymentData.address);
  }, 300_000);

  // --- Mint tests ---

  it('mints NFT to public', async () => {
    const tokenId = 1n;
    await nft.withWallet(alice).methods.mint_to_public(bob.getAddress(), tokenId).send().wait();

    // Verify bob owns the NFT publicly
    await assertOwnsPublicNFT(nft, tokenId, bob.getAddress());
  }, 300_000);

  it('mints NFT to private', async () => {
    const tokenId = 1n;
    await nft.withWallet(alice).methods.mint_to_private(bob.getAddress(), tokenId).send().wait();

    // Verify bob owns the NFT privately
    await assertOwnsPrivateNFT(nft, tokenId, bob.getAddress());
  }, 300_000);

  it('fails to mint when caller is not minter', async () => {
    const tokenId = 1n;

    // Bob attempts to mint when he's not the minter
    await expect(nft.withWallet(bob).methods.mint_to_public(bob.getAddress(), tokenId).send().wait()).rejects.toThrow(
      /^Transaction 0x[0-9a-f]+ was app_logic_reverted\. Reason: $/,
    );

    await expect(nft.withWallet(bob).methods.mint_to_private(bob.getAddress(), tokenId).send().wait()).rejects.toThrow(
      /Assertion failed: caller is not minter/,
    );
  }, 300_000);

  it('fails to mint same token ID twice', async () => {
    const tokenId = 1n;

    // First mint succeeds
    await nft.withWallet(alice).methods.mint_to_public(bob.getAddress(), tokenId).send().wait();

    // Second mint with same token ID should fail
    await expect(
      nft.withWallet(alice).methods.mint_to_public(carl.getAddress(), tokenId).send().wait(),
    ).rejects.toThrow(/^Transaction 0x[0-9a-f]+ was app_logic_reverted\. Reason: $/);
  }, 300_000);

  it('fails to mint with token ID zero', async () => {
    const tokenId = 0n;

    await expect(nft.withWallet(alice).methods.mint_to_public(bob.getAddress(), tokenId).send().wait()).rejects.toThrow(
      /^Transaction 0x[0-9a-f]+ was app_logic_reverted\. Reason: $/,
    );

    await expect(
      nft.withWallet(alice).methods.mint_to_private(bob.getAddress(), tokenId).send().wait(),
    ).rejects.toThrow(/zero token ID not supported/);
  }, 300_000);

  it('can mint multiple NFTs to same owner', async () => {
    const tokenId1 = 1n;
    const tokenId2 = 2n;

    // Mint two NFTs to bob
    await nft.withWallet(alice).methods.mint_to_private(bob.getAddress(), tokenId1).send().wait();
    await nft.withWallet(alice).methods.mint_to_private(bob.getAddress(), tokenId2).send().wait();

    // Verify bob owns both NFTs
    await assertOwnsPrivateNFT(nft, tokenId1, bob.getAddress());
    await assertOwnsPrivateNFT(nft, tokenId2, bob.getAddress());
  }, 300_000);

  // --- Burn tests ---

  it('burns NFT from public balance', async () => {
    const tokenId = 1n;

    // First mint NFT publicly to bob
    await nft.withWallet(alice).methods.mint_to_public(bob.getAddress(), tokenId).send().wait();

    // Verify bob owns the NFT publicly
    await assertOwnsPublicNFT(nft, tokenId, bob.getAddress());

    // Bob burns his NFT
    await nft.withWallet(bob).methods.burn_public(bob.getAddress(), tokenId, 0n).send().wait();

    // Verify the NFT no longer exists
    const owner = await nft.methods.public_owner_of(tokenId).simulate();
    expect(owner.equals(AztecAddress.ZERO)).toBe(true);
  }, 300_000);

  it('burns NFT from private balance', async () => {
    const tokenId = 1n;

    // First mint NFT privately to bob
    await nft.withWallet(alice).methods.mint_to_private(bob.getAddress(), tokenId).send().wait();

    // Verify bob owns the NFT privately
    await assertOwnsPrivateNFT(nft, tokenId, bob.getAddress());

    // Bob burns his NFT
    await nft.withWallet(bob).methods.burn_private(bob.getAddress(), tokenId, 0n).send().wait();

    // Verify the NFT is nullified
    await assertPrivateNFTNullified(nft, tokenId, bob.getAddress());
  }, 300_000);

  it('fails to burn NFT when caller is not owner', async () => {
    const tokenId = 1n;

    // First mint NFT publicly to bob
    await nft.withWallet(alice).methods.mint_to_public(bob.getAddress(), tokenId).send().wait();

    // Carl attempts to burn bob's NFT
    await expect(
      nft.withWallet(carl).methods.burn_public(carl.getAddress(), tokenId, 0n).send().wait(),
    ).rejects.toThrow(/^Transaction 0x[0-9a-f]+ was app_logic_reverted\. Reason: $/);

    // First mint NFT privately to bob
    const tokenId2 = 2n;
    await nft.withWallet(alice).methods.mint_to_private(bob.getAddress(), tokenId2).send().wait();

    // Carl attempts to burn bob's private NFT
    await expect(
      nft.withWallet(carl).methods.burn_private(carl.getAddress(), tokenId2, 0n).send().wait(),
    ).rejects.toThrow(/nft not found/);
  }, 300_000);

  it('fails to burn non-existent NFT', async () => {
    const tokenId = 999n;

    // Try to burn non-existent public NFT
    await expect(nft.withWallet(bob).methods.burn_public(bob.getAddress(), tokenId, 0n).send().wait()).rejects.toThrow(
      /^Transaction 0x[0-9a-f]+ was app_logic_reverted\. Reason: $/,
    );

    // Try to burn non-existent private NFT
    await expect(nft.withWallet(bob).methods.burn_private(bob.getAddress(), tokenId, 0n).send().wait()).rejects.toThrow(
      /nft not found/,
    );
  }, 300_000);

  // --- Transfer tests: private to private ---

  it('transfers NFT from private to private', async () => {
    const tokenId = 1n;

    // First mint NFT privately to alice
    await nft.withWallet(alice).methods.mint_to_private(alice.getAddress(), tokenId).send().wait();

    // Verify alice owns the NFT privately
    await assertOwnsPrivateNFT(nft, tokenId, alice.getAddress());

    // Transfer NFT from alice to bob privately
    await nft
      .withWallet(alice)
      .methods.transfer_private_to_private(alice.getAddress(), bob.getAddress(), tokenId, 0n)
      .send()
      .wait();

    // Verify alice no longer owns the NFT
    await assertPrivateNFTNullified(nft, tokenId, alice.getAddress());

    // Verify bob now owns the NFT privately
    await assertOwnsPrivateNFT(nft, tokenId, bob.getAddress());
  }, 300_000);

  it('fails to transfer private NFT when not owner', async () => {
    const tokenId = 1n;

    // First mint NFT privately to alice
    await nft.withWallet(alice).methods.mint_to_private(alice.getAddress(), tokenId).send().wait();

    // Carl attempts to transfer alice's NFT to bob
    await expect(
      nft
        .withWallet(carl)
        .methods.transfer_private_to_private(carl.getAddress(), bob.getAddress(), tokenId, 0n)
        .send()
        .wait(),
    ).rejects.toThrow(/nft not found/);

    // Verify alice still owns the NFT
    await assertOwnsPrivateNFT(nft, tokenId, alice.getAddress());
  }, 300_000);

  // --- Transfer tests: private to commitment ---

  // TODO: This is failing because the commitment is not stored or accessible
  it.skip('transfers NFT from private to commitment and completes transfer', async () => {
    const tokenId = 1n;

    // First mint NFT privately to alice
    await nft.withWallet(alice).methods.mint_to_private(alice.getAddress(), tokenId).send().wait();

    // Verify alice owns the NFT privately
    await assertOwnsPrivateNFT(nft, tokenId, alice.getAddress());

    // Bob initializes a transfer commitment for receiving the NFT
    await nft.withWallet(bob).methods.initialize_transfer_commitment(bob.getAddress(), bob.getAddress()).send().wait();

    // Get the commitment value through simulation
    const commitment = await nft
      .withWallet(bob)
      .methods.initialize_transfer_commitment(alice.getAddress(), bob.getAddress())
      .simulate();

    // Alice transfers NFT to the commitment
    await nft
      .withWallet(alice)
      .methods.transfer_private_to_commitment(alice.getAddress(), tokenId, commitment, 0n)
      .send()
      .wait();

    // Verify alice no longer owns the NFT
    await assertPrivateNFTNullified(nft, tokenId, alice.getAddress());

    // Verify bob now owns the NFT privately
    await assertOwnsPrivateNFT(nft, tokenId, bob.getAddress());
  }, 300_000);

  it('fails to transfer to invalid commitment', async () => {
    const tokenId = 1n;

    // First mint NFT privately to alice
    await nft.withWallet(alice).methods.mint_to_private(alice.getAddress(), tokenId).send().wait();

    // Create an invalid commitment (using wrong sender)
    const invalidCommitment = await nft
      .withWallet(bob)
      .methods.initialize_transfer_commitment(carl.getAddress(), bob.getAddress())
      .simulate();

    // Alice attempts to transfer to invalid commitment
    await expect(
      nft
        .withWallet(alice)
        .methods.transfer_private_to_commitment(alice.getAddress(), tokenId, invalidCommitment, 0n)
        .send()
        .wait(),
    ).rejects.toThrow(/^Transaction 0x[0-9a-f]+ was app_logic_reverted\. Reason: $/);

    // Verify alice still owns the NFT
    await assertOwnsPrivateNFT(nft, tokenId, alice.getAddress());
  }, 300_000);

  // --- Transfer tests: private to public ---

  it('transfers NFT from private to public', async () => {
    const tokenId = 1n;

    // First mint NFT privately to alice
    await nft.withWallet(alice).methods.mint_to_private(alice.getAddress(), tokenId).send().wait();

    // Verify alice owns the NFT privately
    await assertOwnsPrivateNFT(nft, tokenId, alice.getAddress());

    // Transfer NFT from alice to bob publicly
    await nft
      .withWallet(alice)
      .methods.transfer_private_to_public(alice.getAddress(), bob.getAddress(), tokenId, 0n)
      .send()
      .wait();

    // Verify alice no longer owns the NFT privately
    await assertPrivateNFTNullified(nft, tokenId, alice.getAddress());

    // Verify bob now owns the NFT publicly
    await assertOwnsPublicNFT(nft, tokenId, bob.getAddress());
  }, 300_000);

  it('fails to transfer private NFT to public when not owner', async () => {
    const tokenId = 1n;

    // First mint NFT privately to alice
    await nft.withWallet(alice).methods.mint_to_private(alice.getAddress(), tokenId).send().wait();

    // Carl attempts to transfer alice's NFT to bob
    await expect(
      nft
        .withWallet(carl)
        .methods.transfer_private_to_public(carl.getAddress(), bob.getAddress(), tokenId, 0n)
        .send()
        .wait(),
    ).rejects.toThrow(/nft not found/);

    // Verify alice still owns the NFT privately
    await assertOwnsPrivateNFT(nft, tokenId, alice.getAddress());
  }, 300_000);

  it('transfers NFT from private to public with authorization', async () => {
    const tokenId = 1n;

    // First mint NFT privately to alice
    await nft.withWallet(alice).methods.mint_to_private(alice.getAddress(), tokenId).send().wait();

    // Create transfer call interface with non-zero nonce
    const transferCallInterface = nft
      .withWallet(bob)
      .methods.transfer_private_to_public(alice.getAddress(), bob.getAddress(), tokenId, 1n);

    // Add authorization witness from alice to bob
    const intent: IntentAction = {
      caller: bob.getAddress(),
      action: transferCallInterface,
    };
    const witness = await alice.createAuthWit(intent);

    // Bob executes the transfer with alice's authorization
    await transferCallInterface.send({ authWitnesses: [witness] }).wait();

    // Verify alice no longer owns the NFT privately
    await assertPrivateNFTNullified(nft, tokenId, alice.getAddress());

    // Verify bob now owns the NFT publicly
    await assertOwnsPublicNFT(nft, tokenId, bob.getAddress());
  }, 300_000);

  // --- Transfer tests: private to public with commitment ---

  it('transfers NFT from private to public with commitment', async () => {
    const tokenId = 1n;

    // First mint NFT privately to alice
    await nft.withWallet(alice).methods.mint_to_private(alice.getAddress(), tokenId).send().wait();

    // Verify alice owns the NFT privately
    await assertOwnsPrivateNFT(nft, tokenId, alice.getAddress());

    // Transfer NFT from alice to bob with commitment
    await nft
      .withWallet(alice)
      .methods.transfer_private_to_public_with_commitment(alice.getAddress(), bob.getAddress(), tokenId, 0n)
      .send()
      .wait();

    // Verify alice no longer owns the NFT privately
    await assertPrivateNFTNullified(nft, tokenId, alice.getAddress());

    // Verify bob now owns the NFT publicly
    await assertOwnsPublicNFT(nft, tokenId, bob.getAddress());
  }, 300_000);

  it('fails to transfer private NFT to public with commitment when not owner', async () => {
    const tokenId = 1n;

    // First mint NFT privately to alice
    await nft.withWallet(alice).methods.mint_to_private(alice.getAddress(), tokenId).send().wait();

    // Carl attempts to transfer alice's NFT to bob
    await expect(
      nft
        .withWallet(carl)
        .methods.transfer_private_to_public_with_commitment(carl.getAddress(), bob.getAddress(), tokenId, 0n)
        .send()
        .wait(),
    ).rejects.toThrow(/nft not found/);

    // Verify alice still owns the NFT privately
    await assertOwnsPrivateNFT(nft, tokenId, alice.getAddress());
  }, 300_000);

  it('transfers NFT from private to public with commitment and authorization', async () => {
    const tokenId = 1n;

    // First mint NFT privately to alice
    await nft.withWallet(alice).methods.mint_to_private(alice.getAddress(), tokenId).send().wait();

    // Create transfer call interface with non-zero nonce
    const transferCallInterface = nft
      .withWallet(bob)
      .methods.transfer_private_to_public_with_commitment(alice.getAddress(), bob.getAddress(), tokenId, 1n);

    // Add authorization witness from alice to bob
    const intent: IntentAction = {
      caller: bob.getAddress(),
      action: transferCallInterface,
    };
    const witness = await alice.createAuthWit(intent);

    // Bob executes the transfer with alice's authorization
    await transferCallInterface.send({ authWitnesses: [witness] }).wait();

    // Verify alice no longer owns the NFT privately
    await assertPrivateNFTNullified(nft, tokenId, alice.getAddress());

    // Verify bob now owns the NFT publicly
    await assertOwnsPublicNFT(nft, tokenId, bob.getAddress());
  }, 300_000);

  // --- Transfer tests: public to private ---

  it('transfers NFT from public to private', async () => {
    const tokenId = 1n;

    // First mint NFT publicly to alice
    await nft.withWallet(alice).methods.mint_to_public(alice.getAddress(), tokenId).send().wait();

    // Verify alice owns the NFT publicly
    await assertOwnsPublicNFT(nft, tokenId, alice.getAddress());

    // Transfer NFT from alice's public balance to private balance
    await nft
      .withWallet(alice)
      .methods.transfer_public_to_private(alice.getAddress(), bob.getAddress(), tokenId, 0n)
      .send()
      .wait();

    // Verify alice no longer owns the NFT publicly
    const publicOwner = await nft.methods.public_owner_of(tokenId).simulate();
    expect(publicOwner.equals(AztecAddress.ZERO)).toBe(true);

    // Verify bob now owns the NFT privately
    await assertOwnsPrivateNFT(nft, tokenId, bob.getAddress());
  }, 300_000);

  it('fails to transfer public NFT to private when not owner', async () => {
    const tokenId = 1n;

    // First mint NFT publicly to alice
    await nft.withWallet(alice).methods.mint_to_public(alice.getAddress(), tokenId).send().wait();

    // Carl attempts to transfer alice's NFT to bob
    await expect(
      nft
        .withWallet(carl)
        .methods.transfer_public_to_private(carl.getAddress(), bob.getAddress(), tokenId, 0n)
        .send()
        .wait(),
    ).rejects.toThrow(/^Transaction 0x[0-9a-f]+ was app_logic_reverted\. Reason: $/);

    // Verify alice still owns the NFT publicly
    await assertOwnsPublicNFT(nft, tokenId, alice.getAddress());
  }, 300_000);

  it('transfers NFT from public to private with authorization', async () => {
    const tokenId = 1n;

    // First mint NFT publicly to alice
    await nft.withWallet(alice).methods.mint_to_public(alice.getAddress(), tokenId).send().wait();

    // Create transfer call interface with non-zero nonce
    const transferCallInterface = nft
      .withWallet(bob)
      .methods.transfer_public_to_private(alice.getAddress(), bob.getAddress(), tokenId, 1n);

    // Add authorization witness from alice to bob
    const intent: IntentAction = {
      caller: bob.getAddress(),
      action: transferCallInterface,
    };
    const witness = await alice.createAuthWit(intent);

    // Bob executes the transfer with alice's authorization
    await transferCallInterface.send({ authWitnesses: [witness] }).wait();

    // Verify alice no longer owns the NFT publicly
    const publicOwner = await nft.methods.public_owner_of(tokenId).simulate();
    expect(publicOwner.equals(AztecAddress.ZERO)).toBe(true);

    // Verify bob now owns the NFT privately
    await assertOwnsPrivateNFT(nft, tokenId, bob.getAddress());
  }, 300_000);

  // --- Transfer tests: public to public ---

  it('transfers NFT from public to public', async () => {
    const tokenId = 1n;

    // First mint NFT publicly to alice
    await nft.withWallet(alice).methods.mint_to_public(alice.getAddress(), tokenId).send().wait();

    // Verify alice owns the NFT publicly
    await assertOwnsPublicNFT(nft, tokenId, alice.getAddress());

    // Transfer NFT from alice to bob publicly
    await nft
      .withWallet(alice)
      .methods.transfer_public_to_public(alice.getAddress(), bob.getAddress(), tokenId, 0n)
      .send()
      .wait();

    // Verify alice no longer owns the NFT publicly
    const aliceOwner = await nft.methods.public_owner_of(tokenId).simulate();
    expect(aliceOwner.equals(alice.getAddress())).toBe(false);

    // Verify bob now owns the NFT publicly
    await assertOwnsPublicNFT(nft, tokenId, bob.getAddress());
  }, 300_000);

  it('fails to transfer public NFT when not owner', async () => {
    const tokenId = 1n;

    // First mint NFT publicly to alice
    await nft.withWallet(alice).methods.mint_to_public(alice.getAddress(), tokenId).send().wait();

    // Carl attempts to transfer alice's NFT to bob
    await expect(
      nft
        .withWallet(carl)
        .methods.transfer_public_to_public(carl.getAddress(), bob.getAddress(), tokenId, 0n)
        .send()
        .wait(),
    ).rejects.toThrow(/^Transaction 0x[0-9a-f]+ was app_logic_reverted\. Reason: $/);

    // Verify alice still owns the NFT publicly
    await assertOwnsPublicNFT(nft, tokenId, alice.getAddress());
  }, 300_000);

  // TODO: Pass this test
  it.skip('transfers NFT from public to public with authorization', async () => {
    const tokenId = 1n;

    // First mint NFT publicly to alice
    await nft.withWallet(alice).methods.mint_to_public(alice.getAddress(), tokenId).send().wait();

    // Verify initial ownership
    const initialOwner = await nft.methods.public_owner_of(tokenId).simulate();
    expect(initialOwner.equals(alice.getAddress())).toBe(true);

    // Create transfer call interface with non-zero nonce
    const action = nft
      .withWallet(bob)
      .methods.transfer_public_to_public(alice.getAddress(), bob.getAddress(), tokenId, 1n);

    // Add authorization witness from alice to bob
    const intent: IntentAction = {
      caller: bob.getAddress(),
      action,
    };
    // TODO: failing here
    const witness = await alice.createAuthWit(intent);

    const validity = await alice.lookupValidity(alice.getAddress(), intent, witness);
    expect(validity.isValidInPrivate).toBeTruthy();
    expect(validity.isValidInPublic).toBeFalsy();

    // Bob executes the transfer with alice's authorization
    await action.send({ authWitnesses: [witness] }).wait();

    // Verify final ownership
    const finalOwner = await nft.methods.public_owner_of(tokenId).simulate();
    expect(finalOwner.equals(bob.getAddress())).toBe(true);
  }, 300_000);

  // --- View function tests ---

  it('returns correct name and symbol', async () => {
    const name = await nft.methods.public_get_name().simulate();
    const symbol = await nft.methods.public_get_symbol().simulate();
    const nameStr = bigIntToAsciiString(name.value);
    const symbolStr = bigIntToAsciiString(symbol.value);

    console.log('NFT Name:', nameStr);
    console.log('NFT Symbol:', symbolStr);

    expect(nameStr).toBe('TestNFT');
    expect(symbolStr).toBe('TNFT');
  }, 300_000);

  it('returns correct public owner', async () => {
    const tokenId = 1n;

    // Initially no owner (zero address)
    const initialOwner = await nft.methods.public_owner_of(tokenId).simulate();
    expect(initialOwner.equals(AztecAddress.ZERO)).toBe(true);

    // Mint NFT to alice
    await nft.withWallet(alice).methods.mint_to_public(alice.getAddress(), tokenId).send().wait();

    // Check owner is alice
    const owner = await nft.methods.public_owner_of(tokenId).simulate();
    expect(owner.equals(alice.getAddress())).toBe(true);
  }, 300_000);

  it('returns private NFTs owned by address', async () => {
    const tokenId1 = 1n;
    const tokenId2 = 2n;

    // Initially no NFTs
    const [initialNfts, initialLimitReached] = await nft.methods.get_private_nfts(alice.getAddress(), 0).simulate();
    expect(initialNfts.every((id: bigint) => id === 0n)).toBe(true);
    expect(initialLimitReached).toBe(false);

    // Mint two NFTs to alice
    await nft.withWallet(alice).methods.mint_to_private(alice.getAddress(), tokenId1).send().wait();
    await nft.withWallet(alice).methods.mint_to_private(alice.getAddress(), tokenId2).send().wait();

    // Check owned NFTs
    const [ownedNfts, limitReached] = await nft.methods.get_private_nfts(alice.getAddress(), 0).simulate();
    expect(ownedNfts).toContain(tokenId1);
    expect(ownedNfts).toContain(tokenId2);
    expect(limitReached).toBe(false);
  }, 300_000);

  // --- Access control tests ---

  it('enforces minter role for minting', async () => {
    const tokenId = 1n;

    // Deploy new contract with bob as minter
    const nftWithBobMinter = (await deployNFTWithMinter(bob)) as NFTContract;

    // Alice attempts to mint when she's not the minter
    await expect(
      nftWithBobMinter.withWallet(alice).methods.mint_to_public(alice.getAddress(), tokenId).send().wait(),
    ).rejects.toThrow(/^Transaction 0x[0-9a-f]+ was app_logic_reverted\. Reason: $/);

    await expect(
      nftWithBobMinter.withWallet(alice).methods.mint_to_private(alice.getAddress(), tokenId).send().wait(),
    ).rejects.toThrow(/caller is not minter/);

    // Bob can mint since he's the minter
    await nftWithBobMinter.withWallet(bob).methods.mint_to_public(alice.getAddress(), tokenId).send().wait();
    await assertOwnsPublicNFT(nftWithBobMinter, tokenId, alice.getAddress());
  }, 300_000);

  it('enforces ownership for public transfers', async () => {
    const tokenId = 1n;

    // Mint NFT to alice
    await nft.withWallet(alice).methods.mint_to_public(alice.getAddress(), tokenId).send().wait();

    // Bob attempts to transfer without ownership or authorization
    await expect(
      nft
        .withWallet(bob)
        .methods.transfer_public_to_public(bob.getAddress(), carl.getAddress(), tokenId, 0n)
        .send()
        .wait(),
    ).rejects.toThrow(/^Transaction 0x[0-9a-f]+ was app_logic_reverted\. Reason: $/);

    // Alice can transfer since she's the owner
    await nft
      .withWallet(alice)
      .methods.transfer_public_to_public(alice.getAddress(), bob.getAddress(), tokenId, 0n)
      .send()
      .wait();
    await assertOwnsPublicNFT(nft, tokenId, bob.getAddress());
  }, 300_000);

  it('enforces ownership for private transfers', async () => {
    const tokenId = 1n;

    // Mint NFT privately to alice
    await nft.withWallet(alice).methods.mint_to_private(alice.getAddress(), tokenId).send().wait();

    // Bob attempts to transfer without ownership or authorization
    await expect(
      nft
        .withWallet(bob)
        .methods.transfer_private_to_private(bob.getAddress(), carl.getAddress(), tokenId, 0n)
        .send()
        .wait(),
    ).rejects.toThrow(/nft not found/);

    // Alice can transfer since she's the owner
    await nft
      .withWallet(alice)
      .methods.transfer_private_to_private(alice.getAddress(), bob.getAddress(), tokenId, 0n)
      .send()
      .wait();
    await assertOwnsPrivateNFT(nft, tokenId, bob.getAddress());
  }, 300_000);

  it('enforces authorization for transfers', async () => {
    const tokenId = 1n;
    const invalidNonce = 999n;

    // Mint NFT to alice
    await nft.withWallet(alice).methods.mint_to_public(alice.getAddress(), tokenId).send().wait();

    // Bob attempts transfer with invalid authorization
    const transferCallInterface = nft
      .withWallet(bob)
      .methods.transfer_public_to_public(alice.getAddress(), bob.getAddress(), tokenId, invalidNonce);

    const intent: IntentAction = {
      caller: bob.getAddress(),
      action: transferCallInterface,
    };

    // Create auth witness with wrong nonce
    const witness = await carl.createAuthWit(intent); // Wrong signer (carl instead of alice)

    // Transfer should fail with invalid authorization
    await expect(transferCallInterface.send({ authWitnesses: [witness] }).wait()).rejects.toThrow();

    // Alice still owns the NFT
    await assertOwnsPublicNFT(nft, tokenId, alice.getAddress());
  }, 300_000);
});

function bigIntToAsciiString(bigInt: any): string {
  // Convert the BigInt to hex string, remove '0x' prefix if present
  let hexString = bigInt.toString(16);

  // Split into pairs of characters (bytes)
  const pairs = [];
  for (let i = 0; i < hexString.length; i += 2) {
    // If we have an odd number of characters, pad with 0
    const pair = hexString.slice(i, i + 2).padStart(2, '0');
    pairs.push(pair);
  }

  // Convert each byte to its ASCII character
  let asciiString = '';
  for (const pair of pairs) {
    const charCode = parseInt(pair, 16);
    // Only add printable ASCII characters
    if (charCode >= 32 && charCode <= 126) {
      asciiString += String.fromCharCode(charCode);
    }
  }
  return asciiString;
}
