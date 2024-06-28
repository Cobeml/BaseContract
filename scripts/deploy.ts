import { ethers } from 'hardhat';

async function main() {
  // const token = await ethers.deployContract('Token', ['Life','LIFE']);

  // await token.waitForDeployment();
  // console.log('Token Contract Deployed at ' + token.target);
  
  const token1 = await ethers.deployContract('Token', ['Name1','Symbol1']);
  const token2 = await ethers.deployContract('Token', ['Name2','Symbol2']);

  await token1.waitForDeployment();
  console.log('Token1 contract deployed at', token1.target);

  await token2.waitForDeployment();
  console.log('Token2 contract deployed at', token2.target);

  const competition = await ethers.deployContract('Competition', ['0x4752ba5dbc23f44d87826276bf6fd6b1c372ad24', token1.target + '', token2.target + '']);

  await competition.waitForDeployment();

  console.log('Competition Contract Deployed at ' + competition.target);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});