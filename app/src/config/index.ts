import { sepolia, mainnet, base } from '@reown/appkit/networks'
import type { AppKitNetwork } from '@reown/appkit/networks'

// Get projectId from https://dashboard.reown.com
export const projectId = process.env.NEXT_PUBLIC_PROJECT_ID || "b56e18d47c72ab683b10814fe9495694" // this is a public projectId only to use on localhost
//console.log(`Using projectId: ${projectId}`); // @dev - [Result]: OK

if (!projectId) {
  throw new Error('Project ID is not defined')
}

export const networks = [sepolia, mainnet, base] as [AppKitNetwork, ...AppKitNetwork[]]

