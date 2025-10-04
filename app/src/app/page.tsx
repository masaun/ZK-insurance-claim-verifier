import { Header } from "@/components/Header";
import { InfoList } from "@/components/InfoList";
import { ActionButtonList } from "@/components/ActionButtonList";
import { OnChainTxButton } from "@/components/OnChainTxButton";

export default function Home() {
  return (
    <div className="main-layout">
      <Header />
      
      {/* Hero Section */}
      <section className="hero-section">
        <div className="container">
          <div className="text-center space-y-6 max-w-4xl mx-auto">
            <div className="space-y-4">
              <h1>Zero-Knowledge Insurance Claim Verifier</h1>
              <p className="text-xl text-foreground-muted max-w-2xl mx-auto">
                Verify insurance claims privately and securely using zero-knowledge proofs on Swell Chain. 
                No personal data exposed, complete privacy guaranteed.
              </p>
            </div>
            
            <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
              <a href="/claim" className="btn btn-primary btn-lg">
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                </svg>
                Submit Insurance Claim
              </a>
              <a href="#features" className="btn btn-outline btn-lg">
                Learn More
              </a>
            </div>
            
            <div className="text-sm text-foreground-light">
              Built on Swell Chain • Powered by Noir ZK Proofs
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="section">
        <div className="container">
          <div className="text-center space-y-4 mb-12">
            <h2>Key Features</h2>
            <p className="text-lg text-foreground-muted max-w-2xl mx-auto">
              Experience the future of insurance verification with privacy-first technology
            </p>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
            <div className="card text-center">
              <div className="w-10 h-10 bg-secondary/10 rounded-lg flex items-center justify-center mx-auto mb-4">
                <svg className="w-5 h-5 text-secondary" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" />
                </svg>
              </div>
              <h3 className="card-title">Privacy First</h3>
              <p className="card-description">
                Zero-knowledge proofs ensure your personal data never leaves your device while still proving claim validity.
              </p>
            </div>
            
            <div className="card text-center">
              <div className="w-10 h-10 bg-accent/10 rounded-lg flex items-center justify-center mx-auto mb-4">
                <svg className="w-5 h-5 text-accent" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M13 10V3L4 14h7v7l9-11h-7z" />
                </svg>
              </div>
              <h3 className="card-title">Lightning Fast</h3>
              <p className="card-description">
                Instant verification on Swell Chain with minimal gas fees and maximum throughput.
              </p>
            </div>
            
            <div className="card text-center">
              <div className="w-10 h-10 bg-success/10 rounded-lg flex items-center justify-center mx-auto mb-4">
                <svg className="w-5 h-5 text-success" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                </svg>
              </div>
              <h3 className="card-title">Tamper Proof</h3>
              <p className="card-description">
                Cryptographic verification ensures claims cannot be forged or manipulated.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* How It Works Section */}
      <section id="how-it-works" className="section bg-background-secondary">
        <div className="container">
          <div className="text-center space-y-4 mb-12">
            <h2>How It Works</h2>
            <p className="text-lg text-foreground-muted max-w-2xl mx-auto">
              Simple three-step process to verify your insurance claims
            </p>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="text-center space-y-4">
              <div className="w-16 h-16 bg-primary rounded-full flex items-center justify-center mx-auto">
                <span className="text-white font-bold text-xl">1</span>
              </div>
              <h3>Submit Claim Data</h3>
              <p className="text-foreground-muted">
                Upload your insurance claim documents securely to generate a zero-knowledge proof.
              </p>
            </div>
            
            <div className="text-center space-y-4">
              <div className="w-16 h-16 bg-secondary rounded-full flex items-center justify-center mx-auto">
                <span className="text-white font-bold text-xl">2</span>
              </div>
              <h3>Generate Proof</h3>
              <p className="text-foreground-muted">
                Our Noir circuits create a cryptographic proof of your claim's validity without exposing personal data.
              </p>
            </div>
            
            <div className="text-center space-y-4">
              <div className="w-16 h-16 bg-accent rounded-full flex items-center justify-center mx-auto">
                <span className="text-white font-bold text-xl">3</span>
              </div>
              <h3>Verify On-Chain</h3>
              <p className="text-foreground-muted">
                The proof is verified on Swell Chain, providing immutable confirmation of your claim.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* Actions Section */}
      <section className="section">
        <div className="container">
          <div className="max-w-4xl mx-auto">
            <div className="card">
              <div className="card-header text-center">
                <h2 className="card-title text-2xl">Try the Demo</h2>
                <p className="card-description">
                  Connect your wallet and test the insurance claim verification system
                </p>
              </div>
              
              <div className="space-y-6">
                <ActionButtonList />
                
                <div className="border-t pt-6">
                  <InfoList />
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-border bg-background-secondary">
        <div className="container">
          <div className="py-8 flex flex-col md:flex-row justify-between items-center gap-4">
            <div className="flex items-center gap-2">
              <div className="h-6 w-6 rounded bg-primary flex items-center justify-center">
                <span className="text-white font-bold text-xs">ZK</span>
              </div>
              <span className="font-medium">Insurance Verifier</span>
            </div>
            
            <div className="flex items-center gap-6 text-sm text-foreground-muted">
              <a href="https://github.com" className="hover:text-foreground transition-colors">
                GitHub
              </a>
              <a href="https://docs.swell.io" className="hover:text-foreground transition-colors">
                Swell Chain
              </a>
              <span>Built for Swell City Buildathon</span>
            </div>
          </div>
        </div>
      </footer>
    </div>
  );
}