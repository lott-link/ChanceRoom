require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");

const { PRIVATE_KEY, SMARTCHAIN_API_KEY, MUMBAI_API_KEY, POLYGONSCAN_API_KEY, COINMARKETCAP_API_KEY } = require('./secret.json');

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
  version: "0.8.18",
  settings: {
    // "viaIR": true,
    optimizer: {
      enabled: true,
      // runs: 100000,
    }
   }
  },
  networks: {
    polygon: {
      url: `https://polygon-rpc.com/`,
      // url: `https://rpc-mainnet.maticvigil.com`,
      // url: `https://rpc.ankr.com/polygon/`,
      accounts: [`0x${PRIVATE_KEY}`],
      // gasPrice: 500 * 10 ** 9,
      chainId: 137
    },
    polygonMumbai: {
      // url: `https://matic-mumbai.chainstacklabs.com`,
      // url: `https://rpc.ankr.com/polygon_mumbai`,
      url: `https://polygon-mumbai.blockpi.network/v1/rpc/public`,
      accounts: [`0x${PRIVATE_KEY}`],
      chainId: 80001
    },
  },
  gasReporter: {
    enabled: true,
    currency: 'USD',
    outputFile: 'gas-reporter-matic.txt',
    noColors: true,
    coinmarketcap: `${COINMARKETCAP_API_KEY}`,
    gasPrice: 21,
    token: 'MATIC'
  },
  etherscan: {
    apiKey: {
      polygon: `${POLYGONSCAN_API_KEY}`,
      polygonMumbai: `${POLYGONSCAN_API_KEY}`,
    }
  },
};
