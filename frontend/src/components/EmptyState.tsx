export function EmptyState({ 
  icon = '💰', 
  title = 'No Balance', 
  description = 'Make your first deposit to get started',
  action
}: {
  icon?: string
  title?: string
  description?: string
  action?: React.ReactNode
}) {
  return (
    <div className="empty-state">
      <div className="empty-icon">{icon}</div>
      <h3>{title}</h3>
      <p>{description}</p>
      {action && <div className="empty-action">{action}</div>}
    </div>
  )
}
