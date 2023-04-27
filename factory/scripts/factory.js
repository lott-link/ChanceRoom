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

    // deploy Factory
    const Factory = await ethers.getContractFactory("ChanceRoomFactory");
    const factory = await upgrades.deployProxy(Factory, []);
    await factory.deployed();
    console.log("Factory : ", factory.address);

    await delay(2000)
    await verify(factory.address, [])

    // // upgrade Factory
    // const Factory = await ethers.getContractFactory("ChanceRoomFactory");
    // const factory = await upgrades.upgradeProxy(factoryAddr, Factory);
    // console.log("Factory upgraded");
}
deployFactory();