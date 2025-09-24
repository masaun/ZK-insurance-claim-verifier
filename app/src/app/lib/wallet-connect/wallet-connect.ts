import { Core } from "@walletconnect/core";
import { WalletKit } from "@reown/walletkit";

const core = new Core({
  projectId: process.env.PROJECT_ID,
});

const walletKit = await WalletKit.init({
  core, // <- pass the shared `core` instance
  metadata: {
    name: "Demo app",
    description: "Demo Client as Wallet/Peer",
    url: "https://reown.com/walletkit",
    icons: [],
  },
});


// Subscribe to session events
function handleRedirect(session) {
  // Check if this is a native app
  const isNativeApp = session.peer.metadata.redirect !== undefined;
  
  if (isNativeApp) {
    // Redirect to native app if URL is available
    if (session.peer.metadata.redirect) {
      window.location.href = session.peer.metadata.redirect;
    } else {
      // Show "Return to App" message
      showReturnToAppMessage();
    }
  } else {
    // For web dApps, redirect back to original tab
    if (window.opener) {
      window.opener.location.href = session.peer.metadata.url;
      window.close();
    }
  }
}