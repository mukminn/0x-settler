# Library Usage Examples

This document provides practical examples of how to use the utility libraries in the 0x Settler codebase.

## Table of Contents

- [UnsafeMath Library](#unsafemath-library)
- [Ternary Library](#ternary-library)
- [FastLogic Library](#fastlogic-library)
- [512Math Library](#512math-library)
- [Other Utilities](#other-utilities)

## UnsafeMath Library

The `UnsafeMath` library provides gas-optimized arithmetic operations without overflow checks. **Use with caution** - only when you're certain overflow won't occur.

### Import and Using Statement

```solidity
import {UnsafeMath} from "src/utils/UnsafeMath.sol";

contract MyContract {
    using UnsafeMath for uint256;
    using UnsafeMath for int256;
    
    // Your contract code
}
```

### Basic Arithmetic Operations

```solidity
contract ExampleUnsafeMath {
    using UnsafeMath for uint256;
    using UnsafeMath for int256;
    
    /// @notice Increment a value by 1
    function increment(uint256 x) public pure returns (uint256) {
        return x.unsafeInc(); // Equivalent to x + 1 (unchecked)
    }
    
    /// @notice Decrement a value by 1
    function decrement(uint256 x) public pure returns (uint256) {
        return x.unsafeDec(); // Equivalent to x - 1 (unchecked)
    }
    
    /// @notice Conditional increment (add 1 if condition is true)
    function conditionalIncrement(uint256 x, bool shouldIncrement) public pure returns (uint256) {
        return x.unsafeInc(shouldIncrement);
    }
    
    /// @notice Add two numbers
    function add(uint256 a, uint256 b) public pure returns (uint256) {
        return a.unsafeAdd(b);
    }
    
    /// @notice Divide two numbers (no zero check!)
    function divide(uint256 numerator, uint256 denominator) public pure returns (uint256) {
        // WARNING: This will revert on division by zero
        return numerator.unsafeDiv(denominator);
    }
    
    /// @notice Get absolute value of signed integer
    function absolute(int256 x) public pure returns (uint256) {
        return x.unsafeAbs();
    }
    
    /// @notice Ceiling division (rounds up)
    function divideUp(uint256 n, uint256 d) public pure returns (uint256) {
        // Returns ceil(n/d)
        return n.unsafeDivUp(d);
    }
}
```

### Real-World Example from Codebase

```solidity
// From src/core/Basic.sol
using UnsafeMath for uint256;

function calculateAmount(uint256 balance, uint256 bps) internal pure returns (uint256) {
    // Calculate percentage of balance using basis points
    // balance.unsafeDiv(BASIS) is safe because BASIS is constant (10000)
    return balance.unsafeDiv(BASIS).unsafeMul(bps);
}
```

## Ternary Library

The `Ternary` library provides gas-optimized conditional operations using bitwise operations instead of if/else statements.

### Import and Using Statement

```solidity
import {Ternary} from "src/utils/Ternary.sol";

contract MyContract {
    using Ternary for bool;
    
    // Your contract code
}
```

### Basic Ternary Operations

```solidity
contract ExampleTernary {
    using Ternary for bool;
    
    /// @notice Select value based on condition (condition ? x : y)
    function selectValue(bool condition, uint256 x, uint256 y) public pure returns (uint256) {
        return condition.ternary(x, y);
    }
    
    /// @notice Select address based on condition
    function selectAddress(bool useFirst, address addr1, address addr2) public pure returns (address) {
        return useFirst.ternary(addr1, addr2);
    }
    
    /// @notice Return value if condition is true, otherwise zero
    function orZero(bool condition, uint256 value) public pure returns (uint256) {
        return condition.orZero(value);
    }
    
    /// @notice Conditionally swap two values
    function maybeSwap(bool shouldSwap, uint256 a, uint256 b) public pure returns (uint256, uint256) {
        // If shouldSwap is true, returns (b, a), otherwise (a, b)
        return shouldSwap.maybeSwap(a, b);
    }
}
```

### Real-World Example from Codebase

```solidity
// From src/core/UniswapV2.sol
using Ternary for bool;

function determineSwapDirection(IERC20 token0, IERC20 token1) internal pure returns (bool) {
    // Returns true if token0 < token1 (lexicographic order)
    return (token0 < token1).ternary(true, false);
}

function selectPoolAddress(bool zeroForOne, address pool0, address pool1) internal pure returns (address) {
    return zeroForOne.ternary(pool0, pool1);
}
```

## FastLogic Library

The `FastLogic` library provides gas-optimized boolean operations using assembly.

### Import and Using Statement

```solidity
import {FastLogic} from "src/utils/FastLogic.sol";

contract MyContract {
    using FastLogic for bool;
    
    // Your contract code
}
```

### Boolean Operations

```solidity
contract ExampleFastLogic {
    using FastLogic for bool;
    
    /// @notice Logical OR operation
    function logicalOr(bool a, bool b) public pure returns (bool) {
        return a.or(b);
    }
    
    /// @notice Logical AND operation
    function logicalAnd(bool a, bool b) public pure returns (bool) {
        return a.and(b);
    }
    
    /// @notice AND NOT operation (a && !b)
    function andNot(bool a, bool b) public pure returns (bool) {
        return a.andNot(b);
    }
    
    /// @notice Convert boolean to uint256 (true = 1, false = 0)
    function boolToUint(bool b) public pure returns (uint256) {
        return b.toUint();
    }
    
    /// @notice Complex boolean logic example
    function complexLogic(bool condition1, bool condition2, bool condition3) public pure returns (bool) {
        // Equivalent to: (condition1 || condition2) && !condition3
        return condition1.or(condition2).andNot(condition3);
    }
}
```

### Real-World Example from Codebase

```solidity
// From src/core/Permit2Payment.sol
using FastLogic for bool;

function validateConditions(bool isValid, bool isAllowed, bool isNotPaused) internal pure returns (bool) {
    // All conditions must be true
    return isValid.and(isAllowed).and(isNotPaused);
}
```

## 512Math Library

The `512Math` library provides 512-bit arithmetic operations for handling very large numbers.

### Import and Using Statement

```solidity
import {uint512} from "src/utils/512Math.sol";

contract MyContract {
    // uint512 is a global type with built-in operations
    
    // Your contract code
}
```

### 512-bit Arithmetic

```solidity
contract Example512Math {
    /// @notice Create 512-bit number from 256-bit value
    function create512(uint256 value) public pure returns (uint512) {
        return uint512.from(value);
    }
    
    /// @notice Create 512-bit number from two 256-bit values
    function create512FromTwo(uint256 high, uint256 low) public pure returns (uint512) {
        return uint512.from(high, low);
    }
    
    /// @notice Add two 512-bit numbers
    function add512(uint512 a, uint512 b) public pure returns (uint512) {
        return a + b; // Uses operator overloading
    }
    
    /// @notice Multiply two 256-bit numbers to get 512-bit result
    function multiply256(uint256 a, uint256 b) public pure returns (uint512) {
        return uint512.omul(a, b);
    }
    
    /// @notice Compare 512-bit numbers
    function compare512(uint512 a, uint512 b) public pure returns (bool) {
        return a > b; // Uses operator overloading
    }
    
    /// @notice Extract 256-bit value from 512-bit number
    function extract256(uint512 value) public pure returns (uint256, uint256) {
        return value.into(); // Returns (high, low)
    }
}
```

### Real-World Example

```solidity
// Used in complex mathematical calculations where intermediate results
// might exceed uint256 range
function calculateLargeProduct(uint256 a, uint256 b, uint256 c) public pure returns (uint256) {
    // Calculate a * b * c without overflow
    uint512 product = uint512.omul(a, b);
    product = product * uint512.from(c);
    
    // Extract result (assuming it fits in uint256)
    (uint256 high, uint256 low) = product.into();
    require(high == 0, "Result exceeds uint256");
    return low;
}
```

## Other Utilities

### Revert Library

```solidity
import {Revert} from "src/utils/Revert.sol";

contract ExampleRevert {
    function conditionalRevert(bool shouldRevert, bytes memory reason) public pure {
        Revert.maybeRevert(shouldRevert, reason);
    }
}
```

### Panic Library

```solidity
import {Panic} from "src/utils/Panic.sol";

contract ExamplePanic {
    function checkDivision(uint256 numerator, uint256 denominator) public pure returns (uint256) {
        if (denominator == 0) {
            Panic.panic(Panic.DIVISION_BY_ZERO);
        }
        return numerator / denominator;
    }
}
```

### AddressDerivation Library

```solidity
import {AddressDerivation} from "src/utils/AddressDerivation.sol";

contract ExampleAddressDerivation {
    function deriveAddress(address deployer, bytes32 salt, bytes32 initCodeHash) 
        public 
        pure 
        returns (address) 
    {
        return AddressDerivation.deriveCreate2Address(deployer, salt, initCodeHash);
    }
}
```

## Best Practices

### 1. When to Use UnsafeMath

✅ **Use when:**
- You've verified overflow won't occur
- Working with constants or bounded values
- Gas optimization is critical
- In tight loops with many operations

❌ **Don't use when:**
- Accepting arbitrary user input
- Values can exceed expected ranges
- Security is more important than gas

### 2. When to Use Ternary

✅ **Use when:**
- Simple conditional value selection
- Gas optimization is important
- Code clarity isn't significantly reduced

❌ **Don't use when:**
- Complex conditional logic
- Code readability is more important
- Multiple nested conditions

### 3. When to Use FastLogic

✅ **Use when:**
- Multiple boolean operations
- Gas optimization is critical
- Working with boolean flags

### 4. When to Use 512Math

✅ **Use when:**
- Intermediate calculations might exceed uint256
- Working with very large numbers
- Need precise calculations without overflow

## Complete Example

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {UnsafeMath} from "src/utils/UnsafeMath.sol";
import {Ternary} from "src/utils/Ternary.sol";
import {FastLogic} from "src/utils/FastLogic.sol";

contract CompleteExample {
    using UnsafeMath for uint256;
    using Ternary for bool;
    using FastLogic for bool;
    
    /// @notice Calculate fee based on amount and fee rate
    /// @param amount The base amount
    /// @param feeBps Fee in basis points (10000 = 100%)
    /// @param applyFee Whether to apply the fee
    function calculateFee(
        uint256 amount,
        uint256 feeBps,
        bool applyFee
    ) public pure returns (uint256) {
        // Use ternary to conditionally apply fee
        uint256 feeAmount = applyFee.orZero(amount.unsafeDiv(10000).unsafeMul(feeBps));
        
        // Return amount minus fee
        return amount.unsafeSub(feeAmount);
    }
    
    /// @notice Select pool based on swap direction
    /// @param zeroForOne Swap direction
    /// @param pool0 First pool address
    /// @param pool1 Second pool address
    function selectPool(
        bool zeroForOne,
        address pool0,
        address pool1
    ) public pure returns (address) {
        return zeroForOne.ternary(pool0, pool1);
    }
    
    /// @notice Validate multiple conditions
    /// @param isValid Whether the operation is valid
    /// @param isAllowed Whether the operation is allowed
    /// @param isNotPaused Whether the contract is not paused
    function validate(
        bool isValid,
        bool isAllowed,
        bool isNotPaused
    ) public pure returns (bool) {
        return isValid.and(isAllowed).and(isNotPaused);
    }
}
```

## Testing Library Usage

When testing contracts that use these libraries:

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {Test} from "@forge-std/Test.sol";
import {CompleteExample} from "../src/CompleteExample.sol";

contract CompleteExampleTest is Test {
    CompleteExample example;
    
    function setUp() public {
        example = new CompleteExample();
    }
    
    function testCalculateFee() public {
        uint256 amount = 1000e18;
        uint256 feeBps = 100; // 1%
        bool applyFee = true;
        
        uint256 result = example.calculateFee(amount, feeBps, applyFee);
        assertEq(result, 990e18); // 1000 - 10 = 990
    }
    
    function testSelectPool() public {
        address pool0 = address(0x1111);
        address pool1 = address(0x2222);
        
        address result = example.selectPool(true, pool0, pool1);
        assertEq(result, pool0);
        
        result = example.selectPool(false, pool0, pool1);
        assertEq(result, pool1);
    }
}
```

## Resources

- [UnsafeMath Source](../src/utils/UnsafeMath.sol)
- [Ternary Source](../src/utils/Ternary.sol)
- [FastLogic Source](../src/utils/FastLogic.sol)
- [512Math Source](../src/utils/512Math.sol)
- [Solidity Documentation](https://docs.soliditylang.org/)

