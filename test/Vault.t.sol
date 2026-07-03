// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {Test} from "forge-std/Test.sol";
import {TreasuryVault} from "../src/Vault.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";
import {INonfungiblePositionManager} from "../src/INonfungiblePositionManager.sol";
import {
    AggregatorV3Interface
} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract VaultTest is Test {
    TreasuryVault public vault;
    ERC20Mock public token0;
    ERC20Mock public token1;
    address public positionManager = address(0xBEEF);
    address public user = address(1);
    address mockPriceFeed = address(0x123);
    AggregatorV3Interface internal priceFeed;

    function setUp() public {
        token0 = new ERC20Mock();
        token1 = new ERC20Mock();
        vault = new TreasuryVault(address(token0), address(token1), positionManager, mockPriceFeed);
    }

    function testMintPosition() public {
        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: address(token0),
            token1: address(token1),
            fee: 3000,
            tickLower: -60,
            tickUpper: 60,
            amount0Desired: 100,
            amount1Desired: 100,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(vault),
            deadline: block.timestamp
        });

        bytes memory returnData = abi.encode(uint256(1), uint128(100), uint256(100), uint256(100));
        vm.mockCall(positionManager, abi.encodeWithSelector(INonfungiblePositionManager.mint.selector), returnData);

        (uint256 tokenId, uint128 liquidity,,) = vault.mintPosition(params);

        assertEq(tokenId, 1);
        assertEq(liquidity, 100);
    }

    function testMintPositionArrayUpdate() public {
        INonfungiblePositionManager.MintParams memory params = INonfungiblePositionManager.MintParams({
            token0: address(token0),
            token1: address(token1),
            fee: 3000,
            tickLower: -60,
            tickUpper: 60,
            amount0Desired: 100,
            amount1Desired: 100,
            amount0Min: 0,
            amount1Min: 0,
            recipient: address(vault),
            deadline: block.timestamp
        });

        bytes memory returnData = abi.encode(uint256(1), uint128(100), uint256(100), uint256(100));
        vm.mockCall(positionManager, abi.encodeWithSelector(INonfungiblePositionManager.mint.selector), returnData);

        vault.mintPosition(params);

        uint256[] memory positions = vault.getPositions();
        assertEq(positions.length, 1);
        assertEq(positions[0], 1);
    }

    function testCollectFees() public {
        uint256 tokenId = 1;
        address recipient = address(this);

        bytes memory returnData = abi.encode(uint256(50), uint256(50));
        vm.mockCall(positionManager, abi.encodeWithSelector(INonfungiblePositionManager.collect.selector), returnData);

        (uint256 amount0, uint256 amount1) = vault.collectFees(tokenId, recipient);

        assertEq(amount0, 50);
        assertEq(amount1, 50);
    }

    function testGetPrice() public {
        bytes memory returnData = abi.encode(uint80(1), int256(3000 * 1e8), block.timestamp, block.timestamp, uint80(1));
        vm.mockCall(
            address(vault.priceFeed()),
            abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
            returnData
        );
        int256 price = vault.getLatestPrice();
        assertEq(price, 3000 * 1e8);
    }
}
