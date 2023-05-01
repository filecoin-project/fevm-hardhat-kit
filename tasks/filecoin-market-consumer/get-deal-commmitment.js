task(
    "get-deal-commitment",
    "Reads current dealCommitment for deal stored in the contract."
  )
    .addParam("contract", "The address of the FilecoinMarketConsumer contract")
    .setAction(async (taskArgs) => {
        //store taskargs as useable variables
        const contractAddr = taskArgs.contract
        const networkId = network.name
        console.log("Reading DealCommitment from FilecoinMarketAPI on network", networkId)

        //create a new wallet instance
        const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider)

        //create a FilecoinMarketConsumer contract factory
        const FilecoinMarketConsumer = await ethers.getContractFactory("FilecoinMarketConsumer", wallet)
        //create a FilecoinMarketConsumer contract instance 
        //this is what you will call to interact with the deployed contract
        const filecoinMarketConsumer = await FilecoinMarketConsumer.attach(contractAddr)
        
        //read dealCommitment() variable
        result = await filecoinMarketConsumer.dealCommitment()
        console.log("The deal commitment is:", result.data)
    })