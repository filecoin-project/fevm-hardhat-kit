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

    // //deploy Simplecoin
    const simpleCoin = await deploy("SimpleCoin", {
        from: deployer,
        args: [tokensToBeMinted],
        log: true,
        waitConfirmations: 3,
    })

    // //deploy FilecoinMarketConsumer
    const filecoinMarketConsumer = await deploy("FilecoinMarketConsumer", {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: 3,
    })

    // //deploy DealRewarder
    const dealRewarder = await deploy("DealRewarder", {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: 3,
    })

    // //deploy DealClient
    const dealClient = await deploy("DealClient", {
        from: deployer,
        args: [],
        log: true,
        waitConfirmations: 2,
    })
}

export default DeployContracts
