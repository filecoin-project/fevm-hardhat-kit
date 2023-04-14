// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

import "./ISFil.sol";

contract SFil is ERC20, ISFil {
    uint8 public unwrapInitiated;
    uint public balance;

    constructor() ERC20("Staked FIL", "SFIL") {}

    /**
     * @notice Wraps FIL to sFIL for msg.sender
     */
    function wrap() external payable {
        _mint(msg.sender, msg.value);

        emit Wrap(msg.sender, msg.value);
    }

    /**
     * @notice Wraps FIL to sFIL for user
     * @param _user address of user
     */
    function user(address payable _user) external payable {
        _mint(_user, msg.value);

        emit Wrap(_user, msg.value);
    }

    /**
     * @notice burns the corresponding sFIL amount and send the FIL to msg.sender
     * @param _amount amount of sFIL to unwrap
     */
    function unwrap(uint _amount) external {
        require(unwrapInitiated == 0, "reetrancy");

        require(balanceOf(msg.sender) > _amount, "unsufficient funds!");

        unwrapInitiated = 1;

        _burn(msg.sender, _amount);
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "ERR: Transfer failed.");

        unwrapInitiated = 0;

        emit UnWrap(msg.sender, _amount);
    }
}