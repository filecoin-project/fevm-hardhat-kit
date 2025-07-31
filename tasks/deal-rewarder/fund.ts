import { task } from "hardhat/config"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import { parseEther } from "ethers"
import { DealRewarder } from "../../typechain-types"

task("fund", "Sends 1 FIL to bounty contract.")
    .addParam("contract", "The address of the DealRewarder contract")
    .setAction(async (taskArgs, hre: HardhatRuntimeEnvironment) => {
        const contractAddr = taskArgs.contract
        const networkId = hre.network.name
        console.log("Sending 1 FIL to DealRewarder contract on network", networkId)

        //create a new wallet instance
        const [wallet] = await hre.ethers.getSigners()

        //create a FilecoinMarketConsumer contract factory
        const DealRewarder = await hre.ethers.getContractFactory("DealRewarder", wallet)
        //create a DealRewarder contract instance
        //this is what you will call to interact with the deployed contract
        const dealRewarder = DealRewarder.attach(contractAddr) as DealRewarder

        //send a transaction to call fund() method
        const transaction = await dealRewarder.fund(0, {
            value: parseEther("1"),
        })
        await transaction.wait()
        console.log("Complete!")
    })
