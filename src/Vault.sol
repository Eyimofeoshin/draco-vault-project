// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract TreasuryVault is Ownable {
    using SafeERC20 for IERC20;

    IERC20 public immutable token0;
    IERC20 public immutable token1;
    address public immutable positionManager;
    mapping(address => bool) public allowedTokens;

    constructor(address _token0, address _token1, address _positionManager) Ownable(msg.sender) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
        positionManager = _positionManager;
        allowedTokens[_token0] = true;
        allowedTokens[_token1] = true;
    }

    modifier onlyAllowedToken(address token) {
        require(allowedTokens[token], "Token not allowed");
        _;
    }

    function deposit(uint256 amount0, uint256 amount1) external {
        token0.safeTransferFrom(msg.sender, address(this), amount0);
        token1.safeTransferFrom(msg.sender, address(this), amount1);
    }

    function executeStrategy(bytes calldata data) external onlyOwner returns (bytes memory) {
        (bool success, bytes memory result) = positionManager.call(data);
        require(success, "Strategy execution failed");
        return result;
    }

    function withdraw(address token, uint256 amount, address to) external onlyOwner onlyAllowedToken(token) {
        IERC20(token).safeTransfer(to, amount);
    }
}
