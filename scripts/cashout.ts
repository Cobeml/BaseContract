import { ethers } from "ethers";
import * as hre from "hardhat";

// Replace with your contract's address and ABI
const contractAddress = "0xf953b3A269d80e3eB0F2947630Da976B896A8C5b";
const contractAbi = require("../artifacts/contracts/Competition.sol/Competition.json").abi;
const tokenAbi = require("../artifacts/contracts/Token.sol/Token.json").abi;
const tokenAddress = "0x86A2EE8FAf9A840F7a2c64CA3d51209F9A02081D";

async function main() {
    // Replace with the user's private key or use the hardhat config
    const privateKey = "0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d";
    const provider = new ethers.JsonRpcProvider('http://127.0.0.1:8545/');
    const wallet = new ethers.Wallet(privateKey, provider);

    // Create contract instances
    const contract = new hre.ethers.Contract(contractAddress, contractAbi, wallet);
    const tokenContract = new hre.ethers.Contract(tokenAddress, tokenAbi, wallet);

    // Define the amount of tokens to cash out
    const amountToCashOut = ethers.parseUnits("69000", 18); // Example: cash out 10 tokens

    // Approve the contract to spend tokens on behalf of the user
    try {
        const approveTx = await tokenContract.approve(contractAddress, amountToCashOut);
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