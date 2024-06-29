import { ethers } from "ethers";
import * as hre from "hardhat";

// Replace with your contract's address and ABI
const contractAddress = "0x84feC9B731818e8916Ef7c27e95dFB903210F24b";
const contractAbi = require("../artifacts/contracts/Competition.sol/Competition.json").abi;
const tokenAddress = "0xe5c16894E35b6eFcE82282511385340CeCc10D07"

async function main() {
    // Connect to the Ethereum network (e.g., local node, Infura, Alchemy)
    // Get the deployer account (replace with your private key or use hardhat config)
    const privateKey = "0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d";
    const provider = new ethers.JsonRpcProvider('http://127.0.0.1:8545/');
    

    const wallet = new ethers.Wallet(privateKey,provider);

    // Create a contract instance
    const contract = new hre.ethers.Contract(contractAddress, contractAbi, wallet);

    // Define the amount to send in Gwei
    const amountInGwei = 70_000;
    const amountInWei = amountInGwei * 1_000_000_000;

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