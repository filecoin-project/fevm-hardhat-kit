const CID = require("cids")

task("get-deal-id", "Gets a deal proposal from the proposal id")
    .addParam("contract", "The address of the deal client solidity")
    .addParam("cid", "The proposal ID")
    .setAction(async (taskArgs) => {
        const contractAddr = taskArgs.contract
        const cid = taskArgs.cid
        const networkId = network.name
        console.log("Getting deal proposal on network", networkId)

        //create a new wallet instance
        const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider)

        //convert piece CID string to hex bytes
        const cidHexRaw = new CID(cid).toString("base16").substring(1)
        // const cidHex = "0x00" + cidHexRaw
        const cidHex = "0x" + cidHexRaw
        console.log("Hex bytes are:", cidHex)
        console.log("Complete!")

        //create a DealClient contract factory
        const DealClient = await ethers.getContractFactory("DealClient", wallet)
        //create a DealClient contract instance
        //this is what you will call to interact with the deployed contract
        const dealClient = await DealClient.attach(contractAddr)

        //send a transaction to call makeDealProposal() method
        let Cid = new TextEncoder("utf-8").encode(cid)
        let result = await dealClient.getDealId(Cid)
        console.log("The deal ID is:", result)

        let result1 = await dealClient.getDealId(cidHex)
        console.log("The deal ID is:", result1)

        // getPieceStatus
        let getPieceStatus = await dealClient.getPieceStatus(cidHex)
        console.log("The getPieceStatus is:", getPieceStatus)

        // getProviderSet
        let getProviderSet = await dealClient.getProviderSet(cidHex)
        console.log("The ProviderSet is:", getProviderSet)

        // getProposalIdSet
        let getProposalIdSet = await dealClient.getProviderSet(cidHex)
        console.log("The ProposalIdSet is:", getProposalIdSet)

        // dealsLength
        let dealsLength = await dealClient.dealsLength()
        console.log("The dealsLength is:", dealsLength)

        // getDealByIndex
        let getDealByIndex = await dealClient.getDealByIndex(0)
        console.log("The DealByIndex is:", getDealByIndex)
    })

// new TextEncoder("utf-8").encode("BE_0001"),
