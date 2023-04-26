const { ethers, network } = require("hardhat");
const { time } = require("@nomicfoundation/hardhat-network-helpers");
const { verify } = require("./utils/verifier.js")


async function test() {

    const AddressTest = await ethers.getContractFactory("AddressTest");
    const addr = await upgrades.deployProxy(AddressTest, []);
    // console.log("AddressTest : ", addr.address);


    console.log(await addr.uin160("0x000000ffffffffffffffffffffffffffffffffff"))
    console.log(await addr.uin160("0x0000010000000000000000000000000000000000"))
    
    console.log(await addr.test("0x0000000fffffffffffffffffffffffffffffffff"))
    console.log(await addr.test("0x000000ffffffffffffffffffffffffffffffffff"))
    console.log(await addr.test("0x00000fffffffffffffffffffffffffffffffffff"))
    console.log(await addr.test("0x0003968a6423B034aed4AbC0e8f4E334e555CD76"))
}
test()