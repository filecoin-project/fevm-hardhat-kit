import { task } from "hardhat/config"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import { SimpleCoin } from "../../typechain-types"

task("send-coin", "Sends SimpleCoin")
    .addParam("contract", "The SimpleCoin address")
    .addParam("amount", "The amount to send")
    .addParam("toaccount", "The account to send to")
    .setAction(async (taskArgs, hre: HardhatRuntimeEnvironment) => {
        //store taskargs as useable variables
        const contractAddr = taskArgs.contract
        const amount = taskArgs.amount
        const toAccount = taskArgs.toaccount

        //create a new wallet instance
        const [wallet] = await hre.ethers.getSigners()

        //create a SimpleCoin contract factory
        const SimpleCoin = await hre.ethers.getContractFactory("SimpleCoin", wallet)
        //create a SimpleCoin contract instance
        //this is what you will call to interact with the deployed contract
        const simpleCoinContract = SimpleCoin.attach(contractAddr) as SimpleCoin

        console.log("Sending:", amount, "SimpleCoin to", toAccount)

        //send transaction to call the sendCoin() method
        const transaction = await simpleCoinContract.sendCoin(toAccount, amount)
        await transaction.wait()
        const result = BigInt(await simpleCoinContract.getBalance(toAccount)).toString()
        console.log("Total SimpleCoin at:", toAccount, "is", result)
    })
