const { ethers, network } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { verify } = require("./utils/verifier.js")

async function deployBTicket() {
  const delay = ms => new Promise(res => setTimeout(res, ms));
 
  // deploy implementation
  const Template_BlackTicket = await ethers.getContractFactory("Template_BlackTicket");
  const BlackTicket = await Template_BlackTicket.deploy();
  await BlackTicket.deployed();
  console.log("Template_BlackTicket addr : ", BlackTicket.address);

  await delay(10000)
  await verify(BlackTicket.address, [])

}
deployBTicket();