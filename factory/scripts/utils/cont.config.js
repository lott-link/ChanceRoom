const { network } = require("hardhat");

const zero_address = "0x0000000000000000000000000000000000000000"

let factoryAddr = zero_address

  if(network.config.chainId == 137) {

    factoryAddr = "0x00000bf709482cb57980a5959a73bf8b20b81964"

  } else if(network.config.chainId == 80001) {

    factoryAddr = "0x6F9b35651544066b82CdFdd52e79D7DDf5410203"
  }


module.exports = {
  factoryAddr,
}