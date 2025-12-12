# Testing Documentation

This document provides comprehensive information about testing in the 0x Settler codebase.

## Table of Contents

- [Overview](#overview)
- [Test Structure](#test-structure)
- [Running Tests](#running-tests)
- [Writing Tests](#writing-tests)
- [Test Categories](#test-categories)
- [Error Handling Tests](#error-handling-tests)
- [Best Practices](#best-practices)

## Overview

The 0x Settler project uses [Foundry](https://book.getfoundry.sh/) as its testing framework. All tests are written in Solidity and follow specific patterns established in the codebase.

## Test Structure

Tests are organized into three main directories:

```
test/
├── unit/           # Unit tests for individual components
├── integration/    # Integration tests with forked mainnet state
└── utils/          # Testing utilities and helpers
```

### Unit Tests

Unit tests (`test/unit/`) test individual components in isolation:
- Error handling functions
- Utility functions
- Core logic without external dependencies
- Edge cases and boundary conditions

### Integration Tests

Integration tests (`test/integration/`) test the full system with real blockchain state:
- Fork tests against mainnet
- DEX integration tests
- End-to-end swap flows
- Gas snapshots

## Running Tests

### Basic Commands

```bash
# Run all unit tests
forge test

# Run all integration tests
FOUNDRY_PROFILE=integration forge test

# Run specific test file
forge test --match-path test/unit/core/SettlerErrorsTest.t.sol

# Run specific test function
forge test --match-test testRevertTooMuchSlippage

# Run with verbose output
forge test -vvv

# Run with gas reporting
forge test --gas-report
```

### Test Profiles

The project uses Foundry profiles defined in `foundry.toml`:

- **default**: Unit tests (excludes integration tests)
- **integration**: Integration tests (excludes unit tests)

## Writing Tests

### Test File Naming

Test files should follow the pattern: `<ContractName>Test.t.sol` or `<Feature>Test.t.sol`

Example:
- `SettlerErrorsTest.t.sol` - Tests for error handling
- `EdgeCasesTest.t.sol` - Tests for edge cases

### Basic Test Structure

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test} from "@forge-std/Test.sol";
import {Utils} from "../Utils.sol";

contract MyTest is Utils, Test {
    function setUp() public {
        // Setup code
    }

    function testSomething() public {
        // Test code
    }
}
```

### Error Testing Pattern

When testing errors, use `abi.encodeWithSignature`:

```solidity
function testError() public {
    vm.expectRevert(
        abi.encodeWithSignature("ErrorName(type1,type2)", param1, param2)
    );
    
    // Code that should revert
    revert ErrorName(param1, param2);
}
```

## Test Categories

### Error Handling Tests

Located in `test/unit/core/SettlerErrorsTest.t.sol`:

- **revertTooMuchSlippage**: Tests slippage error handling
- **revertActionInvalid**: Tests invalid action error handling
- **revertUnknownForkId**: Tests unknown fork ID error handling
- **revertConfusedDeputy**: Tests confused deputy error handling

### Edge Case Tests

Located in `test/unit/core/EdgeCasesTest.t.sol`:

- **ZeroSellAmount**: Tests zero sell amount error
- **ZeroBuyAmount**: Tests zero buy amount error
- **ZeroToken**: Tests zero token error
- **DeltaNotPositive/DeltaNotNegative**: Tests delta validation errors

### Integration Tests

Located in `test/integration/`:

- **Pair Tests**: Test swaps between token pairs (USDC/WETH, DAI/WETH, etc.)
- **DEX Tests**: Test specific DEX integrations (UniswapV2, UniswapV3, Curve, etc.)
- **Settler Tests**: Test different Settler flavors (TakerSubmitted, MetaTxn, Intent)

## Error Handling Tests

### Testing Error Revert Functions

The codebase includes helper functions for reverting with custom errors. These are tested in `SettlerErrorsTest.t.sol`:

```solidity
// Example: Testing TooMuchSlippage error
function testRevertTooMuchSlippage() public {
    uint256 expected = 1000e18;
    uint256 actual = 900e18;
    
    vm.expectRevert(
        abi.encodeWithSignature(
            "TooMuchSlippage(address,uint256,uint256)", 
            token, expected, actual
        )
    );
    
    revertTooMuchSlippage(token, expected, actual);
}
```

### Available Error Revert Functions

1. **revertTooMuchSlippage**: Reverts with `TooMuchSlippage` error
2. **revertActionInvalid**: Reverts with `ActionInvalid` error
3. **revertUnknownForkId**: Reverts with `UnknownForkId` error
4. **revertConfusedDeputy**: Reverts with `ConfusedDeputy` error

## Best Practices

### 1. Use Descriptive Test Names

```solidity
// ✅ Good
function testRevertTooMuchSlippageWithZeroExpected() public { }

// ❌ Bad
function test1() public { }
```

### 2. Test Both Happy Path and Edge Cases

```solidity
function testBasicFunctionality() public {
    // Happy path
}

function testBasicFunctionalityWithZeroInput() public {
    // Edge case
}

function testBasicFunctionalityWithMaxInput() public {
    // Boundary case
}
```

### 3. Use Fuzz Tests for Comprehensive Coverage

```solidity
function testFuzzRevertTooMuchSlippage(
    address token,
    uint256 expected,
    uint256 actual
) public {
    vm.assume(expected != actual);
    // Test with various inputs
}
```

### 4. Follow Existing Patterns

- Use `Utils` contract for helper functions
- Use `abi.encodeWithSignature` for error expectations
- Follow naming conventions from existing tests
- Use `vm.expectRevert` for error testing

### 5. Clean Up Unused Code

- Remove unused imports
- Remove unused constants
- Keep tests focused and minimal

### 6. Document Complex Tests

```solidity
/// @notice Test revertTooMuchSlippage with maximum uint256 values
/// @dev This ensures the error handling works with extreme values
function testRevertTooMuchSlippageMaxValues() public {
    // Test implementation
}
```

## Test Utilities

### Utils Contract

The `Utils` contract (`test/utils/Utils.sol`) provides helper functions:

- `_createNamedRejectionDummy`: Creates a dummy contract that reverts
- `_etchNamedRejectionDummy`: Etches code to a specific address
- `_mockExpectCall`: Sets up mock calls with expectations

### BasePairTest

For integration tests, inherit from `BasePairTest`:

```solidity
contract MyIntegrationTest is BasePairTest {
    function fromToken() internal pure override returns (IERC20) {
        return IERC20(0x...);
    }
    
    function toToken() internal pure override returns (IERC20) {
        return IERC20(0x...);
    }
    
    function amount() internal pure override returns (uint256) {
        return 1000e18;
    }
}
```

## Gas Testing

The project includes gas snapshot functionality:

```bash
# Capture gas baseline
npm run snapshot:main

# Compare with main branch
npm run diff:main

# Compare gas results
npm run compare_gas
```

## CI/CD

Tests run automatically on every PR:

1. Build main contracts
2. Build special contracts (MultiCall, CrossChainReceiverFactory, UniswapV4)
3. Run EulerSwap math tests (solc 0.8.28)
4. Run MultiCall tests
5. Run CrossChainReceiverFactory tests
6. Run all other unit tests
7. Run integration tests (fork tests)
8. Gas comparison

## Resources

- [Foundry Book](https://book.getfoundry.sh/)
- [Foundry Testing](https://book.getfoundry.sh/forge/tests)
- [Solidity Testing Best Practices](https://docs.soliditylang.org/en/latest/testing.html)
- [0x Settler README](../README.md)
- [Development Guidelines](../CLAUDE.md)

