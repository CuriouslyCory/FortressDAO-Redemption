// SPDX-License-Identifier: MIT
/*
Author: CuriouslyCory
Website: https://curiouslycory.com
Twitter: @CuriouslyCory
*/

pragma solidity ^0.8.7;

import "hardhat/console.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC20Burnable} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import {IERC20, SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IFORT is IERC20 {
    function burnFrom (address account_, uint256 amount_) external;
}

contract FortRedemption is Ownable, ReentrancyGuard{
    using SafeERC20 for IERC20;

    IFORT public immutable fortToken;
    IERC20 public immutable reserveCurrency;
    address public FORT;
    bool public redeemable;
    uint256 reservePerFort;

    constructor(address _FORT, address _reserveCurrency){
        require( _FORT != address(0) );
        fortToken = IFORT(_FORT);
        reserveCurrency = IERC20(_reserveCurrency);
    }

    function makeRedeemable (uint256 amount) external onlyOwner {
        require(redeemable == false);
        IERC20(reserveCurrency).transferFrom(msg.sender, address(this), amount);
        uint256 remainingReserve = reserveCurrency.balanceOf(address(this));
        uint256 circulatingSupply = IFORT(fortToken).totalSupply() * 10 ** 9;

        

        reservePerFort = SafeMath.div(remainingReserve * 10 ** 18, circulatingSupply);
        redeemable = true;
    }

    function redeemTokens(address sender, uint256 fortAmount) external nonReentrant isRedeemable {
        require(sender != address(0));
        require(fortAmount > 0);

        uint256 totalShare = SafeMath.mul(reservePerFort, fortAmount);
        totalShare = SafeMath.div(totalShare, 10 ** 18);

        require(totalShare <= IERC20(reserveCurrency).balanceOf(address(this)));
        reserveCurrency.safeTransfer(sender, totalShare);

        IFORT(fortToken).burnFrom(msg.sender, fortAmount);
    }

    function withdrawOtherCurrency(address _currency) external nonReentrant onlyOwner {
        require(_currency != address(fortToken), "Owner: Cannot withdraw FORT");

        uint256 balanceToWithdraw = IERC20(_currency).balanceOf(address(this));

        // Transfer token to owner if not null
        require(balanceToWithdraw != 0, "Owner: Nothing to withdraw");
        IERC20(_currency).safeTransfer(msg.sender, balanceToWithdraw);
    }

    modifier isRedeemable () {
        require(redeemable == true, "Not redeemable");
        _;
    }

    
}