const { ethers, network } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { verify } = require("./utils/verifier.js")
let { factoryAddr } = require("./utils/cont.config.js")

async function deploySang() {
  const delay = ms => new Promise(res => setTimeout(res, ms));
 
  // add implementation to Factory
  const Factory = await ethers.getContractAt("ChanceRoomFactory", factoryAddr)
  await Factory.addImplementation("0xA6b2De728eF6137C306C2cA22b033B08deC94a5b");
  await delay(3000)

  const implementations = await Factory.implNames();
  console.log("Implementations : ", implementations);
}
deploySang();