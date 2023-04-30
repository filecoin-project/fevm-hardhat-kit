require("hardhat-deploy")
require("hardhat-deploy-ethers")

const { networkConfig } = require("../helper-hardhat-config")


const private_key = network.config.accounts[0]
const wallet = new ethers.Wallet(private_key, ethers.provider)

module.exports = async ({ deployments }) => {
    const { deploy } = deployments;
    console.log("Wallet Ethereum Address:", wallet.address)
    const chainId = network.config.chainId
    const tokensToBeMinted = networkConfig[chainId]["tokensToBeMinted"]

    
    //deploy Simplecoin
    const simpleCoin = await deploy("SimpleCoin", {
        from: wallet.address,
        args: [tokensToBeMinted],
        log: true,
    });

    //deploy FilecoinMarketConsumer
    const filecoinMarketConsumer = await deploy("FilecoinMarketConsumer", {
        from: wallet.address,
        args: [],
        log: true,
    });

    //deploy DealRewarder
    const dealRewarder = await deploy("DealRewarder", {
        from: wallet.address,
        args: [],
        log: true,
    });
    
    //deploy DealClient
    const dealClient = await deploy("DealClient", {
        from: wallet.address,
        args: [],
        log: true,
    });
}