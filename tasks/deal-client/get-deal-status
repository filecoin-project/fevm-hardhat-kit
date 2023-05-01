const CID = require('cids')

task(
    "get-deal-status",
    "Gets a deal's status from the piece cid"
  )
    .addParam("contract", "The address of the deal client solidity")
    .addParam("pieceCid", "The piece CID of the deal you want the status of")
    .setAction(async (taskArgs) => {
        const contractAddr = taskArgs.contract
        const cid = taskArgs.pieceCid
        const cidHexRaw = new CID(cid).toString('base16').substring(1)
        const cidHex = "0x" + cidHexRaw
        const networkId = network.name
        console.log("Getting deal status on network", networkId)

        //create a new wallet instance
        const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider)
        
        //create a DealClient contract factory
        const DealClient = await ethers.getContractFactory("DealClient", wallet)
        //create a DealClient contract instance 
        //this is what you will call to interact with the deployed contract
        const dealClient = await DealClient.attach(contractAddr)
          
        //send a transaction to call makeDealProposal() method
        //transaction = await dealClient.getDealProposal(proposalID)
        let result = await dealClient.pieceStatus(cidHex)
        console.log("The deal status is:", result)
    })