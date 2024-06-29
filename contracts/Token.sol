// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract Token is ERC20, Ownable {
    address public wallet = msg.sender;

    constructor(string memory name, string memory symbol) ERC20(name, symbol) Ownable() {
        _mint(wallet, 100_000 * 10 ** decimals());
    }
}