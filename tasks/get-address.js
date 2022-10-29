const fa = require("@glif/filecoin-address");
const util = require("util");
const request = util.promisify(require("request"));

task("get-address", "Gets Filecoin deployer address.")
  .setAction(async (taskArgs) => {

    const DEPLOYER_PRIVATE_KEY = network.config.accounts[0]

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

    const deployer = new ethers.Wallet(DEPLOYER_PRIVATE_KEY);
    const delegated = await fa.newDelegatedEthAddress(deployer.address)

    const nonce0x = await callRpc("eth_getTransactionCount", [deployer.address, "latest"]);
    const nonce = parseInt(nonce0x, "hex")
    console.log('nonce:', nonce);
    console.log("Ethereum deployer address:", deployer.address);
    console.log("Filecoin delegated address:", delegated.toString())
    // If the address has not recieved Filecoin yet, this line will fail. Go to faucet.
    try {
      let actorId = await callRpc('Filecoin.StateLookupID', [delegated.toString(), []]);
      actorIdDecimal = Number(actorId.slice(1)).toString(10);
      actorId = Number(actorId.slice(1)).toString(16);
      const f0addr = '0xff' + '0'.repeat(38 - actorId.length) + actorId;

      // console.log('Filecoin deployer address f0', "f0" + actorIdDecimal)
      console.log('Ethereum deployer address (from f0):', f0addr);
      if (nonce === 0) {
        console.log("--")
        console.log("You're ready to init your address now, please run:")
        console.log("yarn hardat init-address")
      }
    } catch (e) {
      console.log("Go to faucet: https://wallaby.network/#faucet")
    }
  })


module.exports = {}