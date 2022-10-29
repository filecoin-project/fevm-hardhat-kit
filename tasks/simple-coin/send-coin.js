task("send-coin", "Calls the simple coin Contract to read the amount of SimpleCoins owned by the account.")
  .addParam("contract", "The address the SimpleCoin contract")
  .addParam("to", "The account to transfer to")
  .addParam("amount", "The amount of SimpleCoin you want to send")
  .setAction(async (taskArgs) => {
    const contractAddr = taskArgs.contract
    const amount = taskArgs.amount
    const recievingAccount = taskArgs.to.toString()
    const networkId = network.name
    console.log("Sending", amount, "SimpleCoin on network", networkId)
    const SimpleCoin = await ethers.getContractFactory("SimpleCoin")

    //Get signer information
    const accounts = await ethers.getSigners()
    const signer = accounts[0]

    const simpleCoinContract = new ethers.Contract(contractAddr, SimpleCoin.interface, signer)
    const transactionResponse = await simpleCoinContract.sendCoin(recievingAccount, amount)
    const transactionReceipt = await transactionResponse.wait()
    console.log("Transaction Hash: ", transactionReceipt)
  })

module.exports = {}