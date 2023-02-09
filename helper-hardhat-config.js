const { ethers } = require("hardhat")

const networkConfig = {
    31415926: {
        name: "hyperspace",
        tokensToBeMinted: 18000,
    },
}

// const developmentChains = ["hardhat", "localhost"]

module.exports = {
    networkConfig,
    // developmentChains,
}
