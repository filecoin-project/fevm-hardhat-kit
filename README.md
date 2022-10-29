# FEVM Hardhat Kit

## Cloning the Repo

Open up your terminal (or command prompt) and navigate to a directory you would like to store this code on. Once there type in the following command:


```
git clone https://github.com/filecoin-project/FEVM-Hardhat-Kit.git
cd FEVM-Hardhat-Kit 
yarn install
```


This will clone the hardhat kit onto your computer, switch directories into the newly installed kit, and install the dependencies the kit needs to work.


## Get a Private Key

You can get a private key from a wallet provider [such as Metamask](https://metamask.zendesk.com/hc/en-us/articles/360015289632-How-to-export-an-account-s-private-key).


## Add your Private Key as an Environment Variable

Add your private key as an environment variable by running this command: 
 
 ```
export PRIVATE_KEY='abcdef'
```

 \
If you use a `.env` file, don't commit and push any changes to .env files that may contain sensitive information, such as a private key! If this information reaches a public GitHub repository, someone can use it to check if you have any Mainnet funds in that wallet address, and steal them!

### Generate a new private key from project

If you want to generate the private key directly from project you can use our script, this will create a brand new key with EthersJS and will save it in `.env` file.

If you want to do it please run:
```
yarn generate-address
```
## Get the Deployer Address

Run this command:
```
yarn hardhat get-address
```

Copy the f1 address (the one that says to send faucet funds). We will use this in the next step to send faucet funds.

Also record the f0 address. We will use the f0 address when interacting with the SimpleCoin contract.

## Fund the Deployer Address

Go to the [Wallaby faucet](https://wallaby.network/#faucet), and paste in the address we copied in the previous step. This will send some wallaby testnet FIL to the account.

## Init deployer address

In order to deploy contract your address must do at least 1 transaction, so you 
## Deploy the SimpleCoin Contract

Type in the following command in the terminal: 
 
 ```
yarn hardhat deploy
```

This will compile the contract and deploy it to the Wallaby network automatically!

Keep note of the deployed contract address for the next step.

If you read the Solidity code for SimpleCoin, you will see in the constructor our deployer account automatically gets assigned 10000 SimpleCoin when the contract is deployed.


## Read your SimpleCoin balance

Type in the following command in the terminal: 
 
 ```
yarn hardhat get-balance --account “YOUR 0x ADDRESS HERE”
```

The console should read that your account has 10000 SimpleCoin!

## Send coins to another address

Type in the following command in the terminal: 
 
 ```
yarn hardhat send-coin --to “YOUR 0x ADDRESS HERE” --amount “AMOUNT YOU WANT TO SEND”
```