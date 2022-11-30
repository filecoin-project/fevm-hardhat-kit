const { ethers } = require("hardhat")

const networkConfig = {
    31415: {
        name: "wallaby",
        tokenToBeMinted: 12000,
    },
}

// const developmentChains = ["hardhat", "localhost"]

module.exports = {
    networkConfig,
    // developmentChains,
}
