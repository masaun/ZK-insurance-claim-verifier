import { Core } from "@walletconnect/core";
import { WalletKit } from "@reown/walletkit";


const core = new Core({
  projectId: process.env.PROJECT_ID,
});

async function initWalletKit() {    
    const walletkit = await WalletKit.init({
    core, // <- pass the shared `core` instance
    metadata: {
        name: "Demo app",
        description: "Demo Client as Wallet/Peer",
        url: "www.walletconnect.com",
        icons: [],
    },
    });
    return walletkit;
}


async function handleChainAbstraction(transaction: any, chainId: number, wallet: any) {
    const walletKit = await initWalletKit();

    // Check if chain abstraction is needed
    const result = await walletKit.chainAbstraction.prepare({
        transaction: {
            from: transaction.from as `0x${string}`,
            to: transaction.to as `0x${string}`,
            // @ts-ignore - cater for both input or data
            input: transaction.input || (transaction.data as `0x${string}`),
            chainId: chainId,
        },
        });

        // Handle the prepare result
        if ('success' in result) {
        if ('notRequired' in result.success) {
            // No bridging required, proceed with normal transaction
            console.log('no routing required');
        } else if ('available' in result.success) {
            const available = result.success.available;
            
            // Sign all bridge transactions and initial transaction
            const bridgeTxs = available.route.map(tx => tx.transactionHashToSign);
            const signedBridgeTxs = bridgeTxs.map(tx => wallet.signAny(tx));
            const signedInitialTx = wallet.signAny(available.initial.transactionHashToSign);

            // Execute the chain abstraction
            const result = await walletKit.chainAbstraction.execute({
            bridgeSignedTransactions: signedBridgeTxs,
            initialSignedTransaction: signedInitialTx,
            orchestrationId: available.routeResponse.orchestrationId,
            });
        }
    }

}