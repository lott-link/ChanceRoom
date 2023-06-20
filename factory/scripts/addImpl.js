const { ethers, network } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { verify } = require("./utils/verifier.js")
let { factoryAddr } = require("./utils/cont.config.js")

async function deploySang() {
  const delay = ms => new Promise(res => setTimeout(res, ms));
 
  // add implementation to Factory
  const Factory = await ethers.getContractAt("ChanceRoomFactory", factoryAddr)
  await Factory.addImplementation("0x6a61731c003Ec3fc46e5Ebc5BFc7b2a121a8D9dC");
  await delay(3000)

  const implementations = await Factory.implNames();
  console.log("Implementations : ", implementations);
}
deploySang();