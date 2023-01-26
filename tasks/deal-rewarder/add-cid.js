const CID = require('cids')

task(
    "add-cid",
    "Adds a CID (piece CID) of data that you would like to put a storage bounty on."
  )
    .addParam("contract", "The address of the DealRewarder contract")
    .addParam("piececid", "The piece CID of the data you want to put up a bounty for")
    .addParam("size", "Size of the data you are putting a bounty on")
    .setAction(async (taskArgs) => {
        //store taskargs as useable variables
        const contractAddr = taskArgs.contract
        const cid = taskArgs.piececid
        const size = taskArgs.size
        const networkId = network.name
        console.log("Adding CID", cid, "as a bounty on network", networkId)

        //create a new wallet instance
        const wallet = new ethers.Wallet(network.config.accounts[0], ethers.provider)
        
        //create a DealRewarder contract factory
        const DealRewarder = await ethers.getContractFactory("DealRewarder", wallet)
        //create a DealRewarder contract instance 
        //this is what you will call to interact with the deployed contract
        const dealRewarder = await DealRewarder.attach(contractAddr)
        
        //convert piece CID string to hex bytes
        const cidHexRaw = new CID(cid).toString('base16').substring(1)
        const cidHex = "0x00" + cidHexRaw
        console.log("Hex bytes are:", cidHex)
        
        //send a transaction to call addCID() method
        transaction = await dealRewarder.addCID(cidHex, size)
        transaction.wait()
       
        console.log("Complete!")
    })