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

  const competition = await ethers.deployContract('CompetitionV3', [0x27F971cb582BF9E50F397e4d29a5C7A34f11faA2, 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24,0x4200000000000000000000000000000000000006, token1.target + '', token2.target + '']);

  await competition.waitForDeployment();

  console.log('Competition Contract Deployed at ' + competition.target);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});