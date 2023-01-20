const CID = require('cids')
const util = require("util");
const request = util.promisify(require("request"));

task(
    "add-cid",
    "Adds a CID (should be a piece ID) of data that you would like to put a storage bounty on."
  )
    .addParam("contract", "The address of the DealRewarder contract")
    .addParam("cid", "The piece CID of the data you want to put up a bounty for")
    .addParam("size", "Size of the data you are putting a bounty on")
    .setAction(async (taskArgs) => {
        const contractAddr = taskArgs.contract
        const account = taskArgs.account
        const networkId = network.name
        console.log("Adding CID as a bounty", networkId)
        const DealRewarder = await ethers.getContractFactory("DealRewarder")
  
        //Get signer information
        const accounts = await ethers.getSigners()
        const signer = accounts[0]

        const priorityFee = await callRpc("eth_maxPriorityFeePerGas")

    async function callRpc(method, params) {
        var options = {
          method: "POST",
          url: "https://api.hyperspace.node.glif.io/rpc/v1",
          // url: "http://localhost:1234/rpc/v0",
          headers: {
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            jsonrpc: "2.0",
            method: method,
            params: params,
            id: 1,
          }),
        };
        const res = await request(options);
        return JSON.parse(res.body).result;
      }

        
        const dealRewarder = new ethers.Contract(contractAddr, DealRewarder.interface, signer)
        const cid = taskArgs.cid
        const size = taskArgs.size
        const cidHexRaw = new CID(cid).toString('base16').substring(1)
        const cidHex = "0x00" + cidHexRaw
        console.log("Bytes are:", cidHex)
   
        await dealRewarder.addCID(cidHex, size, {
            gasLimit: 1000000000,
            maxPriorityFeePerGas: priorityFee
        })
       
        console.log("Complete! Please wait about a minute before reading state!" )
    })
  
  module.exports = {}
  