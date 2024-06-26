import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';

require('dotenv').config();
const WALLET_KEY="PUT KEY HERE";
const LOCAL_WALLET_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

const config: HardhatUserConfig = {
  solidity: {
    version: '0.8.23',
  },
  networks: {
    // for mainnet
    // 'base-mainnet': {
    //   url: 'https://mainnet.base.org',
    //   accounts: [process.env.WALLET_KEY as string],
    //   gasPrice: 1000000000,
    // },
    // for testnet
    'base-sepolia': {
      url: 'https://sepolia.base.org',
      accounts: [WALLET_KEY as string],
      gasPrice: 1000000000,
    },
    // for local dev environment
    'base-local': {
      url: 'http://127.0.0.1:8545/',
      accounts: [LOCAL_WALLET_KEY as string],
      gasPrice: 1000000000,
    },
  },
  etherscan: {
    apiKey: {
     "base-sepolia": "PLACEHOLDER_STRING"
    },
    customChains: [
      {
        network: "base-sepolia",
        chainId: 84532,
        urls: {
         apiURL: "https://api-sepolia.basescan.org/api",
         browserURL: "https://sepolia.basescan.org"
        }
      }
    ]
  },
  defaultNetwork: 'hardhat',
};

export default config;

