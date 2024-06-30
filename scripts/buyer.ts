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
const contractAddress = "0x6b6b4FA0A864A4A2488cC09a079E0398b42d9Cf8";
const contractAbi = require("../artifacts/contracts/Competition.sol/Competition.json").abi;
const tokenAbi = require("../artifacts/contracts/Token.sol/Token.json").abi;
const token1Address = "0x36b46D912249D7cD855F4DDB9f4C915b95a9E240";
const token2Address = "0x5264345864FE79E6B3f514b63cF4C4cb820d456e";

async function main() {
    const provider = new ethers.JsonRpcProvider('https://sepolia.base.org');
    const wallet = new ethers.Wallet(PRIV_KEY, provider);

    // Create a contract instance
    const contract = new hre.ethers.Contract(contractAddress, contractAbi, wallet);

    // Define the amount to send in Gwei
    const amountInGwei = 1000;
    const amountInWei = amountInGwei * 1_000_000_000;

    try {
        const tx = await contract.checkAllowance(contractAddress,contractAddress,token1Address,{ gasLimit: 300000 });
        console.log("Amount Approved to Send:", tx);
    } catch (error) {
        console.error("Error:", error);
    }

    // Call the purchaseToken function
    try {
        const tx = await contract.purchaseToken(token1Address, { value: amountInWei, gasLimit: 3000000 });
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