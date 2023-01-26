task("send-coin", "Sends SimpleCoin")
.addParam("contract", "The SimpleCoin address")
.addParam("amount", "The amount to send")
.addParam("toaccount", "The account to send to")
.setAction(async (taskArgs) => {
    //store taskargs as useable variables
    const contractAddr = taskArgs.contract
    const amount = taskArgs.amount
    const toAccount = taskArgs.toaccount

    //create a new wallet instance
    const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider)

    //create a SimpleCoin contract factory
    const SimpleCoin = await ethers.getContractFactory("SimpleCoin", wallet)
    //create a SimpleCoin contract instance 
    //This is what we will call to interact with the contract
    const simpleCoinContract = await SimpleCoin.attach(contractAddr)

    console.log("Sending:", amount, "SimpleCoin to", toAccount)

    //call the sendCoin function in the SimpleCoin contract
    const transaction = await simpleCoinContract.sendCoin(toAccount, amount)
    const receipt = await transaction.wait()
    let result = BigInt(await simpleCoinContract.getBalance(toAccount)).toString()
    console.log("Total SimpleCoin at:", toAccount, "is", result)
})