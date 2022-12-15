import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";
import "hardhat-deploy-ethers";
import "./tasks";

require("dotenv").config()

const PRIVATE_KEY = process.env.PRIVATE_KEY
/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
    solidity: "0.8.17",
    defaultNetwork: "wallaby",
    networks: {
        wallaby: {
            chainId: 31415,
            url: "https://wallaby.node.glif.io/rpc/v0",
            accounts: [PRIVATE_KEY],
        },
    },
    paths: {
        sources: "./contracts",
        tests: "./test",
        cache: "./cache",
        artifacts: "./artifacts",
    },
}