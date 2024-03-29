const { ethers, network } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { verify } = require("../../factory/scripts/utils/verifier.js")
const { deployFee } = require("./utils/gasEstimate.js")
let { factoryAddr, swapBurnerAddr } = require("./utils/cont.config.js")

async function deploySang() {
  const delay = ms => new Promise(res => setTimeout(res, ms));

  // await deployFee("ChanceRoom_Sang", factoryAddr, swapBurnerAddr)
 
  // deploy implementation
  const Sang = await ethers.getContractFactory("ChanceRoom_Sang");
  const sang = await Sang.deploy(factoryAddr, swapBurnerAddr);
  console.log("deploy request sent...");
  await sang.deployed();
  console.log("Sang addr : ", sang.address);
  await delay(20000)

  await verify(sang.address, [factoryAddr, swapBurnerAddr])

}
deploySang();