const { ethers, network } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { verify } = require("./utils/verifier.js")
let { factoryAddr } = require("./utils/cont.config.js")

async function deploySang() {
  const delay = ms => new Promise(res => setTimeout(res, ms));
 
  // add implementation to Factory
  const Factory = await ethers.getContractAt("ChanceRoomFactory", factoryAddr)
  await Factory.addImplementation("0x312964111d4a2d61e0Ffee1E6dc1Cc027C23FA6C");
  await delay(3000)

  const implementations = await Factory.getImplementations();
  console.log("Implementations : ", implementations);
}
deploySang();