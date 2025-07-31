import { task } from "hardhat/config"
import { HardhatRuntimeEnvironment } from "hardhat/types"
import CID from "cids"
import { DealClient } from "../../typechain-types"
import { DealRequestStruct } from "../../typechain-types/contracts/basic-deal-client/DealClient"
import { ContractTransactionReceipt } from "ethers"

task(
    "make-deal-proposal",
    "Makes a deal proposal via the client contract. This will ultimately emit an event that storage providers can listen too and choose to accept your deal."
)
    .addParam("contract", "The address of the deal client solidity")
    .addParam("pieceCid", "The address of the DealRewarder contract")
    .addParam("pieceSize", "The piece CID of the data you want to put up a bounty for")
    .addParam("verifiedDeal", "Size of the data you are putting a bounty on")
    .addParam("label", "The deal label (typically the raw cid)")
    .addParam("startEpoch", "The epoch the deal will start")
    .addParam("endEpoch", "The epoch the deal will end")
    .addParam("storagePricePerEpoch", "The cost of the deal, in FIL, per epoch")
    .addParam("providerCollateral", "The collateral, in FIL, to be put up by the storage provider")
    .addParam(
        "clientCollateral",
        "The collateral, in FIL, to be put up by the the client (which is you)"
    )
    .addParam("extraParamsVersion", "")
    .addParam("locationRef", "Where the data you want to be stored is located")
    .addParam("carSize", "The size of the .car file")
    .addParam("skipIpniAnnounce", "")
    .addParam("removeUnsealedCopy", "")
    .setAction(async (taskArgs, hre: HardhatRuntimeEnvironment) => {
        //store taskargs as useable variables
        //convert piece CID string to hex bytes
        const cid = taskArgs.pieceCid
        const cidHexRaw = new CID(cid).toString("base16").substring(1)
        const cidHex = "0x" + cidHexRaw
        const contractAddr = taskArgs.contract

        const verified = taskArgs.verifiedDeal === "true"
        const skipIpniAnnounce = taskArgs.skipIpniAnnounce === "true"
        const removeUnsealedCopy = taskArgs.removeUnsealedCopy === "true"

        const extraParamsV1 = [
            taskArgs.locationRef,
            taskArgs.carSize,
            skipIpniAnnounce,
            removeUnsealedCopy,
        ]

        const DealRequestStruct = [
            cidHex,
            taskArgs.pieceSize,
            verified,
            taskArgs.label,
            taskArgs.startEpoch,
            taskArgs.endEpoch,
            taskArgs.storagePricePerEpoch,
            taskArgs.providerCollateral,
            taskArgs.clientCollateral,
            taskArgs.extraParamsVersion,
            extraParamsV1,
        ] as unknown as DealRequestStruct
        const networkId = hre.network.name
        console.log("Making deal proposal on network", networkId)

        //create a new wallet instance
        const [wallet] = await hre.ethers.getSigners()

        //create a DealClient contract factory
        const DealClient = await hre.ethers.getContractFactory("DealClient", wallet)
        //create a DealClient contract instance
        //this is what you will call to interact with the deployed contract
        const dealClient = DealClient.attach(contractAddr) as DealClient

        //send a transaction to call makeDealProposal() method
        const transaction = await dealClient.makeDealProposal(DealRequestStruct)
        const transactionReceipt = (await transaction.wait()) as ContractTransactionReceipt
        if (!transactionReceipt) {
            throw new Error("Transaction receipt is null")
        }
        const event = transactionReceipt.logs[0].topics[1]
        console.log("Complete! Event Emitted. ProposalId is:", event)
    })
