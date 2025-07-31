import { task } from "hardhat/config"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import CID from "cids"
import { DealClient } from "../../typechain-types"

task("get-deal-status", "Gets a deal's status from the piece cid")
    .addParam("contract", "The address of the deal client solidity")
    .addParam("pieceCid", "The piece CID of the deal you want the status of")
    .setAction(async (taskArgs, hre: HardhatRuntimeEnvironment) => {
        const contractAddr = taskArgs.contract
        const cid = taskArgs.pieceCid
        const cidHexRaw = new CID(cid).toString("base16").substring(1)
        const cidHex = "0x" + cidHexRaw
        const networkId = hre.network.name
        console.log("Getting deal status on network", networkId)

        //create a new wallet instance
        const [wallet] = await hre.ethers.getSigners()

        //create a DealClient contract factory
        const DealClient = await hre.ethers.getContractFactory("DealClient", wallet)
        //create a DealClient contract instance
        //this is what you will call to interact with the deployed contract
        const dealClient = DealClient.attach(contractAddr) as DealClient

        //send a transaction to call makeDealProposal() method
        //transaction = await dealClient.getDealProposal(proposalID)
        let result = await dealClient.pieceStatus(cidHex)
        console.log("The deal status is:", result)
    })
