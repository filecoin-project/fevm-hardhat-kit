const { ethers } = require("ethers")
const fs = require("fs")
// Generate a new wallet
const generated = ethers.Wallet.createRandom()
// Save new wallet to .env file
fs.writeFileSync(".env", "PRIVATE_KEY=" + generated._signingKey().privateKey)
console.log("New address generated and private key saved in .env file")