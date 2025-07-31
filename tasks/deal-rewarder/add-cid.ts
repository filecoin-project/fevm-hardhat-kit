import { task } from "hardhat/config"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import CID from "cids"
import { DealRewarder } from "../../typechain-types"

task("add-cid", "Adds a CID (piece CID) of data that you would like to put a storage bounty on.")
    .addParam("contract", "The address of the DealRewarder contract")
    .addParam("piececid", "The piece CID of the data you want to put up a bounty for")
    .addParam("size", "Size of the data you are putting a bounty on")
    .setAction(async (taskArgs, hre: HardhatRuntimeEnvironment) => {
        //store taskargs as useable variables
        const contractAddr = taskArgs.contract
        const cid = taskArgs.piececid
        const size = taskArgs.size
        const networkId = hre.network.name
        console.log("Adding CID", cid, "as a bounty on network", networkId)

        //create a new wallet instance
        const [wallet] = await hre.ethers.getSigners()

        //create a DealRewarder contract factory
        const DealRewarder = await hre.ethers.getContractFactory("DealRewarder", wallet)
        //create a DealRewarder contract instance
        //this is what you will call to interact with the deployed contract
        const dealRewarder = DealRewarder.attach(contractAddr) as DealRewarder

        //convert piece CID string to hex bytes
        const cidHexRaw = new CID(cid).toString("base16").substring(1)
        const cidHex = "0x00" + cidHexRaw
        console.log("Hex bytes are:", cidHex)

        //send a transaction to call addCID() method
        const transaction = await dealRewarder.addCID(cidHex, size)
        await transaction.wait()

        console.log("Complete!")
    })
