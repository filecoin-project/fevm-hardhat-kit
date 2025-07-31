import { task } from "hardhat/config"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import { FilecoinMarketConsumer } from "../../typechain-types"

task(
    "store-all",
    "Calls getter functions in the Filecoin Market API to store data from a specific deal."
)
    .addParam("contract", "The address of the FilecoinMarketConsumer contract")
    .addParam("dealid", "The id of the deal who's data you want to store")
    .setAction(async (taskArgs, hre: HardhatRuntimeEnvironment) => {
        //store taskargs as useable variables
        const contractAddr = taskArgs.contract
        const dealID = taskArgs.dealid
        const networkId = hre.network.name
        console.log("Storing data from FilecoinMarketAPI getter functions on network", networkId)

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

        //send transaction to call storeAll() method
        const transaction = await filecoinMarketConsumer.storeAll(dealID)
        await transaction.wait()
        console.log("Complete!")
    })
