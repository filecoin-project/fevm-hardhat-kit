task("award-item", "Awards item to player address")
.addParam("contract", "The GameItem address")
.addParam("player", "The player address to send the NFT")
.addParam("metadata", "The metadata for the NFT")
.setAction(async (taskArgs) => {
    //store taskargs as useable variables
    const contractAddr = taskArgs.contract
    const player = taskArgs.player
    const metadata = taskArgs.metadata

    //create a new wallet instance
    const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider)

    //create a GameItem contract factory
    const GameItem = await ethers.getContractFactory("GameItem", wallet)
    //create a GameItem contract instance 
    //this is what you will call to interact with the deployed contract
    const gameItemContract = await GameItem.attach(contractAddr)

    console.log("Sending NFT to ", player)

    //send transaction to call the awardItem() method
    const transaction = await gameItemContract.awardItem(player, metadata)
    const receipt = await transaction.wait()

    // Parse the receipt to get the events
    const event = receipt.events.filter((x) => {return x.event == "Transfer"});

    const givenAddress = event[0].args.to;
    const tokenId = event[0].args.tokenId;

    // let result = BigInt(await gameItemContract.getBalance(toAccount)).toString()
    console.log("NFT token id ", tokenId, " awarded to: ", givenAddress)
})