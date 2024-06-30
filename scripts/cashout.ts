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
const contractAddress = "0x5853a99Aa16BBcabe1EA1a92c09F984643c04fdB";
const contractAbi = require("../artifacts/contracts/Competition.sol/Competition.json").abi;
const tokenAbi = require("../artifacts/contracts/Token.sol/Token.json").abi;
const tokenAddress = "0x75FfA03B837dd4cfFC816cEe3Abd11C01d25e356";

async function main() {
    const provider = new ethers.JsonRpcProvider('https://sepolia.base.org');
    const wallet = new ethers.Wallet(PRIV_KEY, provider);

    // Create contract instances
    const contract = new hre.ethers.Contract(contractAddress, contractAbi, wallet);

    // Define the amount of tokens to cash out
    const amountToCashOut = ethers.parseUnits("10", 18); // Example: cash out 10 tokens

    // Approve the contract to spend tokens on behalf of the user
    try {
        const approveTx = await contract.approveTokens(tokenAddress, contractAddress, amountToCashOut);
        console.log("Approval transaction successful:", approveTx.hash);
        await approveTx.wait();
    } catch (error) {
        console.error("Error during approval:", error);
        return;
    }

    // Call the cashout function
    try {
        const cashoutTx = await contract.cashout(amountToCashOut, { gasLimit: 300000 });
        console.log("Cashout transaction successful:", cashoutTx.hash);

        const cashoutReceipt = await cashoutTx.wait();
        console.log("Cashout transaction mined:", cashoutReceipt.transactionHash);

        // Check final ETH balance of the user
        const userEthBalance = await provider.getBalance(wallet.address);
        console.log(`User ETH balance after cashout: ${ethers.formatUnits(userEthBalance, 18)} ETH`);
    } catch (error) {
        console.error("Error during cashout:", error);
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });