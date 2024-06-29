// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Token.sol";

contract Competition is Ownable {
    address public token1;
    address public token2;
    address payable public holder;
    uint public end_time;
    uint256[2] public score;
    bool public gameStarted;
    uint public price1;
    uint public price2;
    uint public token1Count;
    uint public token2Count;
    uint public equivalentETH1;
    uint public equivalentETH2;

    event TokensPurchased(address buyer, uint256 amount);

    constructor(address token1_, address token2_) Ownable(msg.sender) {
        token1 = token1_;
        token2 = token2_;
        score[0] = 0;
        score[1] = 0;
        holder = payable(msg.sender);
        equivalentETH1 = 100_000 gwei;
        equivalentETH2 = 100_000 gwei;
        token1Count = 100_000;
        token2Count = 100_000;
        gameStarted = false;
    }

    function getTokenBalance(address token) public view returns (uint256 amount) {
        amount = IERC20(token).balanceOf(holder);
        return amount;
    }

    function getPrice(address token) public returns (uint256 price_){
        uint balance = getTokenBalance(token);

        uint equivalentETH;

        if (token==token1) {
            equivalentETH = equivalentETH1;
            price1 = equivalentETH / balance;
            price_ = price1;
        } else if (token==token2) {
            equivalentETH = equivalentETH2;
            price2 = equivalentETH / balance;
            price_ = price2;
        } else {
            revert("Token input is not one of game tokens");
        }

        return price_;
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

    function purchaseToken(ERC20 token) public payable {
        require(gameStarted == false, "Game in progress");

        uint contractTokenBalance = IERC20(address(token)).balanceOf(holder);

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
        (uint numberTokens, uint newEquivalentETH) = getAmountOut(contractTokenBalance, equivalentETH, msg.value);
        require(numberTokens > 0, "You must send enough gwei to buy at least 1 token");
        if (address(token) == token1 && token1Count < numberTokens){
            revert("Insufficient token1 remaining in supply");
        }
        if (address(token) == token2 && token2Count < numberTokens){
            revert("Insufficient token2 remaining in supply");
        }

        // Transfer the tokens from the owner to the buyer
        bool success = token.transferFrom(holder , msg.sender, numberTokens);
        require(success, "Token transfer failed");

        if (address(token)==token1) {
            equivalentETH1 = newEquivalentETH;
        } else if (address(token)==token2) {
            equivalentETH2 = newEquivalentETH;
        }

        emit TokensPurchased(msg.sender, numberTokens);
    }

    function start() public onlyOwner {
        gameStarted = false;
    }


    function getScore() public view returns (uint256[2] memory) {
        return score;
    }
    
    // Function to update a score at a specific index in the scores array
    function updateScore(uint256 _index, uint256 _newScore) public onlyOwner {
        require(_index < score.length, "Index out of bounds");
        score[_index] = _newScore;
        gameStarted = true;
    }


    function end(int winner_) public onlyOwner {
        
    }
}

// Things need to decide:
// - If amount of winner token bought should be all ETH returned from LP or ETH from LP - original contributions

// Things need to do:
// - Change the amount of ether provided for liquidity with each hosted game
// - Change the address of the owner to not be my holder
// - Don't hardcode when deploying
// - Test