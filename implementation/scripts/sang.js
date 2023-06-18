const { ethers, network } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { verify } = require("../../factory/scripts/utils/verifier.js")
const { deployFee } = require("./utils/gasEstimate.js")
let { factoryAddr } = require("../../factory/scripts/utils/cont.config.js")

async function deploySang() {
  const delay = ms => new Promise(res => setTimeout(res, ms));

  // await deployFee("ChanceRoom_Sang")
 
  // // deploy implementation
  // const Sang = await ethers.getContractFactory("ChanceRoom_Sang");
  // const sang = await Sang.deploy(factoryAddr);
  // await sang.deployed();
  // console.log("Sang addr : ", sang.address);
  // await delay(20000)

  await verify("0xB02C0Ba0A628ca40F8658f72fF8C9d69B76C3a6B", [factoryAddr])

}
deploySang();