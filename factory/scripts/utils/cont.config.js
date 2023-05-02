const { network } = require("hardhat");

const zero_address = "0x0000000000000000000000000000000000000000"

let factoryAddr = zero_address

  if(network.config.chainId == 137) {

    factoryAddr = "0x000004911bedE2053923bAF3b59e1a9f034482C9"

  } else if(network.config.chainId == 80001) {

    factoryAddr = "0xC5197e5dcEE9268EA665086Fe918872bD3Bb5318"
  }


module.exports = {
  factoryAddr,
}