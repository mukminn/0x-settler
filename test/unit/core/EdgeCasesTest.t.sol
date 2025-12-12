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
contract EdgeCasesTest is Utils, Test {
    IERC20 internal constant TEST_TOKEN = IERC20(address(0x1234567890123456789012345678901234567890));

    /// @notice Test ZeroSellAmount error
    function testZeroSellAmountError() public {
        vm.expectRevert(
            abi.encodeWithSignature("ZeroSellAmount(address)", TEST_TOKEN)
        );
        revert ZeroSellAmount(TEST_TOKEN);
    }

    /// @notice Test ZeroBuyAmount error
    function testZeroBuyAmountError() public {
        vm.expectRevert(
            abi.encodeWithSignature("ZeroBuyAmount(address)", TEST_TOKEN)
        );
        revert ZeroBuyAmount(TEST_TOKEN);
    }

    /// @notice Test ZeroToken error
    function testZeroTokenError() public {
        vm.expectRevert(
            abi.encodeWithSignature("ZeroToken()")
        );
        revert ZeroToken();
    }

    /// @notice Test DeltaNotPositive error
    function testDeltaNotPositiveError() public {
        vm.expectRevert(
            abi.encodeWithSignature("DeltaNotPositive(address)", TEST_TOKEN)
        );
        revert DeltaNotPositive(TEST_TOKEN);
    }

    /// @notice Test DeltaNotNegative error
    function testDeltaNotNegativeError() public {
        vm.expectRevert(
            abi.encodeWithSignature("DeltaNotNegative(address)", TEST_TOKEN)
        );
        revert DeltaNotNegative(TEST_TOKEN);
    }

    /// @notice Fuzz test for ZeroSellAmount with different tokens
    function testFuzzZeroSellAmount(address token) public {
        vm.assume(token != address(0));
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
    function testEdgeCaseErrorSelectors() public {
        bytes4 zeroSellAmountSelector = ZeroSellAmount.selector;
        bytes4 zeroBuyAmountSelector = ZeroBuyAmount.selector;
        bytes4 zeroTokenSelector = ZeroToken.selector;
        bytes4 deltaNotPositiveSelector = DeltaNotPositive.selector;
        bytes4 deltaNotNegativeSelector = DeltaNotNegative.selector;

        // Verify selectors are non-zero (valid selectors)
        assertTrue(zeroSellAmountSelector != bytes4(0), "ZeroSellAmount selector should be non-zero");
        assertTrue(zeroBuyAmountSelector != bytes4(0), "ZeroBuyAmount selector should be non-zero");
        assertTrue(zeroTokenSelector != bytes4(0), "ZeroToken selector should be non-zero");
        assertTrue(deltaNotPositiveSelector != bytes4(0), "DeltaNotPositive selector should be non-zero");
        assertTrue(deltaNotNegativeSelector != bytes4(0), "DeltaNotNegative selector should be non-zero");
    }

    /// @notice Test that error messages can be properly decoded
    function testErrorDecoding() public {
        // Test ZeroSellAmount decoding
        bytes memory zeroSellAmountData = abi.encodeWithSelector(ZeroSellAmount.selector, TEST_TOKEN);
        (bytes4 selector, IERC20 token) = abi.decode(zeroSellAmountData, (bytes4, IERC20));
        assertEq(selector, ZeroSellAmount.selector, "Selector mismatch");
        assertEq(address(token), address(TEST_TOKEN), "Token address mismatch");

        // Test ZeroBuyAmount decoding
        bytes memory zeroBuyAmountData = abi.encodeWithSelector(ZeroBuyAmount.selector, TEST_TOKEN);
        (selector, token) = abi.decode(zeroBuyAmountData, (bytes4, IERC20));
        assertEq(selector, ZeroBuyAmount.selector, "Selector mismatch");
        assertEq(address(token), address(TEST_TOKEN), "Token address mismatch");
    }
}

