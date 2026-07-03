// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {INonfungiblePositionManager} from "./INonfungiblePositionManager.sol";
import {
    AggregatorV3Interface
} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract TreasuryVault is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable token0;
    IERC20 public immutable token1;
    INonfungiblePositionManager public immutable positionManager;
    mapping(address => bool) public allowedTokens;

    uint256[] public positionIds;
    AggregatorV3Interface public priceFeed;

    constructor(address _token0, address _token1, address _positionManager, address _priceFeed) Ownable(msg.sender) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
        positionManager = INonfungiblePositionManager(_positionManager);
        allowedTokens[_token0] = true;
        allowedTokens[_token1] = true;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    modifier onlyAllowedToken(address token) {
        require(allowedTokens[token], "Token not allowed");
        _;
    }

    function deposit(uint256 amount0, uint256 amount1) external {
        token0.safeTransferFrom(msg.sender, address(this), amount0);
        token1.safeTransferFrom(msg.sender, address(this), amount1);
    }

    function mintPosition(INonfungiblePositionManager.MintParams calldata params)
        external
        onlyOwner
        returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1)
    {
        token0.forceApprove(address(positionManager), params.amount0Desired);
        token1.forceApprove(address(positionManager), params.amount1Desired);

        (tokenId, liquidity, amount0, amount1) = positionManager.mint(params);

        positionIds.push(tokenId);
    }

    function getPositions() external view returns (uint256[] memory) {
        return positionIds;
    }

    function withdraw(address token, uint256 amount, address to) external onlyOwner onlyAllowedToken(token) {
        IERC20(token).safeTransfer(to, amount);
    }

    function collectFees(uint256 tokenId, address recipient)
        external
        onlyOwner
        returns (uint256 amount0, uint256 amount1)
    {
        INonfungiblePositionManager.CollectParams memory params = INonfungiblePositionManager.CollectParams({
            tokenId: tokenId, recipient: recipient, amount0Max: type(uint128).max, amount1Max: type(uint128).max
        });

        (amount0, amount1) = positionManager.collect(params);
    }

    function getLatestPrice() public view returns (int256) {
        (, int256 price,,,) = priceFeed.latestRoundData();
        return price;
    }
}

