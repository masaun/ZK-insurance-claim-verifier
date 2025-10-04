'use client'
import { useDisconnect, useAppKit, useAppKitNetwork  } from '@reown/appkit/react'
import { networks } from '@/config'

export const ActionButtonList = () => {
    const { disconnect } = useDisconnect();
    const { open } = useAppKit();
    const { switchNetwork } = useAppKitNetwork();

    const handleDisconnect = async () => {
      try {
        await disconnect();
      } catch (error) {
        console.error("Failed to disconnect:", error);
      }
    }
  return (
    <div className="flex flex-col sm:flex-row gap-4 justify-center">
      <button 
        onClick={() => open()} 
        className="btn btn-secondary"
      >
        Open Wallet Settings
      </button>
      <button 
        onClick={handleDisconnect}
        className="btn btn-outline"
      >
        Disconnect Wallet
      </button>
      <button 
        onClick={() => switchNetwork(networks[1])} 
        className="btn btn-outline"
      >
        Switch to Swell Chain
      </button>
    </div>
  )
}
