// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Token is ERC20, Ownable {
    address public wallet = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266; // change to msg.sender;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) Ownable(wallet) {
        _mint(wallet, 100_000 * 10 ** decimals());
    }
}