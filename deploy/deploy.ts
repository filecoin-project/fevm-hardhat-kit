// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import "hardhat-deploy";
import "hardhat-deploy-ethers";

import { newSecp256k1Address } from "@glif/filecoin-address";
import { HttpNetworkConfig, HardhatRuntimeEnvironment } from "hardhat/types";

import util from "util";
// eslint-disable-next-line node/no-extraneous-require
const request = util.promisify(require("request"));
const { networkConfig } = require("../helper-hardhat-config")

require("dotenv").config();

// import { HttpNetworkConfig } from "hardhat/types";
// import { FeeMarketEIP1559Transaction } from "@ethereumjs/tx";

function hexToBytes(str: string): Uint8Array {
  if (!str) {
    return new Uint8Array();
  }
  const a = [];
  for (let i = 0, len = str.length; i < len; i += 2) {
    a.push(parseInt(str.substr(i, 2), 16));
  }
  return new Uint8Array(a);
}

async function callRpc(method: any, params?: any): Promise<any> {
  const options = {
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

const main = async ({network, ethers, deployments}: HardhatRuntimeEnvironment) => {
  const { deploy } = deployments;
  // Hardhat always runs the compile task when running scripts with its command
  // line interface.
  //
  // If this script is run directly using `node` you may want to call compile
  // manually to make sure everything is compiled
  // await hre.run('compile');
  const config = network.config as HttpNetworkConfig;
  const w = new ethers.Wallet((config.accounts as string[])[0]);

  const deployer = new ethers.Wallet(process.env.PRIVATE_KEY!);

  const pubKey = hexToBytes(deployer.publicKey.slice(2));
  const f1addr = newSecp256k1Address(pubKey).toString();

  const priorityFee = await callRpc("eth_maxPriorityFeePerGas");
  const nonce = await callRpc("Filecoin.MpoolGetNonce", [f1addr]);

  console.log("nonce:", nonce);
  console.log("Send faucet funds to this address (f1):", f1addr);

  let actorId = await callRpc("Filecoin.StateLookupID", [f1addr, []]);
  actorId = Number(actorId.slice(1)).toString(16);
  const f0addr = "0xff" + "0".repeat(38 - actorId.length) + actorId;

  console.log("Ethereum deployer address (from f0):", f0addr);
  console.log("priorityFee: ", priorityFee);

  const chainId = network.config.chainId
  const tokenToBeMinted = networkConfig[chainId!]["tokenToBeMinted"]
  await deploy("SimpleCoin", {
    from: deployer.address,
    args: [tokenToBeMinted],
    // since it's difficult to estimate the gas before f4 address is launched, it's safer to manually set
    // a large gasLimit. This should be addressed in the following releases.
    gasLimit: 1000000000, // BlockGasLimit / 10
    // since Ethereum's legacy transaction format is not supported on FVM, we need to specify
    // maxPriorityFeePerGas to instruct hardhat to use EIP-1559 tx format
    maxPriorityFeePerGas: priorityFee,
    nonce: nonce,
    log: true,
  });

  await deploy("MinerAPI", {
    from: deployer.address,
    args: [0x0000001],
    gasLimit: 1000000000,
    maxPriorityFeePerGas: priorityFee,
    nonce: nonce,
    log: true,
  })

  await deploy("MarketAPI", {
    from: deployer.address,
    args: [],
    gasLimit: 1000000000,
    maxPriorityFeePerGas: priorityFee,
    nonce: nonce,
    log: true,
  })

};

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
export default main;

main.tags = ["SimpleCoin", "MinerAPI", "MarketAPI"];
