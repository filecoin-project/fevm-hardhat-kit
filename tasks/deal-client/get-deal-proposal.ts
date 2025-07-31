import { task } from "hardhat/config"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import { DealClient } from "../../typechain-types"

task("get-deal-proposal", "Gets a deal proposal from the proposal id")
    .addParam("contract", "The address of the deal client solidity")
    .addParam("proposalId", "The proposal ID")
    .setAction(async (taskArgs, hre: HardhatRuntimeEnvironment) => {
        const contractAddr = taskArgs.contract
        const proposalID = taskArgs.proposalId
        const networkId = hre.network.name
        console.log("Getting deal proposal on network", networkId)

        //create a new wallet instance
        const [wallet] = await hre.ethers.getSigners()

        //create a DealClient contract factory
        const DealClient = await hre.ethers.getContractFactory("DealClient", wallet)
        //create a DealClient contract instance
        //this is what you will call to interact with the deployed contract
        const dealClient = DealClient.attach(contractAddr) as DealClient

        //send a transaction to call makeDealProposal() method
        //transaction = await dealClient.getDealProposal(proposalID)
        let result = await dealClient.getDealProposal(proposalID)
        console.log("The deal proposal is:", result)
    })
