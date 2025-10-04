import { Header } from "@/components/Header";
import { InsuranceClaimForm } from "@/components/InsuranceClaimForm";

export default function ClaimPage() {
  return (
    <div className="main-layout">
      <Header />
      
      <section className="section">
        <div className="container">
          <div className="text-center space-y-4 mb-12">
            <h1>Submit Insurance Claim</h1>
            <p className="text-lg text-foreground-muted max-w-2xl mx-auto">
              Use our zero-knowledge verification system to submit and verify your insurance claim privately and securely.
            </p>
          </div>
          
          <InsuranceClaimForm />
        </div>
      </section>
    </div>
  );
}