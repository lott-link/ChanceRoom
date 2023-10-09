const { network } = require("hardhat");

const zero_address = "0x0000000000000000000000000000000000000000"

let factoryAddr = zero_address
let swapBurnerAddr = zero_address

  if(network.config.chainId == 137) {

    factoryAddr = "0x000004911bedE2053923bAF3b59e1a9f034482C9"
    swapBurnerAddr = "0x72b59F7A199f1F8d6d25A2e6269318157eC9F55B"

  } else if(network.config.chainId == 80001) {

    factoryAddr = "0xC5197e5dcEE9268EA665086Fe918872bD3Bb5318"
    swapBurnerAddr = "0xbB9Edb9A00f3357965951a36dAc1a07a5bb037Cf"
  }


module.exports = {
  factoryAddr,
  swapBurnerAddr
}