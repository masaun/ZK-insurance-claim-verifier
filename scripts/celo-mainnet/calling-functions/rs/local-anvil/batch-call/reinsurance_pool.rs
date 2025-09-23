// @dev - Alloy
use alloy::{
    providers::{Provider, ProviderBuilder},
    signers::local::PrivateKeySigner,
    sol,
    primitives::{Bytes, FixedBytes},
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

#[tokio::main]
async fn main() -> eyre::Result<()> {
    dotenv().ok();  // Loads .env file

    // 2. Start Anvil (local test network)
    let anvil = Anvil::new().spawn();
    println!("✅ Anvil running at: {}", anvil.endpoint());

    // Create a signer using one of Anvil's default private keys
    let signer: PrivateKeySigner = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80".parse()?;
    
    // Create provider with wallet  
    let provider = ProviderBuilder::new()
        .with_gas_estimation()
        .wallet(signer.clone())
        .on_http(anvil.endpoint_url());

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
    let mut deploy_bytecode = Bytes::from_hex(bytecode_hex)?.to_vec();
    //let mut constructor_arg = [0u8; 32];
    //constructor_arg[12..].copy_from_slice(zk_jwt_proof_verifier_address.as_slice());
    //zk_deploy_bytecode.extend_from_slice(&constructor_arg);

    let deploy_tx = TransactionRequest::default().with_deploy_code(Bytes::from(deploy_bytecode));
    let receipt = provider.send_transaction(deploy_tx).await?.get_receipt().await?;
    let contract_address = receipt.contract_address.expect("ReInsurancePool deployment failed");

    let reinsurance_pool = ReInsurancePool::new(contract_address, &provider);
    println!("✅ ReInsurancePool deployed at: {:?}", contract_address);

    // 7. Call the ReInsurancePool contract (expecting it to fail gracefully)
    println!("🔄 Calling the ReInsurancePool#checkpoint() ...");
    let method_name: String = "checkpoint".to_string();
    let result = reinsurance_pool.checkpoint(method_name);
    println!("🔄 Result: {:?}", result);

    Ok(())
}



// #[tokio::main]
// async fn main() -> Result<()> {
//     dotenv().ok();  // Loads .env file

//     // let CELO_MAINNET_RPC = env::var("CELO_MAINNET_RPC").parse()?;
//     // let reinsurance_pool_on_celo_mainnet: Address = env::var("REINSURANCE_POOL_on_celo_mainnet")
//     //     .expect("Set REINSURANCE_POOL_on_celo_mainnet in your .env")
//     //     .parse()?;
//     // let private_key: LocalWallet = env::var("PRIVATE_KEY");

//     // // Set up provider and wallet using Alloy's recommended Http provider
//     // let provider = ProviderBuilder::new().connect_http(CELO_MAINNET_RPC);
//     // let wallet: LocalWallet = private_key.parse()?;
//     // let client = Arc::new(provider.with_signer(wallet));

//     // Parse contract address
//     let contract_addr: Address = reinsurance_pool_on_celo_mainnet.parse()?;
//     let contract = Contract::new(contract_addr, client.clone());

//     // Example: Call registerAsDepositer (write)
//     let tx = contract.method::<_, bool>("registerAsDepositer", ())?.send().await?;
//     println!("registerAsDepositer tx: {:?}", tx);

//     // Example: Call deregisterAsDepositer (write)
//     let tx = contract.method::<_, bool>("deregisterAsDepositer", ())?.send().await?;
//     println!("deregisterAsDepositer tx: {:?}", tx);

//     // Example: Call getRewards (view)
//     let rewards: bool = contract.method::<_, bool>("getRewards", ())?.call().await?;
//     println!("getRewards: {:?}", rewards);

//     // Example: Call checkpoint (write)
//     let tx = contract.method::<_, bool>("checkpoint", ("myMethodName".to_string(),))?.send().await?;
//     println!("checkpoint tx: {:?}", tx);

//     // Example: Call depositNativeTokenIntoReInsurancePool (write, payable)
//     let value = U256::from(1u64); // 1 wei
//     //let value = U256::from(1_000_000_000_000_000_000u64); // 1 ETH in wei
//     let tx = contract
//         .method::<_, bool>("depositNativeTokenIntoReInsurancePool", ())?
//         .value(value)
//         .send()
//         .await?;
//     println!("depositNativeTokenIntoReInsurancePool tx: {:?}", tx);

//     // ...repeat for other functions as needed...

//     Ok(())
// }
