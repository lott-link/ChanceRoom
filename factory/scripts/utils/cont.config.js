const { network } = require("hardhat");

const zero_address = "0x0000000000000000000000000000000000000000"

let factoryAddr = zero_address

  if(network.config.chainId == 137) {

    factoryAddr = "0x00000bf709482cb57980a5959a73bf8b20b81964"

  } else if(network.config.chainId == 80001) {

    factoryAddr = "0xE5B7f20C2eCCe895f4F6177073f7982451b2E211"
  }


module.exports = {
  factoryAddr,
}