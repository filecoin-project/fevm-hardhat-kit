const CID = require('cids')

task(
    "make-deal-proposal",
    "Makes a deal proposal via the client contract. This will ultimately emit an event that storage providers can listen too and choose to accept your deal."
  )
    .addParam("contract", "The address of the deal client solidity")
    .addParam("pieceCid", "The address of the DealRewarder contract")
    .addParam("pieceSize", "The piece CID of the data you want to put up a bounty for")
    .addParam("verifiedDeal", "Size of the data you are putting a bounty on")
    .addParam("label", "The deal label (typically the raw cid)")
    .addParam("startEpoch", "The epoch the deal will start")
    .addParam("endEpoch", "The epoch the deal will end")
    .addParam("storagePricePerEpoch", "The cost of the deal, in FIL, per epoch")
    .addParam("providerCollateral", "The collateral, in FIL, to be put up by the storage provider")
    .addParam("clientCollateral", "The collateral, in FIL, to be put up by the the client (which is you)")
    .addParam("extraParamsVersion", "")
    .addParam("locationRef", "Where the data you want to be stored is located")
    .addParam("carSize", "The size of the .car file")
    .addParam("skipIpniAnnounce", "")
    .addParam("removeUnsealedCopy", "")
    .setAction(async (taskArgs) => {
        //store taskargs as useable variables
        //convert piece CID string to hex bytes
        const cid = taskArgs.pieceCid
        const cidHexRaw = new CID(cid).toString('base16').substring(1)
        const cidHex = "0x" + cidHexRaw
        const contractAddr = taskArgs.contract

        const verified = (taskArgs.verifiedDeal === 'true')
        const skipIpniAnnounce = (taskArgs.skipIpniAnnounce === 'true')
        const removeUnsealedCopy = (taskArgs.removeUnsealedCopy === 'true')

        const extraParamsV1 = [
            taskArgs.locationRef,
            taskArgs.carSize,
            skipIpniAnnounce,
            removeUnsealedCopy,
        ]

        const DealRequestStruct = [
        cidHex,
        taskArgs.pieceSize,
        verified,
        taskArgs.label,
        taskArgs.startEpoch,
        taskArgs.endEpoch,
        taskArgs.storagePricePerEpoch,
        taskArgs.providerCollateral,
        taskArgs.clientCollateral, 
        taskArgs.extraParamsVersion,
        extraParamsV1,
        ]
        const networkId = network.name
        console.log("Making deal proposal on network", networkId)

        //create a new wallet instance
        const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider)
        
        //create a DealClient contract factory
        const DealClient = await ethers.getContractFactory("DealClient", wallet)
        //create a DealClient contract instance 
        //this is what you will call to interact with the deployed contract
        const dealClient = await DealClient.attach(contractAddr)
        
        //send a transaction to call makeDealProposal() method
        transaction = await dealClient.makeDealProposal(DealRequestStruct)
        transactionReceipt = await transaction.wait()

        //listen for DealProposalCreate event
        const event = transactionReceipt.events[0].topics[0]
        console.log("Complete! Event Emitted. ProposalId is:", event)
    })