'use client'

import Link from 'next/link'
import { ConnectButton } from './ConnectButton'

export const Header = () => {
  return (
    <header className="border-b border-border bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60 sticky top-0 z-50">
      <div className="container">
        <div className="flex h-16 items-center justify-between">
          {/* Logo and Brand */}
          <div className="flex items-center gap-6">
            <div className="flex items-center gap-2">
              <div className="h-8 w-8 rounded-md bg-primary flex items-center justify-center">
                <span className="text-white font-bold text-sm">ZK</span>
              </div>
              <span className="font-semibold text-lg">Insurance Verifier</span>
            </div>
          </div>

          {/* Navigation */}
          <nav className="hidden md:flex items-center gap-6">
            <Link href="/" className="text-foreground-muted hover:text-foreground transition-colors">
              Home
            </Link>
            <Link href="/claim" className="text-foreground-muted hover:text-foreground transition-colors">
              Submit Claim
            </Link>
            <a href="#features" className="text-foreground-muted hover:text-foreground transition-colors">
              Features
            </a>
            <a href="#how-it-works" className="text-foreground-muted hover:text-foreground transition-colors">
              How it Works
            </a>
          </nav>

          {/* Connect Button */}
          <div className="flex items-center gap-4">
            <ConnectButton />
          </div>
        </div>
      </div>
    </header>
  )
}