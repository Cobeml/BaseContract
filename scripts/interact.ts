const hre = require("hardhat");

async function main() {
    // Get the deployer account
    const [deployer] = await hre.ethers.getSigners();
    console.log("Using the deployer account:", deployer.address);

    // Contract address and ABI
    const contractAddress = "0xf953b3A269d80e3eB0F2947630Da976B896A8C5b";
    const contractAbi = require("../artifacts/contracts/Competition.sol/Competition.json").abi;

    // Create a contract instance
    const contract = new hre.ethers.Contract(contractAddress, contractAbi, deployer);

    // try {
    //     const tx = await contract.getScore({ gasLimit: 30000000 });
    //     console.log("Transaction successful:", tx);
    // } catch (error) {
    //     console.error("Error:", error);
    // }



    try {
        const tx = await contract.end(1, { gasLimit: 30000000 });
        console.log("Transaction successful:", tx);
    } catch (error) {
        console.error("Error:", error);
    }



    try { 
        const gameEnded = await contract.gameEnded();
        console.log("End?:",gameEnded);
    } catch (error){
        console.error("Error:",error);
    }

}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });