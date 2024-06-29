const hre = require("hardhat");

async function main() {
    // Get the deployer account
    const [deployer] = await hre.ethers.getSigners();
    console.log("Using the deployer account:", deployer.address);

    // Contract address and ABI
    const contractAddress = "0x9894Bfa200E6A6420c93a437A343Ea2035294fb6";
    const contractAbi = require("../artifacts/contracts/Competition(v3).sol/CompetitionV3.json").abi;

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
        const tx = await contract.start( { gasLimit: 3_000_000 });
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