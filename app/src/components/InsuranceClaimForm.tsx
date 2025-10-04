'use client'

import { useState } from 'react'
import { OnChainTxButton } from './OnChainTxButton'

export const InsuranceClaimForm = () => {
  const [formData, setFormData] = useState({
    claimId: '',
    policyNumber: '',
    incidentDate: '',
    claimAmount: '',
    description: ''
  })

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target
    setFormData(prev => ({
      ...prev,
      [name]: value
    }))
  }

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      console.log('File uploaded:', file.name)
      // Handle file upload logic here
    }
  }

  return (
    <div className="max-w-2xl mx-auto">
      <div className="card">
        <div className="card-header text-center">
          <h2 className="card-title text-2xl">Submit Insurance Claim</h2>
          <p className="card-description">
            Submit your insurance claim securely with zero-knowledge verification
          </p>
        </div>

        <form className="space-y-6" onSubmit={(e) => e.preventDefault()}>
          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <label htmlFor="claimId" className="text-sm font-medium text-foreground">
                Claim ID
              </label>
              <input
                type="text"
                id="claimId"
                name="claimId"
                value={formData.claimId}
                onChange={handleInputChange}
                className="input"
                placeholder="CLM-2024-001"
                required
              />
            </div>

            <div className="space-y-2">
              <label htmlFor="policyNumber" className="text-sm font-medium text-foreground">
                Policy Number
              </label>
              <input
                type="text"
                id="policyNumber"
                name="policyNumber"
                value={formData.policyNumber}
                onChange={handleInputChange}
                className="input"
                placeholder="POL-123456789"
                required
              />
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            <div className="space-y-2">
              <label htmlFor="incidentDate" className="text-sm font-medium text-foreground">
                Incident Date
              </label>
              <input
                type="date"
                id="incidentDate"
                name="incidentDate"
                value={formData.incidentDate}
                onChange={handleInputChange}
                className="input"
                required
              />
            </div>

            <div className="space-y-2">
              <label htmlFor="claimAmount" className="text-sm font-medium text-foreground">
                Claim Amount ($)
              </label>
              <input
                type="number"
                id="claimAmount"
                name="claimAmount"
                value={formData.claimAmount}
                onChange={handleInputChange}
                className="input"
                placeholder="5000"
                min="0"
                step="0.01"
                required
              />
            </div>
          </div>

          <div className="space-y-2">
            <label htmlFor="description" className="text-sm font-medium text-foreground">
              Incident Description
            </label>
            <textarea
              id="description"
              name="description"
              value={formData.description}
              onChange={handleInputChange}
              rows={4}
              className="input resize-none"
              placeholder="Describe the incident and damages..."
              required
            />
          </div>

          <div className="space-y-2">
            <label htmlFor="documents" className="text-sm font-medium text-foreground">
              Supporting Documents
            </label>
            <div className="border-2 border-dashed border-border rounded-lg p-6 text-center hover:border-primary/50 transition-colors">
              <input
                type="file"
                id="documents"
                onChange={handleFileUpload}
                multiple
                accept=".pdf,.jpg,.jpeg,.png,.doc,.docx"
                className="hidden"
              />
              <label htmlFor="documents" className="cursor-pointer">
                <div className="space-y-2">
                  <svg className="w-8 h-8 text-foreground-muted mx-auto" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                  </svg>
                  <p className="text-foreground-muted">
                    Click to upload documents or drag and drop
                  </p>
                  <p className="text-xs text-foreground-light">
                    PDF, JPG, PNG, DOC up to 10MB each
                  </p>
                </div>
              </label>
            </div>
          </div>

          <div className="border border-border rounded-lg p-4 bg-background-secondary">
            <div className="flex items-start gap-3">
              <svg className="w-5 h-5 text-secondary mt-0.5 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
              </svg>
              <div className="space-y-2">
                <h4 className="text-sm font-medium">Privacy Protection</h4>
                <p className="text-xs text-foreground-muted">
                  Your personal data is processed locally using zero-knowledge proofs. 
                  No sensitive information is transmitted or stored on external servers.
                </p>
              </div>
            </div>
          </div>

          <div className="flex flex-col sm:flex-row gap-4 justify-end">
            <button type="button" className="btn btn-outline">
              Save Draft
            </button>
            <OnChainTxButton />
          </div>
        </form>
      </div>
    </div>
  )
}