// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test} from "forge-std/Test.sol";
import {TreasuryVault} from "../src/Vault.sol";
import {ERC20Mock} from "@openzeppelin/contracts/mocks/token/ERC20Mock.sol";

contract VaultTest is Test {
    TreasuryVault public vault;
    ERC20Mock public token0;
    ERC20Mock public token1;
    ERC20Mock public maliciousToken;
    address public positionManager = address(0xBEEF);
    address public user = address(1);

    function setUp() public {
        token0 = new ERC20Mock();
        token1 = new ERC20Mock();
        maliciousToken = new ERC20Mock();
        vault = new TreasuryVault(address(token0), address(token1), positionManager);

        token0.mint(user, 1000);
        token1.mint(user, 1000);
    }

    function testWithdrawRestricted() public {
        vm.expectRevert("Token not allowed");
        vault.withdraw(address(maliciousToken), 100, user);
    }
}