const { ethers, network } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { verify } = require("./utils/verifier.js")
let { factoryAddr } = require("./utils/cont.config.js")

async function deployBTicket() {
  const delay = ms => new Promise(res => setTimeout(res, ms));
 
  // add implementation to Factory
  const Factory = await ethers.getContractAt("ChanceRoomFactory", factoryAddr)
  await Factory.addTemplate("0x3D2E923504574a412a2B041DCBD7268C16d50298");
  await delay(3000)

  const templates = await Factory.tempNames();
  console.log("templates : ", templates);

}
deployBTicket();