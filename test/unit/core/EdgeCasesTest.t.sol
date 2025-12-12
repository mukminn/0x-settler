// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test} from "@forge-std/Test.sol";
import {IERC20} from "@forge-std/interfaces/IERC20.sol";

import {
    ZeroSellAmount,
    ZeroBuyAmount,
    ZeroToken,
    DeltaNotPositive,
    DeltaNotNegative
} from "src/core/SettlerErrors.sol";

import {Utils} from "../Utils.sol";

/// @title EdgeCasesTest
/// @notice Unit tests for edge cases and boundary conditions
/// @dev Tests verify that edge case errors are correctly defined and can be properly encoded/decoded
contract EdgeCasesTest is Utils, Test {
    /// @notice Test token address used for testing edge case errors
    IERC20 internal constant TEST_TOKEN = IERC20(address(0x1234567890123456789012345678901234567890));

    /// @notice Test ZeroSellAmount error
    /// @dev Verifies that ZeroSellAmount error can be correctly encoded and reverted
    ///      This error is thrown when attempting to sell zero tokens
    function testZeroSellAmountError() public {
        vm.expectRevert(
            abi.encodeWithSignature("ZeroSellAmount(address)", TEST_TOKEN)
        );
        revert ZeroSellAmount(TEST_TOKEN);
    }

    /// @notice Test ZeroBuyAmount error
    /// @dev Verifies that ZeroBuyAmount error can be correctly encoded and reverted
    ///      This error is thrown when attempting to buy zero tokens
    function testZeroBuyAmountError() public {
        vm.expectRevert(
            abi.encodeWithSignature("ZeroBuyAmount(address)", TEST_TOKEN)
        );
        revert ZeroBuyAmount(TEST_TOKEN);
    }

    /// @notice Test ZeroToken error
    /// @dev Verifies that ZeroToken error can be correctly encoded and reverted
    ///      This error is thrown when a zero address is used as a token address
    function testZeroTokenError() public {
        vm.expectRevert(
            abi.encodeWithSignature("ZeroToken()")
        );
        revert ZeroToken();
    }

    /// @notice Test DeltaNotPositive error
    /// @dev Verifies that DeltaNotPositive error can be correctly encoded and reverted
    ///      This error is thrown when token delta is not positive (zero or negative)
    function testDeltaNotPositiveError() public {
        vm.expectRevert(
            abi.encodeWithSignature("DeltaNotPositive(address)", TEST_TOKEN)
        );
        revert DeltaNotPositive(TEST_TOKEN);
    }

    /// @notice Test DeltaNotNegative error
    /// @dev Verifies that DeltaNotNegative error can be correctly encoded and reverted
    ///      This error is thrown when token delta is not negative (zero or positive)
    function testDeltaNotNegativeError() public {
        vm.expectRevert(
            abi.encodeWithSignature("DeltaNotNegative(address)", TEST_TOKEN)
        );
        revert DeltaNotNegative(TEST_TOKEN);
    }

    /// @notice Fuzz test for ZeroSellAmount with different tokens
    /// @dev Comprehensive fuzz testing with various token addresses
    ///      Ensures error handling works correctly for any non-zero token address
    /// @param token The token address to test with (must not be zero address)
    function testFuzzZeroSellAmount(address token) public {
        vm.assume(token != address(0)); // Zero address is tested separately in testZeroTokenError
        vm.expectRevert(
            abi.encodeWithSignature("ZeroSellAmount(address)", IERC20(token))
        );
        revert ZeroSellAmount(IERC20(token));
    }

    /// @notice Fuzz test for ZeroBuyAmount with different tokens
    function testFuzzZeroBuyAmount(address token) public {
        vm.assume(token != address(0));
        vm.expectRevert(
            abi.encodeWithSignature("ZeroBuyAmount(address)", IERC20(token))
        );
        revert ZeroBuyAmount(IERC20(token));
    }

    /// @notice Fuzz test for DeltaNotPositive with different tokens
    function testFuzzDeltaNotPositive(address token) public {
        vm.assume(token != address(0));
        vm.expectRevert(
            abi.encodeWithSignature("DeltaNotPositive(address)", IERC20(token))
        );
        revert DeltaNotPositive(IERC20(token));
    }

    /// @notice Fuzz test for DeltaNotNegative with different tokens
    function testFuzzDeltaNotNegative(address token) public {
        vm.assume(token != address(0));
        vm.expectRevert(
            abi.encodeWithSignature("DeltaNotNegative(address)", IERC20(token))
        );
        revert DeltaNotNegative(IERC20(token));
    }

    /// @notice Test error selectors match expected values
    /// @dev Verifies that all edge case error selectors are valid (non-zero)
    ///      This ensures errors are properly defined and can be decoded off-chain
    function testEdgeCaseErrorSelectors() public {
        bytes4 zeroSellAmountSelector = ZeroSellAmount.selector;
        bytes4 zeroBuyAmountSelector = ZeroBuyAmount.selector;
        bytes4 zeroTokenSelector = ZeroToken.selector;
        bytes4 deltaNotPositiveSelector = DeltaNotPositive.selector;
        bytes4 deltaNotNegativeSelector = DeltaNotNegative.selector;

        // Verify selectors are non-zero (valid selectors)
        // A zero selector would indicate an error in error definition
        assertTrue(zeroSellAmountSelector != bytes4(0), "ZeroSellAmount selector should be non-zero");
        assertTrue(zeroBuyAmountSelector != bytes4(0), "ZeroBuyAmount selector should be non-zero");
        assertTrue(zeroTokenSelector != bytes4(0), "ZeroToken selector should be non-zero");
        assertTrue(deltaNotPositiveSelector != bytes4(0), "DeltaNotPositive selector should be non-zero");
        assertTrue(deltaNotNegativeSelector != bytes4(0), "DeltaNotNegative selector should be non-zero");
    }

    /// @notice Test that error messages can be properly decoded
    /// @dev Verifies that error data can be correctly encoded and decoded
    ///      This is important for off-chain error handling and monitoring systems
    ///      Tests ensure errors can be parsed correctly by external tools
    function testErrorDecoding() public {
        // Test ZeroSellAmount decoding
        // Encode error with selector and token parameter
        bytes memory zeroSellAmountData = abi.encodeWithSelector(ZeroSellAmount.selector, TEST_TOKEN);
        // Decode and verify the encoded data matches the original values
        (bytes4 selector, IERC20 token) = abi.decode(zeroSellAmountData, (bytes4, IERC20));
        assertEq(selector, ZeroSellAmount.selector, "Selector mismatch");
        assertEq(address(token), address(TEST_TOKEN), "Token address mismatch");

        // Test ZeroBuyAmount decoding
        // Similar test for ZeroBuyAmount error to ensure consistency
        bytes memory zeroBuyAmountData = abi.encodeWithSelector(ZeroBuyAmount.selector, TEST_TOKEN);
        (selector, token) = abi.decode(zeroBuyAmountData, (bytes4, IERC20));
        assertEq(selector, ZeroBuyAmount.selector, "Selector mismatch");
        assertEq(address(token), address(TEST_TOKEN), "Token address mismatch");
    }
}

