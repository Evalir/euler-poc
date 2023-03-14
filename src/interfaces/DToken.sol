// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IDToken {
    function repay(uint256 subAccountId, uint256 amount) external;
}
