# Contributing to 0x Settler

Thank you for your interest in contributing to 0x Settler! This guide will help you get started.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Making Changes](#making-changes)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Code Style](#code-style)
- [Good First Issues](#good-first-issues)

## Code of Conduct

This project adheres to a code of conduct. By participating, you are expected to uphold this code.

## Getting Started

1. **Fork the repository**
   ```bash
   git clone https://github.com/mukminn/0x-settler.git
   cd 0x-settler
   ```

2. **Set up upstream remote**
   ```bash
   git remote add upstream https://github.com/0xProject/0x-settler.git
   ```

3. **Create a branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation)
- Node.js and npm
- Git

### Installation

```bash
# Install Foundry dependencies
forge install

# Install npm dependencies
npm install
```

### Environment Setup

1. Copy `api_secrets.json.template` to `api_secrets.json`
2. Add your RPC URLs and API keys
3. Copy `secrets.json.template` to `secrets.json` (if deploying)

## Making Changes

### Before You Start

1. **Read the documentation**
   - [README.md](../README.md) - Project overview
   - [CLAUDE.md](../CLAUDE.md) - Development guidelines
   - [TESTING.md](TESTING.md) - Testing documentation

2. **Check existing issues**
   - Look for existing issues or discussions
   - Comment on issues you want to work on

3. **Start small**
   - Fix typos or documentation
   - Add test cases
   - Improve error messages

### Code Style

Follow the existing code style:

- Use `forge fmt` to format code
- Follow Solidity style guide
- Use custom errors instead of require statements
- Mark assembly blocks as `memory-safe` when appropriate

### Commit Messages

Use clear, descriptive commit messages:

```
fix: correct typos in README
test: add comprehensive error handling tests
docs: add testing documentation
```

Prefixes:
- `fix:` - Bug fixes
- `feat:` - New features
- `test:` - Test additions/changes
- `docs:` - Documentation changes
- `refactor:` - Code refactoring
- `style:` - Code style changes

## Testing

### Running Tests

```bash
# Run all unit tests
forge test

# Run integration tests
FOUNDRY_PROFILE=integration forge test

# Run specific test
forge test --match-test testName

# Run with gas report
forge test --gas-report
```

### Writing Tests

1. **Follow existing patterns**
   - Use `Utils` contract for helpers
   - Use `abi.encodeWithSignature` for error expectations
   - Follow naming conventions

2. **Test coverage**
   - Test happy paths
   - Test edge cases
   - Test error conditions
   - Add fuzz tests when appropriate

3. **See [TESTING.md](TESTING.md) for detailed testing guidelines**

## Submitting Changes

### Before Submitting

1. **Run tests**
   ```bash
   forge test
   FOUNDRY_PROFILE=integration forge test
   ```

2. **Check formatting**
   ```bash
   forge fmt --check
   ```

3. **Check gas impact** (if applicable)
   ```bash
   npm run diff:main
   ```

4. **Update documentation** (if needed)

### Pull Request Process

1. **Create a Pull Request**
   - Use a clear, descriptive title
   - Reference related issues
   - Include a detailed description

2. **PR Description Template**
   ```markdown
   ## Description
   Brief description of changes

   ## Changes
   - Change 1
   - Change 2

   ## Testing
   - How to test
   - Test results

   ## Gas Impact
   - Before: X gas
   - After: Y gas
   - Impact: +/- Z gas
   ```

3. **Wait for Review**
   - Address review comments
   - Make requested changes
   - Keep PR updated with main branch

## Code Style

### Solidity

- Use Solidity 0.8.25 (or version specified in file)
- Use `unchecked` blocks for safe arithmetic
- Prefer `calldata` over `memory` for function arguments
- Use custom errors instead of require statements

### Error Handling

```solidity
// ✅ Good
if (amount == 0) revert ZeroAmount();

// ❌ Bad
require(amount > 0, "Amount must be positive");
```

### Assembly

- Mark assembly blocks as `memory-safe` when appropriate
- Document complex assembly operations
- Follow existing assembly patterns

## Good First Issues

Looking for a place to start? Check out:

- [GOOD_FIRST_ISSUES.md](../GOOD_FIRST_ISSUES.md) - Guide to good first issues
- GitHub Issues with `good first issue` label
- Documentation improvements
- Test coverage improvements

### Beginner-Friendly Tasks

1. **Documentation**
   - Fix typos
   - Improve clarity
   - Add examples

2. **Testing**
   - Add unit tests
   - Add edge case tests
   - Improve test coverage

3. **Code Quality**
   - Refactor small functions
   - Improve error messages
   - Add comments

## Resources

- [0x Settler README](../README.md)
- [Development Guidelines](../CLAUDE.md)
- [Testing Documentation](TESTING.md)
- [Good First Issues Guide](../GOOD_FIRST_ISSUES.md)
- [Foundry Documentation](https://book.getfoundry.sh/)
- [Solidity Documentation](https://docs.soliditylang.org/)

## Questions?

- Open a GitHub Discussion
- Comment on relevant issues
- Review existing PRs for examples

Thank you for contributing! 🎉

