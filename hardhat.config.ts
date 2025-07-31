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
import "@fil-b/filfox-verifier/hardhat"
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
    // configuration for harhdat-verify plugin with Blockscout API
    etherscan: {
        enabled: true,
        apiKey: {
            filecoin: "empty",
            calibration: "empty",
        },
        customChains: [
            {
                network: "filecoin",
                chainId: 314,
                urls: {
                    apiURL: "https://filecoin.blockscout.com/api",
                    browserURL: "https://filecoin.blockscout.com",
                },
            },
            {
                network: "calibration",
                chainId: 314159,
                urls: {
                    apiURL: "https://filecoin-testnet.blockscout.com/api",
                    browserURL: "https://filecoin-testnet.blockscout.com",
                },
            },
        ],
    },
    verify: {
        etherscan: {
            apiKey: "empty",
        },
    },
    sourcify: {
        enabled: true, // verifies both on Sourcify and on Blockscout
        // Optional: specify a different Sourcify server
        apiUrl: "https://sourcify.dev/server",
        // Optional: specify a different Sourcify repository
        browserUrl: "https://repo.sourcify.dev",
    },
}

export default config
