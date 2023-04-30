const { ethers } = require("hardhat")

const networkConfig = {
    31415926: {
	name: "localnet",
	tokensToBeMinted: 12000,
    },
    3141: {
        name: "hyperspace",
        tokensToBeMinted: 12000,
    },
    314: {
        name: "filecoinmainnet",
        tokensToBeMinted: 12000,
    },
}

// const developmentChains = ["hardhat", "localhost"]

module.exports = {
    networkConfig,
    // developmentChains,
}
