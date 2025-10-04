'use client'
import { config } from '@/config'

// @dev - Wagmi, etc
import { writeContract } from '@wagmi/core'
//import { useReadContract, useWriteContract } from "wagmi";
import ReInsurancePoolArtifact from "./artifacts/ReInsurancePool.sol/ReInsurancePool.json";
//import { USDTAbi } from "../abi/USDTAbi";

const ReInsurancePoolAddress = process.env.NEXT_PUBLIC_REINSURANCE_POOL_ON_BASE_MAINNET; // Replace with your contract address
//const USDTAddress = "0x...";

export const OnChainTxButton = () => {
    const handleCallCheckpointFunction = async () => {
      try {
        const result = await writeContract(config,{
            abi: ReInsurancePoolArtifact.abi,
            //abi: USDTAbi,
            address: ReInsurancePoolAddress as `0x${string}`,
            //address: USDTAddress,
            functionName: "checkpoint",
            args: ["Test Checkpoint from Frontend"],
        });
        console.log("Transaction result:", result);
      } catch (error) {
        console.error("Failed to call checkpoint function:", error);
      }
    }

    return (
      <button 
        onClick={handleCallCheckpointFunction}
        className="btn btn-primary btn-lg"
      >
        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
        Verify Insurance Claim
      </button>
    )
}
