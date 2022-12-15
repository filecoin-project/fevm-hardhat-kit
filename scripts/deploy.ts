import { ethers } from "hardhat";

const fa = require("@glif/filecoin-address");
const util = require("util");
const request = util.promisify(require("request"));

async function main () {
    const [deployer] = await ethers.getSigners();
    console.log("deployer", deployer.address)

    let ctr;
    const feeData = await ethers.provider.getFeeData();
    const nonce = await ethers.provider.getTransactionCount(deployer.address);
    console.log('before', nonce)

    const ctrFactory = await ethers.getContractFactory('SimpleCoin')
    ctr = (await ctrFactory.deploy(1, {
      maxPriorityFeePerGas: feeData.maxPriorityFeePerGas?.mul(2), 
      maxFeePerGas: feeData. maxFeePerGas?.mul(2), 
      type: 2,
      nonce: nonce,
    }))

    await ctr.deployTransaction.wait(1);
    const nonce2 = await ethers.provider.getTransactionCount(deployer.address);
    console.log('after', ctr.address, nonce2, ctr.deployTransaction)
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
