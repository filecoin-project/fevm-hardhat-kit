const fa = require("@glif/filecoin-address");

task("get-address", "Gets Filecoin f4 address and corresponding Ethereum address.")
  .setAction(async (taskArgs) => {
  
  //create new Wallet object from private key
  const DEPLOYER_PRIVATE_KEY = network.config.accounts[0]
  const deployer = new ethers.Wallet(DEPLOYER_PRIVATE_KEY);

  //Convert Ethereum address to f4 address
  const f4Address = fa.newDelegatedEthAddress(deployer.address).toString();
  console.log("Ethereum address (this addresss should work for most tools):", deployer.address);
  console.log("f4address (also known as t4 address on testnets):", f4Address);
})