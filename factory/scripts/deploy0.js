const { ethers, network } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { verify } = require("./utils/verifier.js")

const { wMATIC } = require("./utils/config.js")

// tooye chanceRoomFactory power ro biaram tooye ranking haye opensea bedoone `"` bashe ta value befahme opensea
// status ha ro ham biaram
// chanceroom sang ke avalin chanceroom hast nabayad priceRate ro dashte bashe
// tooye chanceroom hall o timer ezafe she priceRate
// rooye function ha comment bezaram ba @dev ke mesle openzeppelin tooye etherscan info neshon bede
  async function deploy0() {
    const delay = ms => new Promise(res => setTimeout(res, ms));

    console.log(network.config.chainId)

    const hour = 60 * 60;
    const salt = "0x0000000000000000000000000000000000000000000000000000000000000000"
      
    let deployer, user1, user2, user3, user4, user5, user6, user7, user8, user9, user10, user11, user12, user13, user14, user15, user16, user17, user18, user19, user20, user21, user22, user23, user24, user25, user26, user27
    const accounts = await ethers.getSigners();
    [deployer, user1, user2, user3, user4, user5, user6, user7, user8, user9, user10, user11, user12, user13, user14, user15, user16, user17, user18, user19, user20, user21, user22, user23, user24, user25, user26, user27] = accounts

    // deploy ChanceRoomFactory
    const ChanceRoomFactory = await ethers.getContractFactory("ChanceRoomFactory");
    const chanceRoomFactory = await upgrades.deployProxy(ChanceRoomFactory, []);
    console.log("ChanceRoomFactory : ", chanceRoomFactory.address);


    // deploy ChanceRoom_Sang
    const ChanceRoom_Sang = await ethers.getContractFactory("ChanceRoom_Sang");
    const chanceRoom_Sang = await ChanceRoom_Sang.deploy(chanceRoomFactory.address);
    console.log("ChanceRoom_Sang : ", chanceRoom_Sang.address);

    // deploy Template_BlackTicket
    const Template_BlackTicket = await ethers.getContractFactory("Template_BlackTicket");
    const BlackTicket = await Template_BlackTicket.deploy();
    console.log("Template_BlackTicket : ", BlackTicket.address);


    // add implementation ChanceRoom_Sang to ChanceRoomFactory
    await chanceRoomFactory.addImplementation(chanceRoom_Sang.address)
    console.log("implementations : ", await chanceRoomFactory.implNames())

    // add template BlackTicket to ChanceRoomFactory
    await chanceRoomFactory.addTemplate(BlackTicket.address)
    console.log("templates : ", await chanceRoomFactory.tempNames())

    // mint valuable NFT
    const NFT = await ethers.getContractFactory("NFT");
    const nft = await NFT.deploy();
    console.log("valuable NFT : ", nft.address);
    await nft.safeMint(user2.address)
    


    // clone first ChanceRoom
    const clonedAddr = chanceRoomFactory.determineChanceRoomAddr("ChanceRoom_Sang", salt)
    const cloned = await ethers.getContractAt("ChanceRoom_Sang", clonedAddr);
    await chanceRoomFactory.connect(user2).newChanceRoom(
      "ChanceRoom_Sang",   //implName
      salt
    )
    console.log("cloned chanceRoom : ", clonedAddr)

    await nft.connect(user2).approve(clonedAddr, 0)
    await cloned.connect(user2).initialize(
      "BlackTicket", //tempName
      nft.address,   // _nftAddr
      "0",           // _nftId
      "6",           // _maximumTicket
      (10 ** 17).toString(),// _ticketPrice
      "1800000"      // holdingTime
    )
    const activeChanceRooms = await chanceRoomFactory.getChanceRooms()
    console.log("ChanceRooms : ", activeChanceRooms)
    console.log(await cloned.ChanceRoomFactory())

    // const clonedChanceRoom = await ethers.getContractAt("ChanceRoom_Sang", activeChanceRooms[0]);

    // // console.log("clonedChanceRoom : ", clonedChanceRoom.address)
    
    // // first purchase ticket
    // await clonedChanceRoom.connect(user2).purchaseTicket({value : (10 ** 17).toString()})
    // console.log("ticket balance of user2 :", await clonedChanceRoom.balanceOf(user2.address))

    // // log layout() 
    // console.log(await clonedChanceRoom.layout())

    // // first purchase ticket
    // await clonedChanceRoom.connect(user2).purchaseTicket({value : (10 ** 17).toString()})
    // console.log("ticket balance of user2 :", await clonedChanceRoom.balanceOf(user2.address))

    // // second purchase ticket
    // await clonedChanceRoom.connect(user3).purchaseTicket({value : (10 ** 17).toString()})
    // console.log("ticket balance of user3 :", await clonedChanceRoom.balanceOf(user3.address))

    // // third purchase ticket
    // await clonedChanceRoom.connect(user4).purchaseTicket({value : (10 ** 17).toString()})
    // console.log("ticket balance of user4 :", await clonedChanceRoom.balanceOf(user4.address))

    // // 4th purchase ticket
    // await clonedChanceRoom.connect(user5).purchaseTicket({value : (10 ** 17).toString()})
    // console.log("ticket balance of user5 :", await clonedChanceRoom.balanceOf(user5.address))

    // // // 5th purchase ticket
    // // await clonedChanceRoom.connect(user6).purchaseTicket({value : (10 ** 17).toString()})
    // // console.log("ticket balance of user6 :", await clonedChanceRoom.balanceOf(user6.address))

    // const chainId = await clonedChanceRoom.chainId()
    // console.log("chain id : ", chainId)

    // //show tokenURI
    // // console.log("token 1 URI : ", await clonedChanceRoom.tokenURI(1))

    // // // console.log("nft id : ", await clonedChanceRoom.nftid())
    // // await delay(1000)
    // // await time.increase(12000 * hour)


    // // // rolluprrrrrrrrr
    // // // await clonedChanceRoom.rollup(); console.log("chance room rolledup");
    // // await clonedChanceRoom.refund(); console.log("chance room refunded");

    // console.log("token 2 URI : ", await clonedChanceRoom.tokenURI(1))

    const id0 = await chanceRoomFactory.tokenByIndex(0);

    console.log(await chanceRoomFactory.tokenURI(id0));

  }

  deploy0();