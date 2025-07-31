import { task } from "hardhat/config"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import { FilecoinMarketConsumer } from "../../typechain-types"

task("get-deal-commitment", "Reads current dealCommitment for deal stored in the contract.")
    .addParam("contract", "The address of the FilecoinMarketConsumer contract")
    .setAction(async (taskArgs, hre: HardhatRuntimeEnvironment) => {
        //store taskargs as useable variables
        const contractAddr = taskArgs.contract
        const networkId = hre.network.name
        console.log("Reading DealCommitment from FilecoinMarketAPI on network", networkId)

        //create a new wallet instance
        const [wallet] = await hre.ethers.getSigners()

        //create a FilecoinMarketConsumer contract factory
        const FilecoinMarketConsumer = await hre.ethers.getContractFactory(
            "FilecoinMarketConsumer",
            wallet
        )
        //create a FilecoinMarketConsumer contract instance
        //this is what you will call to interact with the deployed contract
        const filecoinMarketConsumer = FilecoinMarketConsumer.attach(
            contractAddr
        ) as FilecoinMarketConsumer

        //read dealCommitment() variable
        const result = await filecoinMarketConsumer.dealCommitment()
        console.log("The deal commitment is:", result.data)
    })
