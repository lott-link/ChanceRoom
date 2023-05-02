const { ethers, network } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { verify } = require("./utils/verifier.js")
let { factoryAddr } = require("./utils/cont.config.js")

async function deploySang() {
  const delay = ms => new Promise(res => setTimeout(res, ms));
 
  // add implementation to Factory
  const Factory = await ethers.getContractAt("ChanceRoomFactory", factoryAddr)
  await Factory.addImplementation("0xcd60550caE995a4a15d7d05F1E8a75B2Ff083b35");
  await delay(3000)

  const implementations = await Factory.implNames();
  console.log("Implementations : ", implementations);
}
deploySang();