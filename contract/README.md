# InnoHunt Smart Contract

# Overview
The InnoHunt contract is a decentralized project funding and voting platform where users can create projects, buy and sell shares, create proposals for project funding, and vote on these proposals. Each project has an associated ERC20 token representing its shares.

# Key Components

# Contracts
CreateToken: An ERC20 token contract used for project shares.
InnoHunt: The main contract managing projects, shares, proposals, and voting.

# Structs
Project: Represents a project with details such as owner, total raised funds, total shares, remaining shares, share price, token address, and proposals.
Proposal: Represents a proposal within a project, including upvote and downvote counts, thresholds, required funds, and votes.
Vote: Represents an individual vote with details about the voter, vote type (upvote/downvote), and vote weight.

# Key Features
Create Project: Allows users to create a new project with a specified name, symbol, share price, and total shares.
Buy Shares: Allows users to buy shares of a project by sending ETH.
Sell Shares: Allows users to sell their shares back to the project for ETH.
Withdraw Funds: Allows the project owner to withdraw a portion of the raised funds once.
Create Proposal: Allows the project owner to create funding proposals.
Vote on Proposal: Allows users to vote on proposals with their shares.

# Running the Tests

### Prerequisites

- Node.js
- npm (Node Package Manager)
- Hardhat

### Installation

1. **Clone the repository:**
   ```sh
   git clone <repository-url>
   ```
   
2. **Navigate to the contract directory:**
   ```sh
   cd contract
   ```

3. **Install the dependencies:**
   ```sh
   npm install
   ```

4. **Run the tests:**
   ```sh
   npx hardhat test
   ```
