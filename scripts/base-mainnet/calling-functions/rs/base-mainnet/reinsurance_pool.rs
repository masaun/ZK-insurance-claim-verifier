// @dev - Alloy
use alloy::{
    network::AnyNetwork, // @dev - icl. AnyNetwork for Base Mainnet
    providers::{Provider, ProviderBuilder},
    signers::local::PrivateKeySigner,
    sol,
    primitives::{address, Bytes, FixedBytes, Address, U256},
    hex::FromHex,
    rpc::types::TransactionRequest,
    network::TransactionBuilder,
};
use alloy_node_bindings::Anvil;

// Generate the contract bindings for the ReInsurancePool interface.
sol! { 
    // The `rpc` attribute enables contract interaction via the provider. 
    #[sol(rpc)] 
    ReInsurancePool,
    "artifacts/0901/ReInsurancePool.json"
} 

use dotenv::dotenv;
use std::env;


/**
 * @dev - Call the ReInsurancePool#checkpoint() on Base Mainnet
 * @dev - Run this script with the "sh ./base-mainnet/runningScript_ReInsurancePool.sh" command at the root directory (= /rs)
 * @dev - Example: `any_network` 🔴
 *    (Run: `cargo run --example any_network` 🟣)
 *    https://alloy.rs/examples/advanced/any_network#example-any_network
 */
#[tokio::main]
async fn main() {
    batch_call().await;
}

/**
 * @dev - Batch call the ReInsurancePool#checkpoint() function on Base Mainnet
 * @dev - [TODO 1]: for-loop of the 5 private keys + Call the checkpoint() function inside it.
 * @dev - [TODO 2]: for-loop of the 12 SC address of ReInsurancePool
 */
pub async fn batch_call() {
    let result = checkpoint().await;

    // [TODO 1]: for-loop of the 5 private keys + Call the checkpoint() function inside it.
    // for i in 1..=5 {
    //     let private_key = env::var(format!("PRIVATE_KEY_{}", i)).expect("Missing private key");
    //     let result = checkpoint(private_key).await;
    // }

    // [TODO 2]: for-loop of the 12 SC address of ReInsurancePool
}

/**
 * @dev - Call the ReInsurancePool#checkpoint() function on Base Mainnet
 */
pub async fn checkpoint() -> eyre::Result<()> {
    // 1. Fetch values from env
    dotenv().ok();  // Loads .env file
    //let rpc_url = "https://mainnet.base.org".parse()?;
    let rpc_url = env::var("BASE_MAINNET_RPC").expect("").parse()?;
    let private_key = env::var("PRIVATE_KEY")?;
    let contract_address: Address = env::var("REINSURANCE_POOL_ON_BASE_MAINNET").expect("").parse()?;
    println!("✅ rpc_url: {:?}", rpc_url);
    println!("✅ private_key: {:?}", private_key);
    println!("✅ contract_address: {:?}", contract_address);

    // 2. Start Anvil (local test network)
    //let anvil = Anvil::new().spawn();
    //println!("✅ Anvil running at: {}", anvil.endpoint());

    // Create a signer using one of Anvil's default private keys
    let signer: PrivateKeySigner = private_key.parse()?;
    
    // Create provider with wallet  
    let provider = ProviderBuilder::new()
        .with_gas_estimation()
        .network::<AnyNetwork>() // @dev - Use AnyNetwork for Base Mainnet
        .wallet(signer)
        .connect_http(rpc_url);

    // 3. Deploy ZkJwtProofVerifier first using helper function
    //let zk_jwt_proof_verifier_address = deploy_zk_jwt_proof_verifier(&provider).await?;
    //let zk_jwt_proof_verifier = ZkJwtProofVerifier::new(zk_jwt_proof_verifier_address, &provider);

    // 4. Deploy ReInsurancePool with HonkVerifier address as constructor parameter
    let reinsurance_pool_json = std::fs::read_to_string("artifacts/0903/ReInsurancePool.sol/ReInsurancePool.json")?;
    //let reinsurance_pool_json = std::fs::read_to_string("artifacts/0901/ReInsurancePool.json")?;
    let reinsurance_pool_artifact: serde_json::Value = serde_json::from_str(&reinsurance_pool_json)?;
    let bytecode_hex = reinsurance_pool_artifact["bytecode"]["object"]
        .as_str()
        .ok_or_else(|| eyre::eyre!("Failed to get ReInsurancePool bytecode"))?;

    // Append constructor parameter (HonkVerifier address) to bytecode
    //let mut deploy_bytecode = Bytes::from_hex(bytecode_hex)?.to_vec();
    //let mut constructor_arg = [0u8; 32];
    //constructor_arg[12..].copy_from_slice(zk_jwt_proof_verifier_address.as_slice());
    //zk_deploy_bytecode.extend_from_slice(&constructor_arg);

    //let deploy_tx = TransactionRequest::default().with_deploy_code(Bytes::from(deploy_bytecode));
    //let receipt = provider.send_transaction(deploy_tx).await?.get_receipt().await?;
    //let contract_address = receipt.contract_address.expect("ReInsurancePool deployment failed");

    let reinsurance_pool = ReInsurancePool::new(contract_address, &provider);
    println!("✅ ReInsurancePool contract address on BASE Mainnet: {:?}", contract_address);

    // 7. Call the ReInsurancePool contract (expecting it to fail gracefully)
    println!("🔄 Calling the ReInsurancePool#checkpoint() ...");
    let method_name: String = "checkpoint".to_string();
    let tx = reinsurance_pool.checkpoint(method_name);
    println!("🔄 Result: {:?}", tx);

    // 8. Send the transaction and await receipt
    let tx_sent = tx.send().await?;
    let tx_receipt = tx_sent.get_receipt().await?;
    println!("✅ Transaction receipt: {:?}", tx_receipt);

    Ok(())
} 