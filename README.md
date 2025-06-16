# KipuBank Smart Contract

![Solidity](https://img.shields.io/badge/Solidity-0.8.30-informational) 
![License](https://img.shields.io/badge/License-MIT-blue)

A secure vault system for ETH deposits and controlled withdrawals with configurable limits.

## Features
- Personal ETH vaults for each user
- Global deposit cap (`bankCap`)
- Per-transaction withdrawal limit (`thresholdWithdrawal`)
- Fully documented with NatSpec
- Reentrancy-safe design

## Deployment Guide (Sepolia Testnet)

### Prerequisites
- MetaMask installed and connected to Sepolia
- Sepolia ETH (get from [Google Cloud Web3]([https://sepoliafaucet.com/](https://cloud.google.com/application/web3/faucet/ethereum/sepolia)))
- Remix IDE ([remix.ethereum.org](https://remix.ethereum.org))

### Step-by-Step Deployment
1. **Compile Contract**
   - Open Remix IDE
   - Paste contract code into `KipuBank.sol`
   - Go to "Solidity Compiler" tab
   - Select compiler version `0.8.30`
   - Click "Compile KipuBank.sol"

2. **Configure Deployment**
   - Navigate to "Deploy & Run Transactions"
   - Environment: "Injected Provider - MetaMask" (ensure Sepolia is selected)
   - Account: Select your funded Sepolia account

3. **Deploy Contract**
   - Set constructor parameters:
     - `_bankCap`: (e.g., `1000000000000000000` for 1 ETH cap)
     - `_thresholdWithdrawal`: (e.g., `500000000000000000` for 0.5 ETH limit)
   - Click "Transact"
   - Confirm transaction in MetaMask

4. **Verify Contract**
   - Copy deployed contract address from Remix
   - Go to [Sepolia Etherscan](https://sepolia.etherscan.io/)
   - Search for your contract address
   - Click "Verify & Publish"
   - Fill verification form matching Remix settings
   - Upload `KipuBank.sol`
   - Click "Verify"

## Interacting via Etherscan

### Prerequisites
- Verified contract on Sepolia Etherscan
- MetaMask connected to Sepolia

### Available Functions
1. **Deposit ETH**
   - Navigate to "Contract" → "Write Contract"
   - Connect Web3 wallet
   - Under `deposit` function:
     - Set "Value" field (in wei, e.g., 0.1 ETH = `100000000000000000`)
     - Click "Write"

2. **Withdraw ETH**
   - Under `withdraw` function:
     - Enter amount in wei
     - Click "Write"
     - Confirm transaction

3. **View Balances**
   - Under "Read Contract":
     - `getVaultBalance`: Check user's balance
     - `bankCap`: View global limit
     - `thresholdWithdrawal`: Check per-transaction limit

### Important Events
| Event Name           | Description                          |
|----------------------|--------------------------------------|
| `SuccessDeposit`     | Emitted on successful deposits       |
| `SuccessWithdraw`    | Emitted on successful withdrawals    |
| `FailedDeposit`      | Emitted on failed deposit attempts   |
| `FailedWithdrawal`   | Emitted on failed withdrawal attempts|

## Example of a deployment
Go to [Deploy contract](https://sepolia.etherscan.io/address/0x12961d79a1febCaB9636265CeCbe05b0f81Bc6B7#readContract), or just search fot these contract address: `0x12961d79a1febCaB9636265CeCbe05b0f81Bc6B7` on Sepolia Etherscan.

## License
MIT License - See [LICENSE](LICENSE) for details

