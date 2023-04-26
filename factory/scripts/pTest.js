const { ethers, network } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { verify } = require("./utils/verifier.js")


async function test() {
    
    const Power = await ethers.getContractFactory("Power");
    const power = await Power.deploy()
    await power.deployed();

    console.log(await power.power("0x0000000a6423B034aed4AbC0e8f4E334e555CD76"))
}
test()