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


  const pubKey = hexToBytes(deployer.publicKey.slice(2));
  const f1addr = fa.newSecp256k1Address(pubKey).toString();

  const priorityFee = await callRpc("eth_maxPriorityFeePerGas");
  const nonce = await callRpc("Filecoin.MpoolGetNonce", [f1addr]);
  console.log('nonce:', nonce);
  // console.log("Ethereum deployer address:", deployer.address);
  console.log("Send faucet funds to this address (f1):", f1addr);
  // If the address has not recieved Filecoin yet, this line will fail. Go to faucet.
  let actorId = await callRpc('Filecoin.StateLookupID', [f1addr, []]);
  actorIdDecimal = Number(actorId.slice(1)).toString(10);
  actorId = Number(actorId.slice(1)).toString(16);
  const f0addr = '0xff' + '0'.repeat(38-actorId.length) + actorId;

  // console.log('Filecoin deployer address f0', "f0" + actorIdDecimal)
  console.log('Ethereum deployer address (from f0):', f0addr);
  console.log("priorityFee: ", priorityFee);
})


module.exports = {}