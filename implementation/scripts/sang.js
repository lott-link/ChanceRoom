const { ethers, network } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { verify } = require("../../factory/scripts/utils/verifier.js")
let { factoryAddr } = require("../../factory/scripts/utils/config.js")

async function deploySang() {
  const delay = ms => new Promise(res => setTimeout(res, ms));
 
  // deploy implementation
  const Sang = await ethers.getContractFactory("ChanceRoom_Sang");
  const sang = await Sang.deploy(factoryAddr);
  await sang.deployed();
  console.log("Sang addr : ", sang.address);
  await delay(3000)

  await verify(sang.address, [factoryAddr])

  // // add implementation to chanceRoomFactory
  // const chanceRoomFactory = await ethers.getContractAt("ChanceRoomFactory", factoryAddr)
  // await chanceRoomFactory.addImplementation(sang.address);
  // await delay(3000)

  // const implementations = await chanceRoomFactory.getImplementations();
  // console.log("Implementations : ", implementations);

}
deploySang();