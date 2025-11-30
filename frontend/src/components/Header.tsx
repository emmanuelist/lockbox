import { useAccount } from 'wagmi'

export function Header() {
  const { address, isConnected } = useAccount()

  return (
    <header className="header">
      <div className="header-content">
        <div className="logo">
          <h1>🔒 Lockbox</h1>
          <p className="tagline">Time-locked savings on Base</p>
        </div>

        <div className="wallet-section">
          {isConnected && address && (
            <div className="connected-info">
              <span className="address-badge">
                {address.slice(0, 6)}...{address.slice(-4)}
              </span>
            </div>
          )}
          <appkit-button />
        </div>
      </div>
    </header>
  )
}
