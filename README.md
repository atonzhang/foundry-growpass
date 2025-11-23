# GrowPass - Blockchain Learning Incentive System

GrowPass is a blockchain-based learning incentive system that combines token rewards with NFT achievements to motivate users to complete learning tasks.

## Overview

The system consists of three core smart contracts:

1. **GrowToken.sol**: An ERC20 token contract for rewarding users
2. **GrowPass.sol**: An ERC721 NFT contract representing learning achievements
3. **TaskManager.sol**: A task management system for creating, assigning, and tracking learning tasks

## How It Works

1. Users complete learning tasks registered in the TaskManager
2. Upon task completion, users receive GROW tokens as rewards
3. As users progress, they can mint NFTs (GrowPass) that represent their learning achievements
4. Higher level tasks require higher level NFTs to unlock

## Prerequisites

- [Foundry](https://getfoundry.sh/) - Ethereum development toolkit

## Project Structure

```
├── src/          # Smart contract source files
├── test/         # Test files
├── script/       # Deployment scripts
├── lib/          # Dependencies (forge-std, openzeppelin-contracts)
├── foundry.toml  # Foundry configuration
```

## Getting Started

### Build

Compile the smart contracts:

```shell
$ forge build
```

### Test

Run the test suite:

```shell
$ forge test
```

### Format

Format the code according to Solidity standards:

```shell
$ forge fmt
```

### Gas Snapshots

Generate gas usage snapshots:

```shell
$ forge snapshot
```

### Local Development Node

Start a local Ethereum node for development:

```shell
$ anvil
```

### Deploy

Deploy contracts to a network:

```shell
$ forge script script/Deploy.s.sol:Deploy --rpc-url <your_rpc_url> --private-key <your_private_key>
```

## Core Components

### GrowToken (GROW)

An ERC20 token used to reward users for completing tasks. Only the TaskManager contract can mint new tokens.

### GrowPass (GPASS)

An ERC721 NFT representing learning achievements. Each NFT has a level (1-5) indicated by color:
- Level 1: Green (#10B981)
- Level 2: Blue (#3B82F6)
- Level 3: Purple (#8B5CF6)
- Level 4: Orange (#F59E0B)
- Level 5: Red (#EF4444)

NFT metadata is generated dynamically on-chain including SVG images.

### TaskManager

Manages learning tasks with the following features:
- Predefined learning tasks with token rewards
- Task completion tracking per user
- NFT minting based on task completion
- Integration with both GrowToken and GrowPass contracts

Sample tasks include:
1. Watch Solidity Intro (100 GROW, Level 1)
2. Deploy First Contract (300 GROW, Level 2)
3. Write Foundry Test (500 GROW, Level 3)
4. Submit PR to Open Source (1000 GROW, Level 5)

## License

MIT