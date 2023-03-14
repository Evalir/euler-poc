// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IWETH {
    function totalSupply() external view returns (uint256);
    function balanceOf(address addr) external view returns (uint256);
    function approve(address guy, uint256 wad) external returns (bool);
    function withdraw(uint256 wad) external;
    function transfer(address dst, uint256 wad) external returns (bool);
    function transferFrom(address src, address dst, uint256 wad) external returns (bool);
}
