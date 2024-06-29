// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Token is ERC20, Ownable {
    address public holder = msg.sender;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) Ownable(holder) {
        _mint(holder, 100_000 * 10 ** decimals());
    }
}