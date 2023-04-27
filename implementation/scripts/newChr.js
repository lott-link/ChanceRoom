const { ethers, network } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { verify } = require("../../factory/scripts/utils/verifier.js")
let { factoryAddr } = require("../../factory/scripts/utils/cont.config.js")

async function newChr() {
    // // clone first ChanceRoom
    // const clonedAddr = chanceRoomFactory.determineChanceRoomAddr("Sang", salt)
    // const cloned = await ethers.getContractAt("ChanceRoom_Sang", clonedAddr);
    // await chanceRoomFactory.connect(user2).newChanceRoom(
    //   "ChanceRoom_Sang",   //implName
    //   salt
    // )
    // console.log("cloned chanceRoom : ", clonedAddr)

    const nft = await ethers.getContractAt("NFT", "0x4316773d8a9f366f3ae53419000188b3979360c2") 
    const cloned = await ethers.getContractAt("ChanceRoom_Sang", "0x000695fcef03425f3a05e085917ce1da034b3a0b")

    // await nft.approve("0x000695fcef03425f3a05e085917ce1da034b3a0b", 3)
    // console.log("approved")
    await cloned.initialize(
      "BlackTicket", //tempName
      nft.address,   // _nftAddr
      "3",           // _nftId
      "6",           // _maximumTicket
      (10 ** 17).toString(),// _ticketPrice
      "1800000"      // holdingTime
    )

  }
newChr();