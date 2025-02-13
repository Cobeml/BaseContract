# Competition Smart Contract (see contracts/Competition.sol)

## Overview
The `Competition` smart contract is designed to facilitate a token-based competition between two ERC-20 tokens. It enables users to purchase tokens, track scores, and determine a winner. The contract also includes mechanisms for cashing out winnings once the competition has ended.

## Features
- **Token Purchase:** Users can buy tokens at dynamically calculated prices based on supply and demand.
- **Score Tracking:** The contract maintains scores for the two competing tokens.
- **Game Control:** The contract owner can start, update scores, and end the competition.
- **Winner Determination:** After the game ends, the contract designates a winner based on the final scores.
- **Cashout Mechanism:** Users holding the winning token can exchange their tokens for ETH.

## Contract Components

### State Variables
- `token1`, `token2`: Addresses of the two competing ERC-20 tokens.
- `holder`: Contract address that holds the tokens.
- `score`: Array storing scores of the two tokens.
- `gameInProgress`, `gameEnded`: Boolean values tracking the game state.
- `equivalentETH1`, `equivalentETH2`: ETH reserves equivalent to each token.
- `price`: Base price of tokens.
- `token1Count`, `token2Count`: Initial token supply.
- `winner`: Address of the winning token after the game.

### Events
- `TokensPurchased`: Logs token purchases.
- `TransferAttempt`: Logs transfer attempts.
- `TransferResult`: Logs success or failure of transfers.

### Functions

#### Token Operations
- `getTokenBalance(address token)`: Returns the balance of a given token in the contract.
- `approveTokens(address token, address spender, uint256 amount)`: Approves token spending.
- `getPrice(address token)`: Computes the current price of a token based on its circulating supply.
- `purchaseToken(IERC20 token)`: Allows users to buy tokens with ETH, adjusting token prices dynamically.

#### Game Control
- `start(address token1_, address token2_)`: Initializes the competition with two tokens.
- `getScore()`: Returns the current score array.
- `updateScore(uint256 _index, uint256 _newScore)`: Updates a token’s score.
- `end(int winner_)`: Ends the competition and sets the winning token.

#### Cashout Mechanism
- `cashout(uint amount)`: Allows users to exchange winning tokens for ETH at a rate determined by the contract’s ETH reserves.

## Usage
1. **Deployment:** The contract must be deployed by an owner with two ERC-20 tokens as inputs.
2. **Token Purchase:** Users can send ETH to purchase tokens.
3. **Score Updating:** The owner updates scores during the game.
4. **Ending the Game:** The owner finalizes the game and declares a winner.
5. **Cashing Out:** Users holding the winning token can exchange it for ETH.

## Security Considerations
- Only the owner can start, update scores, and end the game.
- The contract ensures fair price calculations for token purchases and cashouts.
- Users must approve the contract to spend their tokens before cashing out.

This smart contract provides a fair and transparent competition mechanism leveraging ERC-20 tokens and Ethereum transactions.

