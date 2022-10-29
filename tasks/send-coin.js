const fa = require("@glif/filecoin-address");
const util = require("util");
const request = util.promisify(require("request"));
const fs = require('fs')

task("send-coin", "Send coins to another wallet.")
  .addParam("to", "The address of the account you want to send coins")
  .addParam("amount", "The amount of coins you want to send")
  .setAction(async (taskArgs) => {

    async function callRpc(method, params) {
      var options = {
        method: "POST",
        url: "https://wallaby.node.glif.io/rpc/v0",
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

    if (fs.existsSync("./deployments/wallaby/SimpleCoin.json")) {
      const deployment = JSON.parse(fs.readFileSync("./deployments/wallaby/SimpleCoin.json").toString())
      const contractAddr = deployment.address
      const account = taskArgs.to
      const amount = taskArgs.amount
      const networkId = network.name
      console.log("Sending " + amount + " SimpleCoin (", contractAddr, ") to", account, "on network", networkId)
      // Define ABI interface
      const ABI = [{
        "inputs": [
          {
            "internalType": "address",
            "name": "receiver",
            "type": "address"
          },
          {
            "internalType": "uint256",
            "name": "amount",
            "type": "uint256"
          }
        ],
        "name": "sendCoin",
        "outputs": [
          {
            "internalType": "bool",
            "name": "sufficient",
            "type": "bool"
          }
        ],
        "stateMutability": "nonpayable",
        "type": "function"
      }]
      // Get signer information
      const DEPLOYER_PRIVATE_KEY = network.config.accounts[0]
      const provider = new ethers.providers.JsonRpcProvider("https://wallaby.node.glif.io/rpc/v0")
      const signer = new ethers.Wallet(DEPLOYER_PRIVATE_KEY).connect(provider)
      const priorityFee = await callRpc("eth_maxPriorityFeePerGas");
      console.log("Signer address:", signer.address)
      // const pubKey = hexToBytes(signer.publicKey.slice(2));
      // const f1addr = fa.newSecp256k1Address(pubKey).toString();
      const nonce0x = await callRpc("eth_getTransactionCount", [signer.address, "latest"]);
      const nonce = parseInt(nonce0x, "hex")
      console.log('nonce:', nonce);
      try {
        const contractInterface = new ethers.utils.Interface(ABI)
        const data = await contractInterface.encodeFunctionData("sendCoin", [account, amount])
        const transaction = await signer.sendTransaction({
          from: signer.address,
          to: contractAddr,
          value: "0",
          data: data,
          gasLimit: 10000000,
          gasPrice: priorityFee,
          nonce: nonce
        })
        console.log(transaction)
        console.log(result)
      } catch (e) {
        console.log("Failed send coin")
        console.log(e.message)
      }
    } else {
      console.log("Deploy the contract first!")
    }
  })


module.exports = {}