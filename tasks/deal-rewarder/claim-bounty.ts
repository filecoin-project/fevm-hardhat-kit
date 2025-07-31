import { task } from "hardhat/config"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import { DealRewarder } from "../../typechain-types"

task("claim-bounty", "Sends 1 FIL to a whomever the client on the bountied deal is.")
    .addParam("contract", "The address of the DealRewarder contract")
    .addParam("dealid", "The id of the deal with the completed bounty")
    .setAction(async (taskArgs, hre: HardhatRuntimeEnvironment) => {
        //store taskargs as useable variables
        const contractAddr = taskArgs.contract
        const dealid = taskArgs.dealid
        const networkId = hre.network.name
        console.log("Claiming Bounty on network", networkId)

        //create a new wallet instance
        const [wallet] = await hre.ethers.getSigners()

        //create a DealRewarder contract factory
        const DealRewarder = await hre.ethers.getContractFactory("DealRewarder", wallet)
        //create a DealRewarder contract instance
        //this is what you will call to interact with the deployed contract
        const dealRewarder = DealRewarder.attach(contractAddr) as DealRewarder

        //send a transaction to call claim_bounty() method
        const transaction = await dealRewarder.claim_bounty(dealid)
        transaction.wait()
        console.log("Complete!")
    })
