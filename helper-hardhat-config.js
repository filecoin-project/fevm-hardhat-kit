const { ethers } = require("hardhat")

const networkConfig = {
    31415926: {
	name: "localnet",
	tokensToBeMinted: 12000,
    },
    314159: {
        name: "calibrationnet",
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
