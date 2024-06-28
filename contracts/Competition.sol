// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "./Token.sol";

contract Competition is Ownable {
    address public token1;
    address public token2;
    address public wallet = msg.sender;
    uint public end_time;
    ISwapRouter public uniswapRouter;
    INonfungiblePositionManager public positionManager;
    uint256[2] public score;
    uint public liquidity1;
    uint public liquidity2;

    constructor(address _swapRouter, address _positionManager, address token1_, address token2_) Ownable(wallet) {
        uniswapRouter = ISwapRouter(_swapRouter);
        positionManager = INonfungiblePositionManager(_positionManager);
        token1 = token1_;
        token2 = token2_;
        score[0] = 0;
        score[1] = 0;
    }

    function start() external onlyOwner {
        end_time = block.timestamp + 10000000;

        IERC20(token1).approve(address(positionManager), 100_000);
        IERC20(token2).approve(address(positionManager), 100_000);

        // Add liquidity to Uniswap V3 pool
        INonfungiblePositionManager.MintParams memory params1 = INonfungiblePositionManager.MintParams({
            token0: token1,
            token1: address(uniswapRouter.WETH9()),
            fee: 3000, // 0.3% fee tier
            tickLower: -887220,
            tickUpper: 887220,
            amount0Desired: 100_000,
            amount1Desired: 0.0001 ether,
            amount0Min: 0,
            amount1Min: 0,
            recipient: wallet,
            deadline: block.timestamp + 3_000
        });

        (uint256 tokenId1, uint128 liquidity1_, , ) = positionManager.mint{value: 0.0001 ether}(params1);

        INonfungiblePositionManager.MintParams memory params2 = INonfungiblePositionManager.MintParams({
            token0: token2,
            token1: address(uniswapRouter.WETH9()),
            fee: 3000, // 0.3% fee tier
            tickLower: -887220,
            tickUpper: 887220,
            amount0Desired: 100_000,
            amount1Desired: 0.0001 ether,
            amount0Min: 0,
            amount1Min: 0,
            recipient: wallet,
            deadline: block.timestamp + 3_000
        });

        (uint256 tokenId2, uint128 liquidity2_, , ) = positionManager.mint{value: 0.0001 ether}(params2);

        liquidity1 = uint256(liquidity1_);
        liquidity2 = uint256(liquidity2_);
    }

    function getScore() public view returns (uint256[2] memory) {
        return score;
    }
   
    // Function to update a score at a specific index in the scores array
    function updateScore(uint256 _index, uint256 _newScore) public onlyOwner {
        require(_index < score.length, "Index out of bounds");
        score[_index] = _newScore;
    }


    function end(int winner_) external onlyOwner {
        address winner = (winner_ == 1 ? token1 : token2);
        address loser = (winner_ == 2 ? token1 : token2);
        uint256 loserLiquidity = (winner_ == 2 ? liquidity1 : liquidity2);

        // Remove liquidity from the losing pool
        INonfungiblePositionManager.DecreaseLiquidityParams memory params = INonfungiblePositionManager.DecreaseLiquidityParams({
            tokenId: loserLiquidity,
            liquidity: uint128(loserLiquidity),
            amount0Min: 0,
            amount1Min: 0,
            deadline: block.timestamp + 3_000
        });

        (uint256 amount0, uint256 amount1) = positionManager.decreaseLiquidity(params);

        // Collect the tokens
        INonfungiblePositionManager.CollectParams memory collectParams = INonfungiblePositionManager.CollectParams({
            tokenId: loserLiquidity,
            recipient: wallet,
            amount0Max: type(uint128).max,
            amount1Max: type(uint128).max
        });

        (uint256 collectedAmount0, uint256 collectedAmount1) = positionManager.collect(collectParams);

        // Swap ETH for winner tokens
        ISwapRouter.ExactInputSingleParams memory swapParams = ISwapRouter.ExactInputSingleParams({
            tokenIn: uniswapRouter.WETH9(),
            tokenOut: winner,
            fee: 3000,
            recipient: wallet,
            deadline: block.timestamp + 3_000,
            amountIn: collectedAmount1,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        });

        uniswapRouter.exactInputSingle{value: collectedAmount1}(swapParams);
    }
}

// Things need to decide:
// - If amount of winner token bought should be all ETH returned from LP or ETH from LP - original contributions

// Things need to do:
// - Change the amount of ether provided for liquidity with each hosted game
// - Change the address of the owner to not be my wallet
// - Don't hardcode when deploying
// - Test