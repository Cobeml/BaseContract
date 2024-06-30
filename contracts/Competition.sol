// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Token.sol";

contract Competition is Ownable {
    address public token1;
    address public token2;
    address payable public holder;
    uint256[2] public score;
    bool public gameInProgress;
    uint public equivalentETH1;
    uint public equivalentETH2;
    uint public price;
    uint public token1Count;
    uint public token2Count;

    bool public gameEnded;
    address public winner;
    uint tokensReturned;

    event TokensPurchased(address buyer, uint256 amount);
    event TransferAttempt(address from, address to, uint256 value);
    event TransferResult(bool success);

    constructor() Ownable(msg.sender) {
        score[0] = 0;
        score[1] = 0;
        holder = payable(address(this));
        equivalentETH1 = 100_000 * 1e9;
        equivalentETH2 = 100_000 * 1e9;
        gameInProgress = false;
        gameEnded = false;
        price = 1 gwei;
        token1Count = 100_000 * 10**18;
        token2Count = 100_000 * 10**18;
    }

    function getTokenBalance(address token) public view returns (uint256 amount) {
        amount = IERC20(token).balanceOf(holder);
        return amount;
    }

    // Function to approve tokens for spending
    function approveTokens(address token, address spender, uint256 amount) public returns (bool) {
        return IERC20(token).approve(spender, amount);
    }

    function getPrice(address token) public view returns (uint256 price_){
        uint256 tokenBalance = getTokenBalance(token);
        uint256 tokensCirculating = 100_000 * 1e18 - tokenBalance;
        if (gameEnded) {
            if (token == winner) {
                uint ethBalance = address(this).balance;
                price_ = ethBalance * 1e18 / tokensCirculating;
            } else {
                price_ = 0;
            }
            if (token != token1 && token != token2) {
                revert("Token input is not one of game tokens");
            }
            return price_;
        } else {
            uint equivalentETH;

            if (token==token1) {
                equivalentETH = equivalentETH1;
                price_ = equivalentETH * 1e18 / tokenBalance;
            } else if (token==token2) {
                equivalentETH = equivalentETH2;
                price_ = equivalentETH * 1e18 / tokenBalance;
            } else {
                revert("Token input is not one of game tokens");
            }

            return price_;
        }
    }

    // Function to calculate the amount of token1 to send back to the buyer
    function getAmountOut(
        uint256 tokenAReserve, // Current amount of token1 in the pool
        uint256 tokenBReserve, // Current amount of token2 in the pool
        uint256 amountIn // Amount of token2 being sent to buy token1
    ) internal pure returns (uint256 amountTokenAOut, uint256 newTokenBReserve) {
        // Ensure the amountIn is greater than 0
        require(amountIn > 0, "Input amount must be greater than zero");
        
        // Calculate the new reserves after the swap
        newTokenBReserve = tokenBReserve + amountIn;
        
        // Calculate the new tokenAReserve using the constant product formula
        // k = tokenAReserve * tokenBReserve
        // newTokenAReserve = k / newTokenBReserve
        uint256 k = tokenAReserve * tokenBReserve;
        uint256 newTokenAReserve = k / newTokenBReserve;
        
        // Calculate the amount of token1 to be sent back to the buyer
        amountTokenAOut = tokenAReserve - newTokenAReserve;
        
        return (amountTokenAOut, newTokenBReserve);
    }

    function checkAllowance(address owner, address spender, address tokenAddress) public view returns (uint256) {
        IERC20 token = IERC20(tokenAddress);
        return token.allowance(owner, spender);
    }

    function purchaseToken(IERC20 token) public payable {
        require(gameInProgress == false, "Game in progress");
        require(gameEnded == false, "Game ended");

        uint contractTokenBalance =getTokenBalance(address(token));

        uint equivalentETH;

        if (address(token)==token1) {
            equivalentETH = equivalentETH1;
        } else if (address(token)==token2) {
            equivalentETH = equivalentETH2;
        } else {
            revert("Token input is not one of game tokens");
        }

        // 100_000 tokens corresponds to .0001 eth
        // 1 token = .00_000_0001 eth = 1 gwei
        // Transfer the received Ether to the owner
        (uint numTokens, uint newEquivalentETH) = getAmountOut(contractTokenBalance, equivalentETH, msg.value);
        require(numTokens > 0, "You must send enough gwei to buy at least 1 token");
        if (address(token) == token1 && contractTokenBalance < numTokens){
            revert("Insufficient token1 remaining in supply");
        }
        if (address(token) == token2 && contractTokenBalance < numTokens){
            revert("Insufficient token2 remaining in supply");
        }

        // // Transfer the tokens from the owner to the buyer
        emit TransferAttempt(holder, msg.sender, numTokens);
        bool success = token.transfer(msg.sender, numTokens);
        emit TransferResult(success);
        require(success, "Token transfer failed");

        if (address(token)==token1) {
            equivalentETH1 = newEquivalentETH;
        } else if (address(token)==token2) {
            equivalentETH2 = newEquivalentETH;
        }

        emit TokensPurchased(msg.sender, numTokens);
    }

    function start(address token1_, address token2_) public onlyOwner {
        gameInProgress = false;
        token1 = token1_;
        token2 = token2_;
    }


    function getScore() public view returns (uint256[2] memory) {
        return score;
    }
    
    // Function to update a score at a specific index in the scores array
    function updateScore(uint256 _index, uint256 _newScore) public onlyOwner {
        require(_index < score.length, "Index out of bounds");
        score[_index] = _newScore;
        gameInProgress = true;
    }


    function end(int winner_) public onlyOwner {
        gameInProgress = false;
        gameEnded = true;
        winner = (winner_ == 1 ? token1 : token2);
    }

    function cashout(uint amount) public {
        require(gameEnded == true, "Game not ended");
        require(amount > 0, "Amount must be greater than zero");
        
        uint256 winnerBalance = getTokenBalance(winner);
        uint256 winnerTokensCirculating = 100_000 * 1e18 - winnerBalance;
        uint256 ethBalance = address(this).balance;

        (uint ethAmount, uint remainingBalance) = getAmountOut(ethBalance,winnerTokensCirculating,amount); 
        require(address(this).balance >= ethAmount, "Insufficient ETH in contract");

        // Transfer tokens from the user to the contract
        bool success = IERC20(winner).transferFrom(msg.sender, address(this), amount);
        require(success, "Token transfer failed");

        // Transfer ETH to the user
        (bool sent, ) = msg.sender.call{value: ethAmount}("");
        require(sent, "Failed to send Ether");

        // emit TokensCashedOut(msg.sender, amount);
        // emit Log("Cashout completed", msg.sender, amount, address(token));
    }
}