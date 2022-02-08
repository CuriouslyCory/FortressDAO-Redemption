// SPDX-License-Identifier: MIT
/*
Author: CuriouslyCory
Website: https://curiouslycory.com
Twitter: @CuriouslyCory
*/

pragma solidity ^0.8.7;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract sFORT is ERC20 {
    constructor(string memory _name, string memory _symbol, uint128 quantity) ERC20(_name, _symbol) {
        _mint(msg.sender, quantity * 10 ** uint(decimals()));
    }

    function index() public view returns ( uint ) {
        return 5;
    }

    function decimals() public view virtual override returns (uint8) {
        return 9;
    }
}