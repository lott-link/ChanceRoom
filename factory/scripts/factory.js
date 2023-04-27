const { ethers, upgrades, network } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { verify } = require("./utils/verifier.js")

let { factoryAddr } = require("./utils/cont.config.js")

// ye joori az chanceroom be version e implementation beresim
// har chanceroom tabdil be ye ERC721Enumeralble beshe
// id e har chanceroom uint256(uint160(chanceroomAddress)) bashe
//
async function deployFactory() {
    const delay = ms => new Promise(res => setTimeout(res, ms));

    // deploy ChanceRoomFactory
    const ChanceRoomFactory = await ethers.getContractFactory("ChanceRoomFactory");
    const chanceRoomFactory = await upgrades.deployProxy(ChanceRoomFactory, []);
    await chanceRoomFactory.deployed();
    console.log("ChanceRoomFactory : ", chanceRoomFactory.address);

    await delay(2000)
    await verify(chanceRoomFactory.address, [])

    // // upgrade ChanceRoomFactory
    // const ChanceRoomFactory = await ethers.getContractFactory("ChanceRoomFactory");
    // const chanceRoomFactory = await upgrades.upgradeProxy(factoryAddr, ChanceRoomFactory);
    // console.log("ChanceRoomFactory upgraded");
}
deployFactory();