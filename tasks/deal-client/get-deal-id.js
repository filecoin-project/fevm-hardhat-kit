task("get-deal-id", "Gets a deal proposal from the proposal id")
    .addParam("contract", "The address of the deal client solidity")
    .addParam("cid", "The proposal ID")
    .setAction(async (taskArgs) => {
        const contractAddr = taskArgs.contract
        console.log("working")
        const cid = taskArgs.cid
        console.log("working")
        const networkId = network.name
        console.log("Getting deal proposal on network", networkId)

        //create a new wallet instance
        const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider)

        //create a DealClient contract factory
        const DealClient = await ethers.getContractFactory("DealClient", wallet)
        //create a DealClient contract instance
        //this is what you will call to interact with the deployed contract
        const dealClient = await DealClient.attach(contractAddr)

        //send a transaction to call makeDealProposal() method
        let Cid = new TextEncoder("utf-8").encode(cid)
        let result = await dealClient.getDealId(Cid)
        console.log("The deal ID is:", result)

        let result1 = await dealClient.getDealId(
            "0x0001701220a08ffd458e5cc5a24281b27e5cce6fea7112d9364120bc6e8cf36ee8233cc417"
        )
        console.log("The deal ID is:", result1)

        // getPieceStatus
        let getPieceStatus = await dealClient.getPieceStatus(
            "0x0001701220a08ffd458e5cc5a24281b27e5cce6fea7112d9364120bc6e8cf36ee8233cc417"
        )
        console.log("The getPieceStatus is:", getPieceStatus)

        // getProviderSet
        let getProviderSet = await dealClient.getProviderSet(
            "0x0001701220a08ffd458e5cc5a24281b27e5cce6fea7112d9364120bc6e8cf36ee8233cc417"
        )
        console.log("The ProviderSet is:", getProviderSet)

        // getProposalIdSet
        let getProposalIdSet = await dealClient.getProviderSet(
            "0x0001701220a08ffd458e5cc5a24281b27e5cce6fea7112d9364120bc6e8cf36ee8233cc417"
        )
        console.log("The ProposalIdSet is:", getProposalIdSet)

        // dealsLength
        let dealsLength = await dealClient.dealsLength()
        console.log("The dealsLength is:", dealsLength)

        // getDealByIndex
        let getDealByIndex = await dealClient.getDealByIndex(0)
        console.log("The DealByIndex is:", getDealByIndex)

        // let result1 = await dealClient.getDealId(cid)
        // console.log("The deal ID is:", result1)
    })

// new TextEncoder("utf-8").encode("BE_0001"),
