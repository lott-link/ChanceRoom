const { ethers, network } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { verify } = require("./utils/verifier.js")
let { factoryAddr } = require("./utils/cont.config.js")

async function deployBTicket() {
  const delay = ms => new Promise(res => setTimeout(res, ms));
 
  // add implementation to Factory
  const Factory = await ethers.getContractAt("ChanceRoomFactory", factoryAddr)
  await Factory.addTemplate("0xcB2A123c6Faf001329d9e72CdFF8d271055E38ca");
  await delay(10000)

  const templates = await Factory.tempNames();
  console.log("templates : ", templates);

}
deployBTicket();