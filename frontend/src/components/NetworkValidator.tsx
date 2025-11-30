import { useAccount, useChainId, useSwitchChain } from 'wagmi'
import { baseSepolia } from 'wagmi/chains'

export function NetworkValidator({ children }: { children: React.ReactNode }) {
  const chainId = useChainId()
  const { isConnected } = useAccount()
  const { switchChain } = useSwitchChain()
  
  const isCorrectNetwork = chainId === baseSepolia.id
  
  if (!isConnected || isCorrectNetwork) {
    return <>{children}</>
  }
  
  return (
    <div className="network-warning">
      <div className="warning-card">
        <div className="warning-icon">⚠️</div>
        <h2>Wrong Network</h2>
        <p>Please switch to Base Sepolia testnet to use Lockbox</p>
        <div className="network-info">
          <p><strong>Current:</strong> {chainId}</p>
          <p><strong>Required:</strong> Base Sepolia ({baseSepolia.id})</p>
        </div>
        <button
          className="btn btn-primary"
          onClick={() => switchChain({ chainId: baseSepolia.id })}
        >
          Switch to Base Sepolia
        </button>
      </div>
    </div>
  )
}
