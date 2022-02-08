// SPDX-License-Identifier: Unlicensed
// wsFORT Contract

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

interface IsFORT{
    function index() external view returns ( uint );
}
contract wsFORT is ERC20 {

    address public immutable sFORT;

    constructor( address _sFORT ) ERC20( 'Wrapped sFORT', 'wsFORT' ) {
        require( _sFORT != address(0) );
        sFORT = _sFORT;
    }

    /**
        @notice wrap sFORT
        @param _amount uint
        @return uint
     */
    function wrap( uint _amount ) external returns ( uint ) {
        IERC20( sFORT ).transferFrom( msg.sender, address(this), _amount );

        uint value = sFORTTowsFORT( _amount );
        _mint( msg.sender, value );
        return value;
    }

    /**
        @notice unwrap sFORT
        @param _amount uint
        @return uint
     */
    function unwrap( uint _amount ) external returns ( uint ) {
        _burn( msg.sender, _amount );

        uint value = wsFORTTosFORT( _amount );
        IERC20( sFORT ).transfer( msg.sender, value );
        return value;
    }

    /**
        @notice converts wsFORT amount to sFORT
        @param _amount uint
        @return uint
     */
    function wsFORTTosFORT( uint _amount ) public view returns ( uint ) {
        return _amount * ( IsFORT( sFORT ).index() ) / ( 10 ** decimals() );
    }

    /**
        @notice converts sFORT amount to wsFORT
        @param _amount uint
        @return uint
     */
    function sFORTTowsFORT( uint _amount ) public view returns ( uint ) {
        return _amount * ( 10 ** decimals() ) / ( IsFORT( sFORT ).index() );
    }
} 