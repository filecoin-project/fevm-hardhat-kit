const { ethers } = require("hardhat")

const networkConfig = {
    31415926: {
	name: "Localnet",
	tokensToBeMinted: 12000,
    },
    3141: {
        name: "Hyperspace",
        tokensToBeMinted: 12000,
    },
    314: {
        name: "FilecoinMainnet",
        tokensToBeMinted: 12000,
    },
}

// const developmentChains = ["hardhat", "localhost"]

module.exports = {
    networkConfig,
    // developmentChains,
}
