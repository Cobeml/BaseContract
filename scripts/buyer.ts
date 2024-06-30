import { ethers } from "ethers";
import * as hre from "hardhat";
import * as dotenv from "dotenv";
import * as path from "path";

// Load environment variables from .env file
dotenv.config({ path: path.resolve(__dirname, './.env') });

if (!process.env.PRIVATE_KEY) {
  throw new Error("Please set your PRIVATE_KEY in a .env file");
}

const PRIV_KEY=process.env.PRIVATE_KEY;

// Replace with your contract's address and ABI
const contractAddress = "0x5E7e203e3F589604D5C28c3ee3D92c125368BF1D";
const contractAbi = require("../artifacts/contracts/Competition.sol/Competition.json").abi;
const tokenAbi = require("../artifacts/contracts/Token.sol/Token.json").abi;
const tokenAddress = "0xB12f386631A6d940480e57c8ffa6b0AFB5496b4e";

async function main() {
    const provider = new ethers.JsonRpcProvider('https://sepolia.base.org');
    const wallet = new ethers.Wallet(PRIV_KEY, provider);

    // Create a contract instance
    const contract = new hre.ethers.Contract(contractAddress, contractAbi, wallet);

    // Define the amount to send in Gwei
    const amountInGwei = 100;
    const amountInWei = amountInGwei * 1_000_000_000;

    // try {
    //     const approveTx = await contract.approveTokens(tokenAddress, contractAddress, amountInWei);
    //     console.log("Approval transaction successful:", approveTx.hash);
    //     await approveTx.wait();
    // } catch (error) {
    //     console.error("Error during approval:", error);
    //     return;
    // }

    try {
        const tx = await contract.checkAllowance(contractAddress,contractAddress,tokenAddress,{ gasLimit: 300000 });
        console.log("Amount Approved to Send:", tx);
    } catch (error) {
        console.error("Error:", error);
    }

    // Call the purchaseToken function
    try {
        const tx = await contract.purchaseToken(tokenAddress, { value: amountInWei, gasLimit: 3000000 });
        console.log("Transaction successful:", tx.hash);

        // Wait for the transaction to be mined
        const receipt = await tx.wait();
        console.log("Transaction mined:", receipt.transactionHash);
    } catch (error) {
        console.error("Error:", error);
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });