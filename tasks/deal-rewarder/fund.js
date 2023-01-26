task(
    "fund",
    "Sends 1 FIL to bounty contract."
  )
    .addParam("contract", "The address of the DealRewarder contract")
    .setAction(async (taskArgs) => {
        const contractAddr = taskArgs.contract
        const networkId = network.name
        console.log("Sending 1 FIL to DealRewarder contract on network", networkId)

        //create a new wallet instance
        const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider)

        //create a FilecoinMarketConsumer contract factory
        const DealRewarder = await ethers.getContractFactory("DealRewarder", wallet)
        //create a DealRewarder contract instance 
        //this is what you will call to interact with the deployed contract
        const dealRewarder = await DealRewarder.attach(contractAddr)

        //send a transaction to call fund() method
        transaction = await dealRewarder.fund(0, {
          value: ethers.utils.parseEther("1")    
        })
        transaction.wait()
        console.log("Complete!")
    })