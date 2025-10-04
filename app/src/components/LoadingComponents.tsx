'use client'

export const LoadingSpinner = () => {
  return (
    <div className="flex items-center justify-center">
      <div className="animate-spin rounded-full h-6 w-6 border-2 border-primary border-t-transparent"></div>
    </div>
  )
}

export const LoadingButton = ({ 
  children, 
  loading = false, 
  className = "", 
  ...props 
}: {
  children: React.ReactNode
  loading?: boolean
  className?: string
} & React.ButtonHTMLAttributes<HTMLButtonElement>) => {
  return (
    <button 
      className={`btn ${className} ${loading ? 'opacity-75 cursor-not-allowed' : ''}`} 
      disabled={loading}
      {...props}
    >
      {loading ? (
        <div className="flex items-center gap-2">
          <LoadingSpinner />
          Processing...
        </div>
      ) : (
        children
      )}
    </button>
  )
}