# ERC-721 Staking Vault & Time-Based Rewards Engine

An enterprise-grade NFT Staking Vault designed to lock ERC-721 tokens and calculate time-weighted rewards. Built with Solidity `0.8.20`, focusing on gas optimization, standard receiver interfaces, and strict access control mechanisms.

## 🚀 Key Features & Architectural Overview
- **Escrow Mechanics:** Safely holds user NFTs within the vault contract using `safeTransferFrom` and tracks ownership states on-chain.
- **Time-Weighted Rewards:** Accrues rewards dynamically based on block timestamps at a rate of 10 reward units per day (`10 ether / 24h`).
- **Gas-Optimized Struct Packing:** Packed timestamp tracking (`uint248`) with standard address primitives to fit storage into a single 32-byte slot (`EVMSlot`).

## 🛡️ Security Vectors & Audit Checklist

### 1. ERC-721 Receiver Callback Access Control (Fixed Critical Bug)
- **Vector:** Unrestricted invocation of `onERC721Received` allows arbitrary callers to inject fake staking states into the vault.
- **Mitigation:** Strict caller verification enforcing `require(msg.sender == address(nftContract))` before processing callbacks or writing to storage.

### 2. Checks-Effects-Interactions (CEI) Compliance
- **Vector:** State corruption during token retrieval or withdrawal sequences.
- **Mitigation:** Internal state updates—including calculation of pending rewards (`rewards[msg.sender] += reward`) and deletion of the stake record (`delete vault[tokenId]`)—are executed **prior** to outbound asset transfers.

### 3. Precision & Time Invariance
- **Vector:** Division loss or rounding exploits in reward calculation logic.
- **Mitigation:** Integer division is delayed until after multiplication in elapsed time delta evaluations (`(timeStaked * REWARD_PER_DAY) / 1 days`).

## 🛠️ Tech Stack
- **Smart Contract Language:** Solidity `^0.8.20`
- **Libraries & Standards:** OpenZeppelin v5.0 (`IERC721`, `IERC721Receiver`, `Ownable`)
- **Architecture Patterns:** Escrow Vault, CEI Pattern, Dynamic State Deletion
