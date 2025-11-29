export function LoadingSkeleton({ type = 'card' }: { type?: 'card' | 'text' | 'button' }) {
  if (type === 'text') {
    return (
      <div className="skeleton skeleton-text" role="status" aria-label="Loading...">
        <span className="sr-only">Loading...</span>
      </div>
    )
  }

  if (type === 'button') {
    return (
      <div className="skeleton skeleton-button" role="status" aria-label="Loading...">
        <span className="sr-only">Loading...</span>
      </div>
    )
  }

  return (
    <div className="skeleton skeleton-card" role="status" aria-label="Loading...">
      <div className="skeleton-header"></div>
      <div className="skeleton-body">
        <div className="skeleton-line"></div>
        <div className="skeleton-line"></div>
        <div className="skeleton-line short"></div>
      </div>
      <span className="sr-only">Loading...</span>
    </div>
  )
}

export function BalanceLoader() {
  return (
    <div className="balance-card">
      <div className="balance-info">
        <h3>Total Balance</h3>
        <div className="skeleton skeleton-text" style={{ width: '200px', height: '48px', margin: '0 auto' }}></div>
      </div>
      <div className="timelock-info">
        <div className="skeleton skeleton-text" style={{ width: '150px', height: '20px', margin: '0 auto' }}></div>
      </div>
    </div>
  )
}
