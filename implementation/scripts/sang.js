const { ethers, network } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { verify } = require("../../factory/scripts/utils/verifier.js")
let { factoryAddr } = require("../../factory/scripts/utils/cont.config.js")

async function deploySang() {
  const delay = ms => new Promise(res => setTimeout(res, ms));
 
  // // deploy implementation
  // const Sang = await ethers.getContractFactory("ChanceRoom_Sang");
  // const sang = await Sang.deploy(factoryAddr);
  // await sang.deployed();
  // console.log("Sang addr : ", sang.address);
  // await delay(3000)

  // await verify("0x3c993Bdc24e242fF19c6d12CBeC321bd7eDcEdf8", [factoryAddr])

}
deploySang();