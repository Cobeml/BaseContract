const hre = require("hardhat");

async function main() {
    // Get the deployer account
    const [deployer] = await hre.ethers.getSigners();
    console.log("Using the deployer account:", deployer.address);

    // Contract address and ABI
    const contractAddress = "0x959922bE3CAee4b8Cd9a407cc3ac1C251C2007B1";
    const contractAbi = require("../artifacts/contracts/Competition.sol/Competition.json").abi;

    // Create a contract instance
    const contract = new hre.ethers.Contract(contractAddress, contractAbi, deployer);

    // Example function call from the deployer's address
    // try {
    //     const tx = await contract.getScore({ gasLimit: 30000000 });
    //     console.log("Transaction successful:", tx);
    // } catch (error) {
    //     console.error("Error:", error);
    // }
    try {
        const tx = await contract.start("!!Name1", "!!SYM1", "!!Name2", "!!SYM2", { gasLimit: 30000000 });
        await tx.wait();
        console.log("Transaction successful:", tx);
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