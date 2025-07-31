import { DeployFunction } from "hardhat-deploy/types"
import { HardhatRuntimeEnvironment } from "hardhat/types"

/**
 * Contracts deployment
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const DeployContracts: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
    const [deployerSigner] = await hre.ethers.getSigners()
    const deployer = await deployerSigner.getAddress()

    const { deploy } = hre.deployments
    const tokensToBeMinted = 12000

    // deploy Simplecoin
    const simpleCoin = await deploy("SimpleCoin", {
        from: deployer,
        args: [tokensToBeMinted],
        log: true,
        waitConfirmations: 3,
    })

    // deploy FilecoinMarketConsumer
    const filecoinMarketConsumer = await deploy("FilecoinMarketConsumer", {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: 3,
    })

    // deploy DealRewarder
    const dealRewarder = await deploy("DealRewarder", {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: 3,
    })

    // deploy DealClient
    const dealClient = await deploy("DealClient", {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: 2,
    })

    //verify contracts
    await verifyContract(simpleCoin.address, [tokensToBeMinted], hre)
    await verifyContract(filecoinMarketConsumer.address, [], hre)
    await verifyContract(dealRewarder.address, [], hre)
    await verifyContract(dealClient.address, [], hre)
}

const IGNORE_BLOCKSCOUT_VERIFICATION = process.env.IGNORE_BLOCKSCOUT_VERIFICATION === "true"
const IGNORE_FILFOX_VERIFICATION = process.env.IGNORE_FILFOX_VERIFICATION === "true"

async function verifyContract(
    contractAddress: string,
    constructorArguments: any,
    hre: HardhatRuntimeEnvironment
) {
    if (!IGNORE_FILFOX_VERIFICATION) {
        await filfoxVerifier(contractAddress, hre)
    }
    if (!IGNORE_BLOCKSCOUT_VERIFICATION) {
        await blockscoutVerifier(contractAddress, constructorArguments, hre)
    }
}

async function blockscoutVerifier(
    contractAddress: string,
    constructorArguments: any,
    hre: HardhatRuntimeEnvironment
) {
    try {
        await hre.run("verify:verify", {
            address: contractAddress,
            constructorArguments: constructorArguments,
            force: true,
        })
    } catch (error) {
        console.log("\nError verifying contract using the force flag ")
    } finally {
        console.log("\nTrying again without the force flag\n")
        try {
            await hre.run("verify:verify", {
                address: contractAddress,
                constructorArguments: constructorArguments,
                force: false,
            })
        } catch (error) {
            console.log("Error while verifying contract on blockscout: ", error)
        }
    }
}

async function filfoxVerifier(contractAddress: string, hre: HardhatRuntimeEnvironment) {
    try {
        // verify contract on filfox
        await hre.run("verifyfilfox", {
            address: contractAddress,
        })
    } catch (error) {
        console.log("\nError verifying contract on filfox", error)
    }
}

export default DeployContracts
