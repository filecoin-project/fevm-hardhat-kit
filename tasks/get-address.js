const fa = require("@glif/filecoin-address");
const util = require("util");
const request = util.promisify(require("request"));

task("get-address", "Gets Filecoin f4 address and corresponding Ethereum address.")
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


  const pubKey = hexToBytes(deployer.publicKey.slice(2));

  const priorityFee = await callRpc("eth_maxPriorityFeePerGas");

  const f4Address = fa.newDelegatedEthAddress(deployer.address).toString();
  const nonce = await callRpc("Filecoin.MpoolGetNonce", [f4Address]);
  console.log("f4address (for use with faucet) = ", f4Address);
  console.log("Ethereum address:", deployer.address);  
})


module.exports = {}