import { useWalletInfo } from '@reown/appkit/react'


function WalletDisplay() {
  const { walletInfo } = useWalletInfo();
  
  return (
    <div className="wallet-info">
      {walletInfo?.name && (
        <>
          <img src={walletInfo.icon} alt={walletInfo.name} />
          <span>{walletInfo.name}</span>
        </>
      )}
    </div>
  );
}