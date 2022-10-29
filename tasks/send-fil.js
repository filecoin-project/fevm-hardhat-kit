const fa = require("@glif/filecoin-address");
const util = require("util");
const request = util.promisify(require("request"));

task("send-fil", "Send coins to another wallet.")
  .addParam("to", "The address where you want to send FIL")
  .addParam("amount", "Amount of FIL you want to send")
  .setAction(async (taskArgs) => {

    function hexToBytes(hex) {
      for (var bytes = [], c = 0; c < hex.length; c += 2)
        bytes.push(parseInt(hex.substr(c, 2), 16));
      return new Uint8Array(bytes);
    }

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

    const to = taskArgs.to
    const amount = taskArgs.amount
    const networkId = network.name
    console.log("Sending " + amount + " FIL to", to, "on network", networkId)

    //Get signer information
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
      const transaction = await signer.sendTransaction({
        from: signer.address,
        to: to,
        value: amount,
        gasLimit: 10000000,
        gasPrice: priorityFee,
        nonce: nonce
      })
      console.log(transaction)
    } catch (e) {
      console.log("Failed sending FIL")
      console.log(e.message)
    }
  })


module.exports = {}