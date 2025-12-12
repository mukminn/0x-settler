// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test} from "@forge-std/Test.sol";
import {IERC20} from "@forge-std/interfaces/IERC20.sol";

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
/// @dev Tests verify that error revert functions correctly encode and revert with the expected error data
contract SettlerErrorsTest is Utils, Test {
    /// @notice Test token address used for testing error functions
    IERC20 internal constant TEST_TOKEN = IERC20(address(0x1234567890123456789012345678901234567890));
    
    /// @notice Test address used for testing (currently unused but available for future tests)
    address internal constant TEST_ADDRESS = address(0xABCDEFABCDEFABCDEFABCDEFABCDEFABCDEFABCD);

    /// @notice Test revertTooMuchSlippage function with valid parameters
    /// @dev Verifies that the TooMuchSlippage error is correctly encoded and reverted
    ///      when actual buy amount is less than expected (indicating slippage)
    function testRevertTooMuchSlippage() public {
        uint256 expectedBuyAmount = 1000e18;
        uint256 actualBuyAmount = 900e18; // Less than expected (slippage)

        vm.expectRevert(
            abi.encodeWithSignature(
                "TooMuchSlippage(address,uint256,uint256)", TEST_TOKEN, expectedBuyAmount, actualBuyAmount
            )
        );

        revertTooMuchSlippage(TEST_TOKEN, expectedBuyAmount, actualBuyAmount);
    }

    /// @notice Test revertTooMuchSlippage with zero expected amount
    /// @dev Edge case: Tests error handling when expected amount is zero
    ///      This scenario can occur in certain edge cases or initialization states
    function testRevertTooMuchSlippageZeroExpected() public {
        uint256 expectedBuyAmount = 0;
        uint256 actualBuyAmount = 100e18;

        vm.expectRevert(
            abi.encodeWithSignature(
                "TooMuchSlippage(address,uint256,uint256)", TEST_TOKEN, expectedBuyAmount, actualBuyAmount
            )
        );

        revertTooMuchSlippage(TEST_TOKEN, expectedBuyAmount, actualBuyAmount);
    }

    /// @notice Test revertTooMuchSlippage with maximum uint256 values
    /// @dev Boundary test: Verifies error handling works correctly with maximum possible values
    ///      Ensures no overflow issues when dealing with extreme amounts
    function testRevertTooMuchSlippageMaxValues() public {
        uint256 expectedBuyAmount = type(uint256).max;
        uint256 actualBuyAmount = type(uint256).max - 1;

        vm.expectRevert(
            abi.encodeWithSignature(
                "TooMuchSlippage(address,uint256,uint256)", TEST_TOKEN, expectedBuyAmount, actualBuyAmount
            )
        );

        revertTooMuchSlippage(TEST_TOKEN, expectedBuyAmount, actualBuyAmount);
    }

    /// @notice Test revertActionInvalid with valid parameters
    /// @dev Verifies that ActionInvalid error is correctly encoded with action index, selector, and data
    ///      This error is thrown when an unrecognized action is encountered during settlement
    function testRevertActionInvalid() public {
        uint256 i = 5; // Action index in the actions array
        bytes4 action = bytes4(0x12345678); // Invalid action selector
        bytes memory data = abi.encode("test data"); // Action calldata

        vm.expectRevert(
            abi.encodeWithSignature("ActionInvalid(uint256,bytes4,bytes)", i, action, data)
        );

        revertActionInvalid(i, uint256(uint32(action)), data);
    }

    /// @notice Test revertActionInvalid with empty data
    /// @dev Edge case: Tests error handling when action data is empty
    ///      Some actions may have no additional data beyond the selector
    function testRevertActionInvalidEmptyData() public {
        uint256 i = 0;
        bytes4 action = bytes4(0x00000000);
        bytes memory data = "";

        vm.expectRevert(
            abi.encodeWithSignature("ActionInvalid(uint256,bytes4,bytes)", i, action, data)
        );

        revertActionInvalid(i, uint256(uint32(action)), data);
    }

    /// @notice Test revertActionInvalid with large data
    /// @dev Boundary test: Verifies error encoding works correctly with large data payloads
    ///      Ensures the error encoding handles dynamic bytes arrays of significant size
    function testRevertActionInvalidLargeData() public {
        uint256 i = 100; // Action index
        bytes4 action = bytes4(0xFFFFFFFF); // Action selector
        bytes memory data = new bytes(1000); // Large data payload
        // Fill data with pattern to ensure all bytes are tested
        for (uint256 j = 0; j < 1000; j++) {
            data[j] = bytes1(uint8(j % 256));
        }

        vm.expectRevert(
            abi.encodeWithSignature("ActionInvalid(uint256,bytes4,bytes)", i, action, data)
        );

        revertActionInvalid(i, uint256(uint32(action)), data);
    }

    /// @notice Test revertUnknownForkId with valid fork ID
    /// @dev Tests error handling for unknown UniswapV3 fork ID
    ///      Fork ID 255 represents the maximum uint8 value
    function testRevertUnknownForkId() public {
        uint8 forkId = 255; // Maximum uint8 value

        vm.expectRevert(
            abi.encodeWithSignature("UnknownForkId(uint8)", forkId)
        );

        revertUnknownForkId(forkId);
    }

    /// @notice Test revertUnknownForkId with zero fork ID
    /// @dev Edge case: Tests error handling when fork ID is zero
    ///      Zero is a valid but potentially uninitialized fork ID
    function testRevertUnknownForkIdZero() public {
        uint8 forkId = 0;

        vm.expectRevert(
            abi.encodeWithSignature("UnknownForkId(uint8)", forkId)
        );

        revertUnknownForkId(forkId);
    }

    /// @notice Test revertConfusedDeputy function
    /// @dev Tests the ConfusedDeputy error which prevents calling restricted targets
    ///      This is a security-critical error that prevents certain attack vectors
    function testRevertConfusedDeputy() public {
        vm.expectRevert(
            abi.encodeWithSignature("ConfusedDeputy()")
        );

        revertConfusedDeputy();
    }

    /// @notice Fuzz test for revertTooMuchSlippage
    /// @dev Comprehensive fuzz testing with various token addresses and amount combinations
    ///      Ensures error handling works correctly across a wide range of inputs
    /// @param token The token address to test with
    /// @param expected The expected buy amount
    /// @param actual The actual buy amount received
    function testFuzzRevertTooMuchSlippage(
        address token,
        uint256 expected,
        uint256 actual
    ) public {
        vm.assume(expected != actual); // Ensure they're different for meaningful test

        vm.expectRevert(
            abi.encodeWithSignature("TooMuchSlippage(address,uint256,uint256)", IERC20(token), expected, actual)
        );

        revertTooMuchSlippage(IERC20(token), expected, actual);
    }

    /// @notice Fuzz test for revertActionInvalid
    /// @dev Comprehensive fuzz testing with various action indices, selectors, and data payloads
    ///      Tests error encoding with different data sizes and patterns
    /// @param i The action index in the actions array
    /// @param action The action selector (4 bytes)
    /// @param data The action calldata (variable length)
    function testFuzzRevertActionInvalid(
        uint256 i,
        bytes4 action,
        bytes memory data
    ) public {
        vm.expectRevert(
            abi.encodeWithSignature("ActionInvalid(uint256,bytes4,bytes)", i, action, data)
        );

        revertActionInvalid(i, uint256(uint32(action)), data);
    }

    /// @notice Fuzz test for revertUnknownForkId
    /// @dev Comprehensive fuzz testing with all possible uint8 fork ID values
    ///      Ensures error handling works for any fork ID value
    /// @param forkId The fork ID to test (0-255)
    function testFuzzRevertUnknownForkId(uint8 forkId) public {
        vm.expectRevert(
            abi.encodeWithSignature("UnknownForkId(uint8)", forkId)
        );

        revertUnknownForkId(forkId);
    }

    /// @notice Test that error selectors match expected values
    /// @dev Verifies that error selectors are correct and haven't changed
    ///      This is important for off-chain error decoding and monitoring systems
    ///      Selector values are derived from the error signature keccak256 hash
    function testErrorSelectors() public {
        // Test TooMuchSlippage selector - first 4 bytes of keccak256("TooMuchSlippage(address,uint256,uint256)")
        bytes4 tooMuchSlippageSelector = TooMuchSlippage.selector;
        assertEq(tooMuchSlippageSelector, bytes4(0x97a6f3b9), "TooMuchSlippage selector mismatch");

        // Test ActionInvalid selector - first 4 bytes of keccak256("ActionInvalid(uint256,bytes4,bytes)")
        bytes4 actionInvalidSelector = ActionInvalid.selector;
        assertEq(actionInvalidSelector, bytes4(0x3c74eed6), "ActionInvalid selector mismatch");

        // Test UnknownForkId selector - first 4 bytes of keccak256("UnknownForkId(uint8)")
        bytes4 unknownForkIdSelector = UnknownForkId.selector;
        assertEq(unknownForkIdSelector, bytes4(0xd3b1276d), "UnknownForkId selector mismatch");

        // Test ConfusedDeputy selector - first 4 bytes of keccak256("ConfusedDeputy()")
        bytes4 confusedDeputySelector = ConfusedDeputy.selector;
        assertEq(confusedDeputySelector, bytes4(0xe758b8d5), "ConfusedDeputy selector mismatch");
    }
}

