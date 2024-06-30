import { ethers } from 'hardhat';

async function main() {
  // const token = await ethers.deployContract('Token', ['Life','LIFE']);

  // await token.waitForDeployment();
  // console.log('Token Contract Deployed at ' + token.target);
  
  const [deployer] = await ethers.getSigners();
  console.log("Deployer:", deployer.address);

  const competition = await ethers.deployContract('Competition', []);

  await competition.waitForDeployment();

  console.log('Competition Contract Deployed at ' + competition.target);


  // Contract address and ABI
  const contractAddress = competition.target;
  const contractAbi = require("../artifacts/contracts/Competition.sol/Competition.json").abi;

  // Create a contract instance
  const contract = new hre.ethers.Contract(contractAddress, contractAbi, deployer);

  const token1 = await ethers.deployContract('Token', ['Name1','Symbol1', contractAddress]);
  const token2 = await ethers.deployContract('Token', ['Name2','Symbol2', contractAddress]);

  await token1.waitForDeployment();
  console.log('Token1 contract deployed at', token1.target);

  await token2.waitForDeployment();
  console.log('Token2 contract deployed at', token2.target);

  try {
    const tx = await contract.start(token1.target + '', token2.target + '', { gasLimit: 3000000 });
    console.log("Transaction successful:", tx);
  } catch (error) {
    console.error("Error:", error);
  }


  const approveTx1 = await contract.approveTokens(token1.target, contractAddress, ethers.parseUnits("100000",18));
  const approveTx2 = await contract.approveTokens(token2.target, contractAddress, ethers.parseUnits("100000",18));
  console.log("Approved sending tokens");

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});