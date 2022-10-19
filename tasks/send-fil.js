const fa = require("@glif/filecoin-address");
const util = require("util");
const request = util.promisify(require("request"));

task("send-fil", "Send coins to another wallet.")
  .addParam("account", "The address of the account you want the balance for")
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

    const account = taskArgs.account
    const networkId = network.name
    console.log("Sending 10 FIL to", account, "on network", networkId)
    const SimpleCoin = await ethers.getContractFactory("SimpleCoin")

    //Get signer information
    const DEPLOYER_PRIVATE_KEY = network.config.accounts[0]
    const provider = new ethers.providers.JsonRpcProvider("https://wallaby.node.glif.io/rpc/v0")
    const signer = new ethers.Wallet(DEPLOYER_PRIVATE_KEY).connect(provider)
    const priorityFee = await callRpc("eth_maxPriorityFeePerGas");
    console.log("Signer address:", signer.address)
    const pubKey = hexToBytes(signer.publicKey.slice(2));
    const f1addr = fa.newSecp256k1Address(pubKey).toString();
    const nonce = await callRpc("Filecoin.MpoolGetNonce", [f1addr]);
    console.log('nonce:', nonce);
    try {
      //Create connection to API Consumer Contract and call the createRequestTo function
      const transaction = await signer.sendTransaction({
        from: signer.address,
        to: account,
        value: "100000000000000000000",
        gasLimit: 10000000,
        gasPrice: priorityFee,
        nonce: nonce
      })
      console.log(transaction)
    } catch (e) {
      console.log("Failed send coin")
      console.log(e.message)
    }
  })


module.exports = {}