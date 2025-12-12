// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test} from "@forge-std/Test.sol";
import {IERC20} from "@forge-std/interfaces/IERC20.sol";
import {ERC20} from "@solmate/tokens/ERC20.sol";

import {
    TooMuchSlippage,
    revertTooMuchSlippage,
    ActionInvalid,
    revertActionInvalid,
    UnknownForkId,
    revertUnknownForkId,
    ConfusedDeputy,
    revertConfusedDeputy
} from "src/core/SettlerErrors.sol";

import {Utils} from "../Utils.sol";

/// @title SettlerErrorsTest
/// @notice Unit tests for error handling functions in SettlerErrors.sol
contract SettlerErrorsTest is Utils, Test {
    IERC20 internal constant TEST_TOKEN = IERC20(address(0x1234567890123456789012345678901234567890));
    address internal constant TEST_ADDRESS = address(0xABCDEFABCDEFABCDEFABCDEFABCDEFABCDEFABCD);

    /// @notice Test revertTooMuchSlippage function with valid parameters
    function testRevertTooMuchSlippage() public {
        uint256 expectedBuyAmount = 1000e18;
        uint256 actualBuyAmount = 900e18; // Less than expected (slippage)

        vm.expectRevert(
            abi.encodeWithSelector(
                TooMuchSlippage.selector, TEST_TOKEN, expectedBuyAmount, actualBuyAmount
            )
        );

        revertTooMuchSlippage(TEST_TOKEN, expectedBuyAmount, actualBuyAmount);
    }

    /// @notice Test revertTooMuchSlippage with zero expected amount
    function testRevertTooMuchSlippageZeroExpected() public {
        uint256 expectedBuyAmount = 0;
        uint256 actualBuyAmount = 100e18;

        vm.expectRevert(
            abi.encodeWithSelector(
                TooMuchSlippage.selector, TEST_TOKEN, expectedBuyAmount, actualBuyAmount
            )
        );

        revertTooMuchSlippage(TEST_TOKEN, expectedBuyAmount, actualBuyAmount);
    }

    /// @notice Test revertTooMuchSlippage with maximum uint256 values
    function testRevertTooMuchSlippageMaxValues() public {
        uint256 expectedBuyAmount = type(uint256).max;
        uint256 actualBuyAmount = type(uint256).max - 1;

        vm.expectRevert(
            abi.encodeWithSelector(
                TooMuchSlippage.selector, TEST_TOKEN, expectedBuyAmount, actualBuyAmount
            )
        );

        revertTooMuchSlippage(TEST_TOKEN, expectedBuyAmount, actualBuyAmount);
    }

    /// @notice Test revertActionInvalid with valid parameters
    function testRevertActionInvalid() public {
        uint256 i = 5;
        bytes4 action = bytes4(0x12345678);
        bytes memory data = abi.encode("test data");

        vm.expectRevert(
            abi.encodeWithSelector(ActionInvalid.selector, i, action, data)
        );

        revertActionInvalid(i, uint256(uint32(action)), data);
    }

    /// @notice Test revertActionInvalid with empty data
    function testRevertActionInvalidEmptyData() public {
        uint256 i = 0;
        bytes4 action = bytes4(0x00000000);
        bytes memory data = "";

        vm.expectRevert(
            abi.encodeWithSelector(ActionInvalid.selector, i, action, data)
        );

        revertActionInvalid(i, uint256(uint32(action)), data);
    }

    /// @notice Test revertActionInvalid with large data
    function testRevertActionInvalidLargeData() public {
        uint256 i = 100;
        bytes4 action = bytes4(0xFFFFFFFF);
        bytes memory data = new bytes(1000);
        for (uint256 j = 0; j < 1000; j++) {
            data[j] = bytes1(uint8(j % 256));
        }

        vm.expectRevert(
            abi.encodeWithSelector(ActionInvalid.selector, i, action, data)
        );

        revertActionInvalid(i, uint256(uint32(action)), data);
    }

    /// @notice Test revertUnknownForkId with valid fork ID
    function testRevertUnknownForkId() public {
        uint8 forkId = 255;

        vm.expectRevert(
            abi.encodeWithSelector(UnknownForkId.selector, forkId)
        );

        revertUnknownForkId(forkId);
    }

    /// @notice Test revertUnknownForkId with zero fork ID
    function testRevertUnknownForkIdZero() public {
        uint8 forkId = 0;

        vm.expectRevert(
            abi.encodeWithSelector(UnknownForkId.selector, forkId)
        );

        revertUnknownForkId(forkId);
    }

    /// @notice Test revertConfusedDeputy function
    function testRevertConfusedDeputy() public {
        vm.expectRevert(
            abi.encodeWithSelector(ConfusedDeputy.selector)
        );

        revertConfusedDeputy();
    }

    /// @notice Fuzz test for revertTooMuchSlippage
    function testFuzzRevertTooMuchSlippage(
        address token,
        uint256 expected,
        uint256 actual
    ) public {
        vm.assume(expected != actual); // Ensure they're different for meaningful test

        vm.expectRevert(
            abi.encodeWithSelector(TooMuchSlippage.selector, IERC20(token), expected, actual)
        );

        revertTooMuchSlippage(IERC20(token), expected, actual);
    }

    /// @notice Fuzz test for revertActionInvalid
    function testFuzzRevertActionInvalid(
        uint256 i,
        bytes4 action,
        bytes memory data
    ) public {
        vm.expectRevert(
            abi.encodeWithSelector(ActionInvalid.selector, i, action, data)
        );

        revertActionInvalid(i, uint256(uint32(action)), data);
    }

    /// @notice Fuzz test for revertUnknownForkId
    function testFuzzRevertUnknownForkId(uint8 forkId) public {
        vm.expectRevert(
            abi.encodeWithSelector(UnknownForkId.selector, forkId)
        );

        revertUnknownForkId(forkId);
    }

    /// @notice Test that error selectors match expected values
    function testErrorSelectors() public {
        // Test TooMuchSlippage selector
        bytes4 tooMuchSlippageSelector = TooMuchSlippage.selector;
        assertEq(tooMuchSlippageSelector, bytes4(0x97a6f3b9), "TooMuchSlippage selector mismatch");

        // Test ActionInvalid selector
        bytes4 actionInvalidSelector = ActionInvalid.selector;
        assertEq(actionInvalidSelector, bytes4(0x3c74eed6), "ActionInvalid selector mismatch");

        // Test UnknownForkId selector
        bytes4 unknownForkIdSelector = UnknownForkId.selector;
        assertEq(unknownForkIdSelector, bytes4(0xd3b1276d), "UnknownForkId selector mismatch");

        // Test ConfusedDeputy selector
        bytes4 confusedDeputySelector = ConfusedDeputy.selector;
        assertEq(confusedDeputySelector, bytes4(0xe758b8d5), "ConfusedDeputy selector mismatch");
    }
}

