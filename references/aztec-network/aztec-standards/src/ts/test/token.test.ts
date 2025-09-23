import { TokenContractArtifact, TokenContract } from '../../artifacts/Token.js';
import {
  AccountWallet,
  CompleteAddress,
  ContractDeployer,
  Fr,
  PXE,
  TxStatus,
  getContractInstanceFromDeployParams,
  Contract,
  AccountWalletWithSecretKey,
  IntentAction,
} from '@aztec/aztec.js';
import { getInitialTestAccountsWallets } from '@aztec/accounts/testing';
import {
  AMOUNT,
  createPXE,
  expectTokenBalances,
  expectUintNote,
  setupSandbox,
  wad,
  deployTokenWithMinter,
} from './utils.js';

export async function deployTokenWithInitialSupply(deployer: AccountWallet) {
  const contract = await Contract.deploy(
    deployer,
    TokenContractArtifact,
    ['PrivateToken', 'PT', 18, 0, deployer.getAddress(), deployer.getAddress()],
    'constructor_with_initial_supply',
  )
    .send()
    .deployed();
  return contract;
}

describe('Token - Single PXE', () => {
  let pxe: PXE;
  let wallets: AccountWalletWithSecretKey[] = [];
  let accounts: CompleteAddress[] = [];

  let alice: AccountWallet;
  let bob: AccountWallet;
  let carl: AccountWallet;

  let token: TokenContract;

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
    token = (await deployTokenWithMinter(alice)) as TokenContract;
  });

  it('deploys the contract with minter', async () => {
    const salt = Fr.random();
    const [deployerWallet] = wallets; // using first account as deployer

    const deploymentData = await getContractInstanceFromDeployParams(TokenContractArtifact, {
      constructorArtifact: 'constructor_with_minter',
      constructorArgs: ['PrivateToken', 'PT', 18, deployerWallet.getAddress(), deployerWallet.getAddress()],
      salt,
      deployer: deployerWallet.getAddress(),
    });
    const deployer = new ContractDeployer(TokenContractArtifact, deployerWallet, undefined, 'constructor_with_minter');
    const tx = deployer
      .deploy('PrivateToken', 'PT', 18, deployerWallet.getAddress(), deployerWallet.getAddress())
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

  it('deploys the contract with initial supply', async () => {
    const salt = Fr.random();
    const [deployerWallet] = wallets; // using first account as deployer

    const deploymentData = await getContractInstanceFromDeployParams(TokenContractArtifact, {
      constructorArtifact: 'constructor_with_initial_supply',
      constructorArgs: ['PrivateToken', 'PT', 18, 1, deployerWallet.getAddress(), deployerWallet.getAddress()],
      salt,
      deployer: deployerWallet.getAddress(),
    });
    const deployer = new ContractDeployer(
      TokenContractArtifact,
      deployerWallet,
      undefined,
      'constructor_with_initial_supply',
    );
    const tx = deployer
      .deploy('PrivateToken', 'PT', 18, 1, deployerWallet.getAddress(), deployerWallet.getAddress())
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

  it('mints', async () => {
    await token.withWallet(alice);
    const tx = await token.methods.mint_to_public(bob.getAddress(), AMOUNT).send().wait();
    const balance = await token.methods.balance_of_public(bob.getAddress()).simulate();
    expect(balance).toBe(AMOUNT);
  }, 300_000);

  it('transfers tokens between public accounts', async () => {
    // First mint 2 tokens to alice
    await token
      .withWallet(alice)
      .methods.mint_to_public(alice.getAddress(), AMOUNT * 2n)
      .send()
      .wait();

    // Transfer 1 token from alice to bob
    await token
      .withWallet(alice)
      .methods.transfer_public_to_public(alice.getAddress(), bob.getAddress(), AMOUNT, 0)
      .send()
      .wait();

    // Check balances are correct
    const aliceBalance = await token.methods.balance_of_public(alice.getAddress()).simulate();
    const bobBalance = await token.methods.balance_of_public(bob.getAddress()).simulate();

    expect(aliceBalance).toBe(AMOUNT);
    expect(bobBalance).toBe(AMOUNT);
  }, 300_000);

  // TODO(#29): burn was nuked because of this PR, re-enable it
  // it('burns public tokens', async () => {
  //   // First mint 2 tokens to alice
  //   await token
  //     .withWallet(alice)
  //     .methods.mint_to_public(alice.getAddress(), AMOUNT * 2n)
  //     .send()
  //     .wait();

  //   // Burn 1 token from alice
  //   await token.withWallet(alice).methods.burn_public(alice.getAddress(), AMOUNT, 0).send().wait();

  //   // Check balance and total supply are reduced
  //   const aliceBalance = await token.methods.balance_of_public(alice.getAddress()).simulate();
  //   const totalSupply = await token.methods.total_supply().simulate();

  //   expect(aliceBalance).toBe(AMOUNT);
  //   expect(totalSupply).toBe(AMOUNT);
  // }, 300_000);

  it('transfers tokens from private to public balance', async () => {
    // First mint to private 2 tokens to alice
    await token
      .withWallet(alice)
      .methods.mint_to_private(alice.getAddress(), alice.getAddress(), AMOUNT * 2n)
      .send()
      .wait();

    // Transfer 1 token from alice's private balance to public balance
    await token
      .withWallet(alice)
      .methods.transfer_private_to_public(alice.getAddress(), alice.getAddress(), AMOUNT, 0)
      .send()
      .wait();

    // Check public balance is correct
    const alicePublicBalance = await token.methods.balance_of_public(alice.getAddress()).simulate();
    expect(alicePublicBalance).toBe(AMOUNT);

    // Check total supply hasn't changed
    const totalSupply = await token.methods.total_supply().simulate();
    expect(totalSupply).toBe(AMOUNT * 2n);
  }, 300_000);

  it.skip('fails when transferring more tokens than available in private balance', async () => {
    // Mint 1 token privately to alice
    await token.withWallet(alice).methods.mint_to_private(alice.getAddress(), alice.getAddress(), AMOUNT).send().wait();

    // Try to transfer more tokens than available from private to public balance
    // TODO(#29): fix "Invalid arguments size: expected 3, got 2" error handling
    // await expect(
    //   token
    //     .withWallet(alice)
    //     .methods.transfer_private_to_public(alice.getAddress(), alice.getAddress(), AMOUNT + 1n, 0)
    //     .send()
    //     .wait(),
    // ).rejects.toThrow(/Balance too low/);
  }, 300_000);

  it('can transfer tokens between private balances', async () => {
    // Mint 2 tokens privately to alice
    await token
      .withWallet(alice)
      .methods.mint_to_private(alice.getAddress(), alice.getAddress(), AMOUNT * 2n)
      .send()
      .wait();

    // Transfer 1 token from alice to bob's private balance
    await token
      .withWallet(alice)
      .methods.transfer_private_to_private(alice.getAddress(), bob.getAddress(), AMOUNT, 0)
      .send()
      .wait();

    // Try to transfer more than available balance
    // TODO(#29): fix "Invalid arguments size: expected 3, got 2" error handling
    // await expect(
    //   token
    //     .withWallet(alice)
    //     .methods.transfer_private_to_private(alice.getAddress(), bob.getAddress(), AMOUNT + 1n, 0)
    //     .send()
    //     .wait(),
    // ).rejects.toThrow(/Balance too low/);

    // Check total supply hasn't changed
    const totalSupply = await token.methods.total_supply().simulate();
    expect(totalSupply).toBe(AMOUNT * 2n);
  }, 300_000);

  it('can mint tokens to private balance', async () => {
    // Mint 2 tokens privately to alice
    await token
      .withWallet(alice)
      .methods.mint_to_private(alice.getAddress(), alice.getAddress(), AMOUNT * 2n)
      .send()
      .wait();

    // Check total supply increased
    const totalSupply = await token.methods.total_supply().simulate();
    expect(totalSupply).toBe(AMOUNT * 2n);

    // Public balance should be 0 since we minted privately
    const alicePublicBalance = await token.methods.balance_of_public(alice.getAddress()).simulate();
    expect(alicePublicBalance).toBe(0n);
  }, 300_000);

  it('can burn tokens from private balance', async () => {
    // Mint 2 tokens privately to alice
    await token
      .withWallet(alice)
      .methods.mint_to_private(alice.getAddress(), alice.getAddress(), AMOUNT * 2n)
      .send()
      .wait();

    // Burn 1 token from alice's private balance
    await token.withWallet(alice).methods.burn_private(alice.getAddress(), AMOUNT, 0).send().wait();

    // Try to burn more than available balance
    await expect(
      token
        .withWallet(alice)
        .methods.burn_private(alice.getAddress(), AMOUNT * 2n, 0)
        .send()
        .wait(),
    ).rejects.toThrow(/Balance too low/);

    // Check total supply decreased
    const totalSupply = await token.methods.total_supply().simulate();
    expect(totalSupply).toBe(AMOUNT);

    // Public balance should still be 0
    const alicePublicBalance = await token.methods.balance_of_public(alice.getAddress()).simulate();
    expect(alicePublicBalance).toBe(0n);
  }, 300_000);

  it('can transfer tokens from public to private balance', async () => {
    // Mint 2 tokens publicly to alice
    await token
      .withWallet(alice)
      .methods.mint_to_public(alice.getAddress(), AMOUNT * 2n)
      .send()
      .wait();

    // Transfer 1 token from alice's public balance to private balance
    await token
      .withWallet(alice)
      .methods.transfer_public_to_private(alice.getAddress(), alice.getAddress(), AMOUNT, 0)
      .send()
      .wait();

    // Try to transfer more than available public balance
    // TODO(#29): fix "Invalid arguments size: expected 3, got 2" error handling
    // await expect(
    //   token
    //     .withWallet(alice)
    //     .methods.transfer_public_to_private(alice.getAddress(), alice.getAddress(), AMOUNT * 2n, 0)
    //     .send()
    //     .wait(),
    // ).rejects.toThrow(/attempt to subtract with underflow/);

    // Check total supply stayed the same
    const totalSupply = await token.methods.total_supply().simulate();
    expect(totalSupply).toBe(AMOUNT * 2n);

    // Public balance should be reduced by transferred amount
    const alicePublicBalance = await token.methods.balance_of_public(alice.getAddress()).simulate();
    expect(alicePublicBalance).toBe(AMOUNT);
  }, 300_000);

  it.skip('mint in public, prepare partial note and finalize it', async () => {
    await token.withWallet(alice);

    await token.methods.mint_to_public(alice.getAddress(), AMOUNT).send().wait();

    // alice has tokens in public
    expect(await token.methods.balance_of_public(alice.getAddress()).simulate()).toBe(AMOUNT);
    expect(await token.methods.balance_of_private(alice.getAddress()).simulate()).toBe(0n);
    // bob has 0 tokens
    expect(await token.methods.balance_of_private(bob.getAddress()).simulate()).toBe(0n);
    expect(await token.methods.balance_of_private(bob.getAddress()).simulate()).toBe(0n);

    expect(await token.methods.total_supply().simulate()).toBe(AMOUNT);

    // alice prepares partial note for bob
    await token.methods.initialize_transfer_commitment(bob.getAddress(), alice.getAddress()).send().wait();

    // alice still has tokens in public
    expect(await token.methods.balance_of_public(alice.getAddress()).simulate()).toBe(AMOUNT);

    // finalize partial note passing the commitment slot
    // await token.methods.transfer_public_to_commitment(AMOUNT, latestEvent.hiding_point_slot).send().wait();

    // alice now has no tokens
    // expect(await token.methods.balance_of_public(alice.getAddress()).simulate()).toBe(0n);
    // // bob has tokens in private
    // expect(await token.methods.balance_of_public(bob.getAddress()).simulate()).toBe(0n);
    // expect(await token.methods.balance_of_private(bob.getAddress()).simulate()).toBe(AMOUNT);
    // // total supply is still the same
    // expect(await token.methods.total_supply().simulate()).toBe(AMOUNT);
  }, 300_000);

  // TODO: Can't figure out why this is failing
  // Assertion failed: unauthorized 'true, authorized'
  it.skip('public transfer with authwitness', async () => {
    // Mint tokens to Alice in public
    await token.withWallet(alice).methods.mint_to_public(alice.getAddress(), AMOUNT).send().wait();

    // build transfer public to public call
    const nonce = Fr.random();
    const action = token
      .withWallet(carl)
      .methods.transfer_public_to_public(alice.getAddress(), bob.getAddress(), AMOUNT, nonce);

    // define intent
    const intent: IntentAction = {
      caller: carl.getAddress(),
      action,
    };
    // alice creates authwitness
    const authWitness = await alice.createAuthWit(intent);
    // alice authorizes the public authwit
    await (await alice.setPublicAuthWit(intent, true)).send().wait();

    // check validity of alice's authwit
    const validity = await carl.lookupValidity(alice.getAddress(), intent, authWitness);
    expect(validity.isValidInPrivate).toBeTruthy();
    expect(validity.isValidInPublic).toBeTruthy();

    // Carl submits the action, using alice's authwit
    await action.send({ authWitnesses: [authWitness] }).wait();

    // Check balances, alice to should 0
    expect(await token.methods.balance_of_public(alice.getAddress()).simulate()).toBe(0n);
    // Bob should have the a non-zero amount
    expect(await token.methods.balance_of_public(bob.getAddress()).simulate()).toBe(AMOUNT);
  }, 300_000);

  it('private transfer with authwitness', async () => {
    // setup balances
    await token.withWallet(alice).methods.mint_to_public(alice.getAddress(), AMOUNT).send().wait();
    await token
      .withWallet(alice)
      .methods.transfer_public_to_private(alice.getAddress(), alice.getAddress(), AMOUNT, 0)
      .send()
      .wait();

    expect(await token.methods.balance_of_private(alice.getAddress()).simulate()).toBe(AMOUNT);

    // prepare action
    const nonce = Fr.random();
    const action = token
      .withWallet(carl)
      .methods.transfer_private_to_private(alice.getAddress(), bob.getAddress(), AMOUNT, nonce);

    const intent: IntentAction = {
      caller: carl.getAddress(),
      action,
    };
    const witness = await alice.createAuthWit(intent);

    const validity = await alice.lookupValidity(alice.getAddress(), intent, witness);
    expect(validity.isValidInPrivate).toBeTruthy();
    expect(validity.isValidInPublic).toBeFalsy();

    await action.send({ authWitnesses: [witness] }).wait();

    expect(await token.methods.balance_of_private(alice.getAddress()).simulate()).toBe(0n);
    expect(await token.methods.balance_of_private(bob.getAddress()).simulate()).toBe(AMOUNT);
  }, 300_000);
});

describe('Token - Multi PXE', () => {
  let alicePXE: PXE;
  let bobPXE: PXE;

  let aliceWallet: AccountWalletWithSecretKey;
  let bobWallet: AccountWalletWithSecretKey;

  let alice: AccountWallet;
  let bob: AccountWallet;

  let token: TokenContract;

  beforeAll(async () => {
    alicePXE = await createPXE(0);
    bobPXE = await createPXE(1);

    const initialsAlice = await getInitialTestAccountsWallets(alicePXE);
    const initialsBob = await getInitialTestAccountsWallets(bobPXE);
    // TODO: assert that the used PXEs are actually separate instances?

    aliceWallet = initialsAlice[0];
    bobWallet = initialsBob[1];
    alice = initialsAlice[0];
    bob = initialsBob[1];
  });

  beforeEach(async () => {
    token = (await deployTokenWithMinter(alice)) as TokenContract;
    await bobPXE.registerContract(token);

    // alice knows bob
    // TODO: review this, alice shouldn't need to register bob's **secrets**!
    await alicePXE.registerAccount(bobWallet.getSecretKey(), bob.getCompleteAddress().partialAddress);
    await alicePXE.registerSender(bob.getAddress());

    // bob knows alice
    await bobPXE.registerAccount(aliceWallet.getSecretKey(), alice.getCompleteAddress().partialAddress);
    await bobPXE.registerSender(alice.getAddress());
  });

  it('transfers', async () => {
    let events, notes;

    // mint initial amount to alice
    await token.withWallet(alice).methods.mint_to_public(alice.getAddress(), wad(10)).send().wait();

    // self-transfer 5 public tokens to private
    const aliceShieldTx = await token
      .withWallet(alice)
      .methods.transfer_public_to_private(alice.getAddress(), alice.getAddress(), wad(5), 0)
      .send()
      .wait();
    await token.withWallet(alice).methods.sync_private_state().simulate({});

    // assert balances
    await expectTokenBalances(token, alice.getAddress(), wad(5), wad(5));

    // retrieve notes from last tx
    notes = await alicePXE.getNotes({ txHash: aliceShieldTx.txHash });
    expect(notes.length).toBe(1);
    expectUintNote(notes[0], wad(5), alice.getAddress());

    // transfer some private tokens to bob
    const fundBobTx = await token
      .withWallet(alice)
      .methods.transfer_public_to_private(alice.getAddress(), bob.getAddress(), wad(5), 0)
      .send()
      .wait();

    await token.withWallet(alice).methods.sync_private_state().simulate({});
    await token.withWallet(bob).methods.sync_private_state().simulate({});

    notes = await alicePXE.getNotes({ txHash: fundBobTx.txHash });
    expect(notes.length).toBe(1);
    expectUintNote(notes[0], wad(5), bob.getAddress());

    // TODO: Bob is not receiving notes
    // notes = await bob.getNotes({ txHash: fundBobTx.txHash });
    // expect(notes.length).toBe(1);
    // expectUintNote(notes[0], wad(5), bob.getAddress());

    // fund bob again
    const fundBobTx2 = await token
      .withWallet(alice)
      .methods.transfer_private_to_private(alice.getAddress(), bob.getAddress(), wad(5), 0)
      .send()
      .wait();

    await token.withWallet(alice).methods.sync_private_state().simulate({});
    await token.withWallet(bob).methods.sync_private_state().simulate({});

    // assert balances
    await expectTokenBalances(token, alice.getAddress(), wad(0), wad(0));
    await expectTokenBalances(token, bob.getAddress(), wad(0), wad(10));

    // Alice shouldn't have any notes because it not a sender/registered account in her PXE
    // (but she has because I gave her access to Bob's notes)
    notes = await alicePXE.getNotes({ txHash: fundBobTx2.txHash });
    expect(notes.length).toBe(1);
    expectUintNote(notes[0], wad(5), bob.getAddress());

    // TODO: Bob is not receiving notes
    // Bob should have a note
    // notes = await bob.getNotes({txHash: fundBobTx2.txHash});
    // expect(notes.length).toBe(1);
    // expectUintNote(notes[0], wad(5), bob.getAddress());

    // assert alice's balances again
    await expectTokenBalances(token, alice.getAddress(), wad(0), wad(0));
    // assert bob's balances
    await expectTokenBalances(token, bob.getAddress(), wad(0), wad(10));
  }, 300_000);
});
