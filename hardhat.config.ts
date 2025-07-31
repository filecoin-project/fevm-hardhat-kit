import "./tasks"
import "@nomicfoundation/hardhat-chai-matchers"
import "@nomicfoundation/hardhat-ethers"
import "@nomicfoundation/hardhat-verify"
import "@typechain/hardhat"
import { config as dotenvConfig } from "dotenv"
import "hardhat-deploy"
import "hardhat-deploy-ethers"
import "hardhat-gas-reporter"
import { HardhatUserConfig } from "hardhat/config"
import "solidity-coverage"
dotenvConfig()
const deployerPrivateKey = process.env.PRIVATE_KEY!

const config: HardhatUserConfig = {
    solidity: {
        version: "0.8.23",
        settings: {
            optimizer: {
                enabled: true,
                // https://docs.soliditylang.org/en/latest/using-the-compiler.html#optimizer-options
                runs: 1000,
            },
            viaIR: false,
        },
    },
    defaultNetwork: "calibration",
    namedAccounts: {
        deployer: {
            // By default, it will take the first Hardhat account as the deployer
            default: 0,
        },
    },
    networks: {
        filecoin: {
            url: "https://rpc.ankr.com/filecoin",
            accounts: [deployerPrivateKey],
            chainId: 314,
        },
        calibration: {
            url: "https://rpc.ankr.com/filecoin_testnet",
            accounts: [deployerPrivateKey],
            chainId: 314159,
        },
    },
}

export default config
