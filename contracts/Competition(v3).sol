// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.7.6;
pragma abicoder v2;

import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import '@uniswap/v3-core/contracts/libraries/TickMath.sol';
import '@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol';
import '@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol';
import '@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol';
import '@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol';
import '@uniswap/v3-periphery/contracts/base/LiquidityManagement.sol';
import "@openzeppelin/contracts/access/Ownable.sol";

contract CompetitionV3 is IERC721Receiver, Ownable {
    address public token1;
    address public token2;
    uint24 public constant poolFee = 10000;
    address public wallet = msg.sender;
    uint public end_time;
    INonfungiblePositionManager public immutable nonfungiblePositionManager;
    uint256[2] public score;
    uint public liquidity1;
    uint public liquidity2;
    address public winner;
    address public loser;
    address WETH;

    struct Deposit {
        address owner;
        uint128 liquidity;
        address token0;
        address token1;
    }

    mapping(uint256 => Deposit) public deposits;

    constructor(
        INonfungiblePositionManager _nonfungiblePositionManager,
        address _factory,
        address _WETH9,
        address token1_, 
        address token2_
    ) {
        nonfungiblePositionManager = _nonfungiblePositionManager;
        token1 = token1_;
        token2 = token2_;
        score[0] = 0;
        score[1] = 0;
        end_time = block.timestamp + 10000000;

        WETH = _WETH9;
    }

    function onERC721Received(
        address operator,
        address,
        uint256 tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        // get position information
        _createDeposit(operator, tokenId);
        return this.onERC721Received.selector;
    }

    function _createDeposit(address owner, uint256 tokenId) internal {
        (, , address token0, address token1, , , , uint128 liquidity, , , , ) =
            nonfungiblePositionManager.positions(tokenId);

        // set the owner and data for position
        // operator is msg.sender
        deposits[tokenId] = Deposit({owner: owner, liquidity: liquidity, token0: token0, token1: token1});
    }

    function createPoolAndDeposit(address token) internal
        returns (
            uint256 tokenId,
            uint128 liquidity,
            uint256 amountToken,
            uint256 amountETH
        )
    {
        nonfungiblePositionManager.createAndInitializePoolIfNecessary(WETH, token, poolFee, 60464810527415870840939482028383868920);

        // For this example, we will provide equal amounts of liquidity in both assets.
        // Providing liquidity in both assets means liquidity will be earning fees and is considered in-range.

        uint256 amountTokenToMint = 50_000;
        uint256 amountETHToMint = .0001 ether;

        TransferHelper.safeApprove(token, address(nonfungiblePositionManager), amountTokenToMint);
        TransferHelper.safeApprove(WETH, address(nonfungiblePositionManager), amountETHToMint);

        INonfungiblePositionManager.MintParams memory params =
            INonfungiblePositionManager.MintParams({
                token0: WETH,
                token1: token,
                fee: poolFee,
                tickLower: TickMath.MIN_TICK,
                tickUpper: TickMath.MAX_TICK,
                amount0Desired: amountTokenToMint,
                amount1Desired: amountETHToMint,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp
            });

        // Note that the pool defined by DAI/USDC and fee tier 0.3% must already be created and initialized in order to mint
        (tokenId, liquidity, amountToken, amountETH) = nonfungiblePositionManager.mint(params);

        // Create a deposit
        _createDeposit(msg.sender, tokenId);

        // Remove allowance and refund in both assets.
        if (amountToken < amountTokenToMint) {
            TransferHelper.safeApprove(token, address(nonfungiblePositionManager), 0);
            uint256 refund0 = amountTokenToMint - amountToken;
            TransferHelper.safeTransfer(token, msg.sender, refund0);
        }

        if (amountETH < amountETHToMint) {
            TransferHelper.safeApprove(WETH, address(nonfungiblePositionManager), 0);
            uint256 refund1 = amountETHToMint - amountETH;
            TransferHelper.safeTransfer(WETH, msg.sender, refund1);
        }
    }

    function start() onlyOwner external {
        createPoolAndDeposit(token1);
        createPoolAndDeposit(token2);
    }

    function getScore() public view returns (uint256[2] memory) {
        return score;
    }
   
    // Function to update a score at a specific index in the scores array
    function updateScore(uint256 _index, uint256 _newScore) public onlyOwner {
        require(_index < score.length, "Index out of bounds");
        score[_index] = _newScore;
    }
}
