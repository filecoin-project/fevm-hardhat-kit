task(
  "get-balance",
  "Calls the SimpleCoin contract to read the amount of SimpleCoins owned by the account."
)
  .addParam("contract", "The address the SimpleCoin contract")
  .addParam("account", "The address of the account you want the balance for")
  .setAction(async (taskArgs) => {
      //store taskargs as useable variables
      const contractAddr = taskArgs.contract
      const account = taskArgs.account
      const networkId = network.name
      console.log("Reading SimpleCoin owned by", account, "on network", networkId)
      
      //create a new wallet instance
      const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider)

      //create a SimpleCoin contract factory
      const SimpleCoin = await ethers.getContractFactory("SimpleCoin", wallet)
      //Create a SimpleCoin contract instance 
      //This is what we will call to interact with the contract
      const simpleCoinContract = await SimpleCoin.attach(contractAddr)
       
      //Call the getBalance method
      let result = BigInt(await simpleCoinContract.getBalance(account)).toString()
      console.log("Amount of Simplecoin owned by", account, "is", result)
      let mintedToken = await simpleCoinContract.getMintedTokenBalance()
      console.log(`Total amount of minted tokens is ${mintedToken}`)
  })
