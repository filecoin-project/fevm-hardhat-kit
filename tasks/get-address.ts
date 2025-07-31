import { task } from "hardhat/config"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import * as fa from "@glif/filecoin-address"

task("get-address", "Gets Filecoin f4 address and corresponding Ethereum address.").setAction(
    async (_taskArgs, hre: HardhatRuntimeEnvironment) => {
        //create new Wallet object from private key
        const [wallet] = await hre.ethers.getSigners()
        const walletAddress = await wallet.getAddress()

        //Convert Ethereum address to f4 address
        const f4Address = fa.newDelegatedEthAddress(walletAddress).toString()
        console.log("Ethereum address (this addresss should work for most tools):", walletAddress)
        console.log("f4address (also known as t4 address on testnets):", f4Address)
    }
)
