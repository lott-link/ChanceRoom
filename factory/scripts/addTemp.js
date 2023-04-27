const { ethers, network } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { verify } = require("./utils/verifier.js")
let { factoryAddr } = require("./utils/cont.config.js")

async function deployBTicket() {
  const delay = ms => new Promise(res => setTimeout(res, ms));
 
  // add implementation to Factory
  const Factory = await ethers.getContractAt("ChanceRoomFactory", factoryAddr)
  await Factory.addTemplate("0x505648d960e7E3989d4E42Fe8cAc8bD47c8F3706");
  await delay(3000)

  const templates = await Factory.getTemplates();
  console.log("templates : ", templates);

}
deployBTicket();