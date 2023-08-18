task(
  "owner-of",
  "Calls the GameItem contract to read the owner of a token id."
)
  .addParam("contract", "The address the GameItem contract")
  .addParam("account", "The address of the account you want to verify ownership of the token id")
  .addParam("id", "The token id of the NFT")
  .setAction(async (taskArgs) => {
      //store taskargs as useable variables
      const contractAddr = taskArgs.contract
      const account = taskArgs.account
      const id = taskArgs.id
      const networkId = network.name
      console.log("Reading GameItem owned by", account, "on network", networkId)
      
      //create a new wallet instance
      const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider)

      //create a GameItem contract factory
      const GameItem = await ethers.getContractFactory("GameItem", wallet)
      //Create a GameItem contract instance 
      //This is what we will call to interact with the contract
      const gameItem = await GameItem.attach(contractAddr)
       
      //Call the ownerOf method
      let result = (await gameItem.ownerOf(id)).toString()
      console.log("Owner of token id ", id, "is", result)
      // let mintedToken = await simpleCoinContract.getMintedTokenBalance()
      // console.log(`Total amount of minted tokens is ${mintedToken}`)
  })
