task(
    "store-all",
    "Calls getter functions in the Filecoin Market API to store data from a specific deal."
  )
    .addParam("contract", "The address of the FilecoinMarketConsumer contract")
    .addParam("dealid", "The id of the deal who's data you want to store")
    .setAction(async (taskArgs) => {
        //store taskargs as useable variables
        const contractAddr = taskArgs.contract
        const dealID = taskArgs.dealid
        const networkId = network.name
        console.log("Storing data from FilecoinMarketAPI getter functions on network", networkId)

        //create a new wallet instance
        const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider)

        //create a FilecoinMarketConsumer contract factory
        const FilecoinMarketConsumer = await ethers.getContractFactory("FilecoinMarketConsumer", wallet)
        //create a FilecoinMarketConsumer contract instance 
        //this is what you will call to interact with the deployed contract
        const filecoinMarketConsumer = await FilecoinMarketConsumer.attach(contractAddr)
        
        //send transaction to call storeAll() method
        transaction = await filecoinMarketConsumer.storeAll(dealID)
        const receipt = await transaction.wait()
        console.log("Complete!")
    })