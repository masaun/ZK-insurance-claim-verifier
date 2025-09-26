import { sepolia, mainnet, arbitrum, base } from '@reown/appkit/networks'
import type { AppKitNetwork } from '@reown/appkit/networks'
import { createAppKit } from "@reown/appkit/react";

// @dev - Ethers.js v6 adapter
import { EthersAdapter } from "@reown/appkit-adapter-ethers";

// Get projectId from https://dashboard.reown.com
export const projectId = process.env.NEXT_PUBLIC_PROJECT_ID || "b56e18d47c72ab683b10814fe9495694" // this is a public projectId only to use on localhost
//console.log(`Using projectId: ${projectId}`); // @dev - [Result]: OK

if (!projectId) {
  throw new Error('Project ID is not defined')
}

// @dev - Define supported networks
export const networks = [sepolia, mainnet, arbitrum, base] as [AppKitNetwork, ...AppKitNetwork[]]

// 2. Create a metadata object
const metadata = {
  name: "My Website",
  description: "My Website description",
  url: "https://mywebsite.com", // origin must match your domain & subdomain
  icons: ["https://avatars.mywebsite.com/"],
};

// 3. Create the AppKit instance
createAppKit({
  adapters: [new EthersAdapter()],
  metadata,
  networks: networks,
  //networks: [mainnet, arbitrum],
  projectId,
  features: {
    analytics: true, // Optional - defaults to your Cloud configuration
  },
});