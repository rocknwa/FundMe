# 🌐 ChainFund

**ChainFund** is an innovative decentralized finance (DeFi) project showcasing advanced Solidity smart contract development. This portfolio project implements a secure crowdfunding platform, allowing users to contribute ETH with a minimum USD threshold (5 USD) enforced via **Chainlink price feeds**.

It highlights gas optimization, security best practices, and complex integrations—positioning the developer as a skilled blockchain professional ready to deliver robust DeFi solutions.

---

## 🚀 Project Overview

**ChainFund** is a decentralized crowdfunding platform that enables users to fund projects in ETH, ensuring contributions meet a minimum value of **5 USD** using real-time **Chainlink ETH/USD price feeds**. The contract owner can withdraw funds securely, with an optimized withdrawal option to reduce gas costs.

### ✨ Key Features

* **Crowdfunding**: Users fund the contract with ETH, meeting a 5 USD minimum.
* **Price Feed Integration**: Chainlink ensures accurate ETH-to-USD conversions.
* **Secure Withdrawals**: Owner-only withdrawals, with a gas-optimized variant.
* **Funder Tracking**: Records contributors and their amounts for transparency.
* **Network Flexibility**: Deployable on Sepolia, Mainnet, or Anvil with mock support.

This project demonstrates the developer’s ability to create a secure, efficient, and user-friendly DeFi application, making it an ideal showcase for recruiters seeking blockchain talent.

---

## 🛠️ Skills Demonstrated

### 🧠 Technical Skills

* **Solidity Development**: Proficient in writing modular, secure smart contracts using `Solidity 0.8.19`.
* **Gas Optimization**:

  * Used `immutable` variables (`i_owner`)
  * Used `PriceConverter` library for ETH-USD conversions
  * Implemented `cheaperWithdraw` for reduced gas costs
* **Security Best Practices**:

  * Custom errors (`ChainFund_NotOwner`)
  * Owner-only modifiers
  * Safe ETH transfers and Chainlink feed validation
* **Complex Integrations**:

  * Real-time Chainlink price feeds
  * Library-based architecture for modularity and gas efficiency
* **Testing with Foundry**:

  * Comprehensive unit and E2E tests (funding, withdrawals, edge cases)
* **Scripting and Automation**:

  * Forge scripts for deployment and interaction (deploy/fund/withdraw)
* **Protocol Knowledge**:

  * Chainlink, ETH funding mechanics, multi-network support

### 💡 Transferable Skills

* **Problem-Solving**: Designed real-world funding threshold logic.
* **Attention to Detail**: Price precision and robust error handling.
* **System Design**: Modular libraries and scripts for scalability.
* **Adaptability**: Sepolia/Mainnet/Anvil support with mocks.

---

## 📦 Contracts

### 🏗️ Core Components

* **ChainFund**:

  * ETH crowdfunding contract with 5 USD minimum
  * Owner-only withdrawals
  * Funder tracking
* **PriceConverter**:

  * ETH-USD conversion using Chainlink feeds
  * Internal, gas-optimized utility functions
* **MockV3Aggregator**:

  * Chainlink feed mock for local (Anvil) testing

---

## 📜 Scripts and Tests

### 🧩 Scripts

* **DeployChainFund**: Deploys `ChainFund` using `HelperConfig` (selects Chainlink feed or mock).
* **HelperConfig**: Manages Sepolia, Mainnet, and Anvil configuration for feeds.
* **FundChainFund**: Sends 0.1 ETH to the latest `ChainFund` deployment using `DevOpsTools`.
* **WithdrawChainFund**: Withdraws funds (owner-only) from the latest deployment.

### 🧪 Tests

* **ChainFundTest**:

  * Validates price feed, funding thresholds, and data structures
  * Tests withdrawal logic and funder tracking
* **InteractionsTest**:

  * Deploys, funds, and withdraws from contract
  * Verifies final state (zero balance)

---

## 🏆 Achievements

* **Gas Optimization**:

  * Used `immutable` and local memory caching in `cheaperWithdraw`
  * Inlined library logic for ETH/USD conversions
* **Security**:

  * Custom error `ChainFund_NotOwner`
  * Safe ETH transfer with balance checks
  * Validated Chainlink data freshness
* **Integration**:

  * Clean Chainlink integration and modular `PriceConverter` library
* **Comprehensive Testing**:

  * Unit + E2E tests ensure reliability across chains
* **Automation**:

  * Scripts for funding, withdrawal, and deployment
  * Supports DevOps tools and CI-style setup

---

## 🧰 Technical Stack

| Category            | Stack                                     |
| ------------------- | ----------------------------------------- |
| Language            | Solidity 0.8.19                           |
| Framework           | Foundry                                   |
| Price Feeds         | Chainlink ETH/USD                         |
| Chainlink Interface | AggregatorV3Interface                     |
| Supported Networks  | Sepolia, Mainnet, Anvil (local with mock) |
| Tooling             | Forge, DevOpsTools, dotenv, Makefile      |

---

## 🧪 Setup & Testing Guide

### 📋 Prerequisites

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
sudo apt install make # for Linux users
```

---

### 🔃 Clone Repository

```bash
git clone https://github.com/rocknwa/ChainFund.git
cd ChainFund
```

---

### ⚙️ Environment Variables

Create a `.env` file in the root with:

```bash
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/your-api-key
PRIVATE_KEY=0xYourPrivateKey
ETHERSCAN_API_KEY=YourEtherscanAPIKey
```

Then run:

```bash
source .env
```

---

### 📦 Install Dependencies

```bash
make install
```

---

### ✅ Run Tests

```bash
make test
```

For verbose or forked testing:

```bash
forge test --fork-url <YOUR_RPC_URL> -vvv
```

---

### 🚀 Deploy Contract

#### Local (Anvil)

```bash
make deploy
```

#### Sepolia

```bash
make deploy ARGS="--network sepolia"
```

---

## 🧮 Makefile Commands

| Command         | Description                                 |
| --------------- | ------------------------------------------- |
| `make help`     | Displays available commands                 |
| `make all`      | Cleans, installs, updates, and builds       |
| `make clean`    | Removes old build artifacts                 |
| `make remove`   | Removes all submodules and resets libs      |
| `make install`  | Installs dependencies                       |
| `make update`   | Updates dependencies                        |
| `make build`    | Compiles contracts                          |
| `make test`     | Runs unit and integration tests             |
| `make snapshot` | Takes gas usage snapshot                    |
| `make format`   | Formats Solidity code                       |
| `make anvil`    | Starts a local blockchain node              |
| `make deploy`   | Deploys `ChainFund`                         |
| `make fund`     | Sends 0.1 ETH to `ChainFund`                |
| `make withdraw` | Withdraws ETH from `ChainFund` (owner-only) |

---

## 📬 Contact Information

For further inquiries or collaboration:

* **Email**: [anitherock44@gmail.com](mailto:anitherock44@gmail.com)
