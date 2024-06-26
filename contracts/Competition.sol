// SPDX-License-Identifier: MIT 
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
import "./Token.sol";

contract Competition is Ownable {
    address public token1;
    address public token2;
    address public wallet = msg.sender;
    uint public end_time;
    IUniswapV2Router02 public uniswapRouter;
    uint256[2] public score;
    uint public liquidity1;
    uint public liquidity2;

    constructor(address _uniswapRouter) Ownable(wallet) {
        uniswapRouter = IUniswapV2Router02(_uniswapRouter);
        score[0] = 0;
        score[1] = 0;
    }

    function start(string calldata name1, string calldata symbol1, string calldata name2, string calldata symbol2) onlyOwner external {
        Token t1 = new Token(name1, symbol1);
        Token t2 = new Token(name2, symbol2);
        // end_time = block.timestamp + 10000000;
        // token1 = address(t1);
        // token2 = address(t2);
        // // 100_000 of token printed - see Token.sol
        // // Approve Uniswap Router to spend the tokens
        // IERC20(token1).approve(address(uniswapRouter), 100_000);
        // IERC20(token2).approve(address(uniswapRouter), 100_000);

        // (uint amountToken1, uint amountETH1, uint liquidity1_) = uniswapRouter.addLiquidityETH {value: 0.01 ether} (
        //     token1,
        //     100_000,
        //     0,
        //     .01 ether,
        //     wallet,
        //     block.timestamp + 30_000
        // ); // we should decide how much liquidity,token,eth we are sending to the LP

        // (uint amountToken2, uint amountETH2, uint liquidity2_) = uniswapRouter.addLiquidityETH {value: 0.01 ether} (
        //     token2,
        //     100_000,
        //     0,
        //     .01 ether,
        //     wallet,
        //     block.timestamp + 30_000
        // ) ;

        // liquidity1 = liquidity1_;
        // liquidity2 = liquidity2_;
    }

    function getScore() public view returns (uint256[2] memory) {
        return score;
    }
    
    // Function to update a score at a specific index in the scores array
    function updateScore(uint256 _index, uint256 _newScore) public onlyOwner {
        require(_index < score.length, "Index out of bounds");
        score[_index] = _newScore;
    }


    function end(int winner_) onlyOwner external {
        // winner_ should be 1 or 2
        address winner;
        address loser;
        winner = (winner_ == 1 ? token1 : token2);
        loser = (winner_ == 2 ? token1 : token2);
        uint loserLiquidity = (winner_ == 2 ? liquidity1 : liquidity2);


         // Remove liquidity from the first pool
        (uint amountToken, uint amountETH) = uniswapRouter.removeLiquidityETH(
            loser,
            loserLiquidity,
            0,
            0,
            wallet,
            block.timestamp + 3000
        );

        // Add liquidity to the second pool
        address[] memory path = new address[](2);
        path[0] = uniswapRouter.WETH(); // WETH address
        path[1] = winner;
        uniswapRouter.swapExactETHForTokens {value: amountETH} (
            0, 
            path, 
            wallet, 
            block.timestamp + 3000
        );

    }
}

// Things need to decide:
// - If amount of winner token bought should be all ETH returned from LP or ETH from LP - original contributions

// Things need to do:
// - Change the amount of ether provided for liquidity with each hosted game
// - Change the address of the owner to not be my wallet
// - Don't hardcode when deploying
// - Test