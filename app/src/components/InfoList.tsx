'use client'

import { useEffect } from 'react'
import {
    useAppKitState,
    useAppKitTheme,
    useAppKitEvents,
    useAppKitAccount,
    useWalletInfo
     } from '@reown/appkit/react'
import { useClientMounted } from "@/hooks/useClientMount";

export const InfoList = () => {
    const kitTheme = useAppKitTheme();
    const state = useAppKitState();
    const {address, caipAddress, isConnected, embeddedWalletInfo} = useAppKitAccount();
    const events = useAppKitEvents()
    const walletInfo = useWalletInfo()
    const mounted = useClientMounted();
    useEffect(() => {
        console.log("Events: ", events);
    }, [events]);

  return !mounted ? null : (
    <div className="space-y-4">
      <div className="text-center mb-6">
        <h3 className="text-lg font-semibold">Wallet Information</h3>
        <p className="text-sm text-foreground-muted">Connected wallet details and status</p>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        <div className="card">
          <div className="card-header">
            <h4 className="card-title text-sm">Account</h4>
          </div>
          <div className="space-y-2 text-sm">
            <div className="flex justify-between">
              <span className="text-foreground-muted">Status:</span>
              <span className={`font-medium ${isConnected ? 'text-success' : 'text-error'}`}>
                {isConnected ? 'Connected' : 'Disconnected'}
              </span>
            </div>
            {address && (
              <div className="flex justify-between">
                <span className="text-foreground-muted">Address:</span>
                <span className="font-mono text-xs">
                  {`${address.slice(0, 6)}...${address.slice(-4)}`}
                </span>
              </div>
            )}
            {walletInfo.walletInfo?.name && (
              <div className="flex justify-between">
                <span className="text-foreground-muted">Wallet:</span>
                <span className="font-medium">{walletInfo.walletInfo.name}</span>
              </div>
            )}
          </div>
        </div>

        <div className="card">
          <div className="card-header">
            <h4 className="card-title text-sm">Network</h4>
          </div>
          <div className="space-y-2 text-sm">
            <div className="flex justify-between">
              <span className="text-foreground-muted">Chain:</span>
              <span className="font-medium">{state.activeChain || 'Not Connected'}</span>
            </div>
            <div className="flex justify-between">
              <span className="text-foreground-muted">Loading:</span>
              <span className={`font-medium ${state.loading ? 'text-warning' : 'text-success'}`}>
                {state.loading ? 'Yes' : 'No'}
              </span>
            </div>
            <div className="flex justify-between">
              <span className="text-foreground-muted">Theme:</span>
              <span className="font-medium capitalize">{kitTheme.themeMode}</span>
            </div>
          </div>
        </div>
      </div>

      {embeddedWalletInfo && (
        <div className="card">
          <div className="card-header">
            <h4 className="card-title text-sm">Embedded Wallet</h4>
          </div>
          <div className="space-y-2 text-sm">
            {embeddedWalletInfo.user?.email && (
              <div className="flex justify-between">
                <span className="text-foreground-muted">Email:</span>
                <span className="font-medium">{embeddedWalletInfo.user.email}</span>
              </div>
            )}
            {embeddedWalletInfo.user?.username && (
              <div className="flex justify-between">
                <span className="text-foreground-muted">Username:</span>
                <span className="font-medium">{embeddedWalletInfo.user.username}</span>
              </div>
            )}
            {embeddedWalletInfo.authProvider && (
              <div className="flex justify-between">
                <span className="text-foreground-muted">Provider:</span>
                <span className="font-medium">{embeddedWalletInfo.authProvider}</span>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  )
}
