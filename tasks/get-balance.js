const fs = require("fs")

task("get-balance", "Calls the simple coin Contract to read the amount of SimpleCoins owned by the account.")
  .addParam("account", "The address of the account you want the balance for")
  .setAction(async (taskArgs) => {
    const account = taskArgs.account
    const networkId = network.name

    if (fs.existsSync("./deployments/wallaby/SimpleCoin.json")) {
      const deployment = JSON.parse(fs.readFileSync("./deployments/wallaby/SimpleCoin.json").toString())
      const contractAddr = deployment.address
      console.log("Reading SimpleCoin deployed at", contractAddr, "on network", networkId)
      const SimpleCoin = await ethers.getContractFactory("SimpleCoin")

      //Get signer information
      const accounts = await ethers.getSigners()
      const signer = accounts[0]


      //Create connection to API Consumer Contract and call the createRequestTo function
      const simpleCoinContract = new ethers.Contract(contractAddr, SimpleCoin.interface, signer)
      let result = BigInt(await simpleCoinContract.getBalance(account)).toString()
      console.log("Data is:", result)
      if (result == 0 && ["hardhat", "localhost", "ganache"].indexOf(network.name) == 0) {
        console.log("You'll either need to wait another minute, or fix something!")
      }
      if (["hardhat", "localhost", "ganache"].indexOf(network.name) >= 0) {
        console.log("You'll have to manually update the value since you're on a local chain!")
      }
    } else {
      console.log("Deploy contract first!")
    }
  })

module.exports = {}