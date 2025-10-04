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


async function useVerifyAPI() {
    const walletKit = await initWalletKit();

    /// ...
    walletKit.on("auth_request", async (authRequest) => {
        const { verifyContext } = authRequest
        const validation = verifyContext.verified.validation // can be VALID, INVALID or UNKNOWN
        const origin = verifyContext.verified.origin // the actual verified origin of the request
        const isScam = verifyContext.verified.isScam // true if the domain is flagged as malicious

        // if the domain is flagged as malicious, you should warn the user as they may lose their funds - check the `Threat` case for more info
        if(isScam) {
            // show a warning screen to the user
            // and proceed only if the user accepts the risk
        }

        switch(validation) {
            case "VALID":
            // proceed with the request - check the `Domain match` case for more info
            break
            case "INVALID":
            // show a warning dialog to the user - check the `Mismatch` case for more info
            // and proceed only if the user accepts the risk
            break
            case "UNKNOWN":
            // show a warning dialog to the user - check the `Unverified` case for more info
            // and proceed only if the user accepts the risk
            break
        }
    })

}
