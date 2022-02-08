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

interface IFORT is IERC20 {}

contract wsFortRedemption is Ownable, ReentrancyGuard{
    using SafeERC20 for IERC20;

    IFORT public immutable wsFortToken;
    IERC20 public immutable reserveCurrency;
    address public FORT;
    bool public redeemable;
    uint256 reservePerFort;
    uint256 redeemableQty;

    constructor(address _WSFORT, address _reserveCurrency, uint256 _redeemableQty){
        require( _WSFORT != address(0) );
        wsFortToken = IFORT(_WSFORT);
        reserveCurrency = IERC20(_reserveCurrency);
        redeemableQty = _redeemableQty;
    }

    function makeRedeemable (uint256 amount) external onlyOwner {
        require(redeemable == false);
        IERC20(reserveCurrency).transferFrom(msg.sender, address(this), amount);
        uint256 remainingReserve = reserveCurrency.balanceOf(address(this));

        reservePerFort = SafeMath.div(remainingReserve * 10 ** 18, redeemableQty);
        redeemable = true;
    }

    // 
    function redeemTokens(address sender, uint256 wsFortAmount) external nonReentrant isRedeemable {
        require(sender != address(0));
        require(wsFortAmount > 0);

        uint256 totalShare = SafeMath.mul(reservePerFort, wsFortAmount);
        totalShare = SafeMath.div(totalShare, 10 ** 18);

        require(totalShare <= IERC20(reserveCurrency).balanceOf(address(this)));
        reserveCurrency.safeTransfer(sender, totalShare);
    }

    // call with contract address of the token you want to withdraw
    function withdrawCurrency(address _currency) external nonReentrant onlyOwner {
        uint256 balanceToWithdraw = IERC20(_currency).balanceOf(address(this));

        // Transfer token to owner if not null
        require(balanceToWithdraw != 0, "Owner: Nothing to withdraw");
        IERC20(_currency).safeTransfer(msg.sender, balanceToWithdraw);
    }

    // redemption not yet triggered
    modifier isRedeemable () {
        require(redeemable == true, "Not redeemable");
        _;
    }

    
}