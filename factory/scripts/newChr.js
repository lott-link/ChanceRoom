
    // clone first ChanceRoom
    const clonedAddr = chanceRoomFactory.determineChanceRoomAddr("Sang", salt)
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
