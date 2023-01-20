const util = require("util");
const request = util.promisify(require("request"));

task(
    "store-all",
    "Calls all the getter functions in the Filecoin Market API to store data from a specific deal."
  )
    .addParam("contract", "The address of the FilecoinMarketConsumer contract")
    .addParam("dealid", "The id of the deal who's data you want to store")
    .setAction(async (taskArgs) => {
        const contractAddr = taskArgs.contract
        const account = taskArgs.account
        const networkId = network.name
        console.log("Storing data from FilecoinMarketAPI Getter Functions on network", networkId)
        const FilecoinMarketConsumer = await ethers.getContractFactory("FilecoinMarketConsumer")
  
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

        
        const filecoinMarketConsumer = new ethers.Contract(contractAddr, FilecoinMarketConsumer.interface, signer)
        const dealID = taskArgs.dealid
        await filecoinMarketConsumer.storeAll(dealID, {
            gasLimit: 1000000000,
            maxPriorityFeePerGas: priorityFee
        })
        
        console.log("Complete! Please wait about a minute before reading state!" )
    })
  
  module.exports = {}
  