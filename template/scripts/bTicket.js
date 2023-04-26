const { ethers, network } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { verify } = require("../../factory/scripts/utils/verifier.js")
let { factoryAddr } = require("../../factory/scripts/utils/config.js")

async function deployBTicket() {
  const delay = ms => new Promise(res => setTimeout(res, ms));
 
  // deploy implementation
  const Template_BlackTicket = await ethers.getContractFactory("Template_BlackTicket");
  const BlackTicket = await Template_BlackTicket.deploy();
  await BlackTicket.deployed();
  console.log("Template_BlackTicket addr : ", BlackTicket.address);
  await delay(3000)

  await verify(BlackTicket.address, [])

  // add implementation to chanceRoomFactory
  const chanceRoomFactory = await ethers.getContractAt("ChanceRoomFactory", factoryAddr)
  await chanceRoomFactory.addTemplate(BlackTicket.address);
  await delay(3000)

  const templates = await chanceRoomFactory.getTemplates();
  console.log("templates : ", templates);

}
deployBTicket();