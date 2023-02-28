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
        const contractAddr = taskArgs.contract
        const cid = taskArgs.pieceCid
        const pieceSize = taskArgs.pieceSize
        const verifiedDeal = taskArgs.verifiedDeal
        const label = taskArgs.label
        const startepoch = taskArgs.startEpoch
        const endepoch = taskArgs.endEpoch
        const pricePerEpoch = taskArgs.storagePricePerEpoch
        const providerCollateral = taskArgs.providerCollateral
        const clientCollateral = taskArgs.clientCollateral 
        const extraParamsVersion = taskArgs.extraParamsVersion
        const extraParams = {
            locationRef: taskArgs.locationRef,
            carSize: taskArgs.carSize,
            skipIpniAnnounce: taskArgs.skipIpniAnnounce,
            removeUnsealedCopy: taskArgs.removeUnsealedCopy
        }
        const networkId = network.name
        console.log("Making deal proposal on network", networkId)

        //create a new wallet instance
        const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider)
        
        //create a DealClient contract factory
        const DealClient = await ethers.getContractFactory("DealClient", wallet)
        //create a DealClient contract instance 
        //this is what you will call to interact with the deployed contract
        const dealClient = await DealClient.attach(contractAddr)
        
        //convert piece CID string to hex bytes
        const cidHexRaw = new CID(cid).toString('base16').substring(1)
        const cidHex = "0x00" + cidHexRaw
        
        //send a transaction to call makeDealProposal() method
        transaction = await dealClient.makeDealProposal(
            cidHex, 
            pieceSize,
            verifiedDeal,
            label,
            startepoch,
            endepoch,
            pricePerEpoch,
            providerCollateral,
            clientCollateral,
            extraParamsVersion,
            extraParams
            )
        transaction.wait()
       
        console.log("Complete! Event CreateDealProposal will now be emitted")
        console.log("Listening for event CreateDealProposal")

        //listen for DealProposalCreate event
        ethers.provider.on(DealProposalCreate, () => {
            console.log("Event DealPropsoalCreate emmited on network", networkId)
        })
    })