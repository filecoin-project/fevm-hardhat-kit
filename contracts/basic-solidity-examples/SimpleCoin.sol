// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

import "hardhat/console.sol";

error SimpleCoin__NotEnoughBalance();

contract SimpleCoin {
        mapping (address => uint) public balances;
        uint256 private i_tokensToBeMinted;

        event tokensMinted(
            uint256 indexed numberTokensMinted,
            address owner    
        );

        constructor(uint256 tokensToBeMinted) {
                balances[tx.origin] = tokensToBeMinted;
                i_tokensToBeMinted= tokensToBeMinted;
                emit tokensMinted(tokensToBeMinted, msg.sender);
        }

        function sendCoin(address receiver, uint amount) public returns(bool sufficient) {
                if (balances[msg.sender] < amount) {
                        // return false;
                revert SimpleCoin__NotEnoughBalance();
                }

                balances[msg.sender] -= amount;
                balances[receiver] += amount;
                 console.log(
        "Transferring from %s to %s %s tokens",
        msg.sender,
        receiver,
        amount
    );
                return true;
        }

        function getBalance(address addr) public view returns(uint) {
                return balances[addr];
        }

        function getMintedTokenBalance() public view returns(uint256){
                return i_tokensToBeMinted;
        }
}