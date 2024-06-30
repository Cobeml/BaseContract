const hre = require("hardhat");

async function main() {
    // Get the deployer account
    const [deployer] = await hre.ethers.getSigners();
    console.log("Using the deployer account:", deployer.address);

    // Contract address and ABI
    const contractAddress = "0xa7fa7C4eD8c6009845826D2A84bE75b3599Df9ec";
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
        const tx = await contract.checkAllowance(contractAddress,contractAddress,'0x65C7Aba8cf9DC43F8b135CC8405d614AF2Ae7e46',{ gasLimit: 300000 });
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