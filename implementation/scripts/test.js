/* global describe it before ethers */

const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { assert, expect } = require('chai')


describe('sang test', async function () {

    const hour = 60 * 60;
    let zero_address
    let deployer, user1, user2, user3, user4, user5, user6, user7, user8, user9, user10
    let sang

    before(async function () {
        zero_address = "0x0000000000000000000000000000000000000000"
        const accounts = await ethers.getSigners();
        [deployer, user1, user2, user3, user4, user5, user6, user7, user8, user9, user10] = accounts
    }) 

    it('should deploy contract without any Errors', async () => {
        const Sang = await ethers.getContractFactory("ChanceRoom_Sang");
        sang = await Sang.deploy(zero_address);
        await sang.deployed();
        console.log("Sang addr : ", sang.address);
    })
    
    
})