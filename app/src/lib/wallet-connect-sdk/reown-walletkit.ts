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

async function signSessionApproval() {
    const walletkit = await initWalletKit();
    walletkit.on("session_proposal", async (proposal) => {
    const session = await walletkit.approveSession({
        id: proposal.id,
        namespaces,
    });
    await walletkit.pair({ uri });
}

async function SignSessionRejection() {
    const walletkit = await initWalletKit();
    walletkit.on("session_proposal", async (proposal) => {
    const session = await walletkit.rejectSession({
        id: proposal.id,
        reason: getSdkError("USER_REJECTED_METHODS"),
    });
}

async function signSessionDisconnect() {
    const walletkit = await initWalletKit();
    await walletkit.disconnectSession({
        topic,
        reason: getSdkError("USER_DISCONNECTED"),
    });
}

async function respondingToSignSessionRequests() {
    const walletkit = await initWalletKit();
    walletkit.on("session_request", async (event) => {
        const { id, method, params } = event.request;
        await walletkit.respondSessionRequest({ id, result: response });
    });
}

async function UpdatingASignSession() {
    const walletkit = await initWalletKit();
    await walletkit.updateSession({ topic, namespaces: newNs });
}

async function updatingASignSession() {
    const walletkit = await initWalletKit();
    await walletkit.extendSession({ topic });
}

async function emitSignSessionEvents() {
    const walletkit = await initWalletKit();
    await walletkit.emitSessionEvent({
        topic,
        event: {
            name: "accountsChanged",
            data: ["0xab16a96D359eC26a11e2C2b3d8f8B8942d5Bfcdb"],
  },
  chainId: "eip155:1",
}

async function handleSignEvents() {
    const walletkit = await initWalletKit();
    walletkit.on("session_proposal", handler);
    walletkit.on("session_request", handler);
    walletkit.on("session_delete", handler);
}