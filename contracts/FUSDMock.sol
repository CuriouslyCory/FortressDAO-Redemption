// SPDX-License-Identifier: MIT
/*
Author: CuriouslyCory
Website: https://curiouslycory.com
Twitter: @CuriouslyCory
*/

pragma solidity ^0.8.7;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract FUSDMock is ERC20 {
    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {
        _mint(msg.sender, 14000000 * 10**uint(decimals()));
    }
}