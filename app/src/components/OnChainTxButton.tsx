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
      <div>
        <button onClick={handleCallCheckpointFunction}>Call Checkpoint Function</button>
      </div>
    )
}
