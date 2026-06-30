// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {TreasuryVault} from "../src/Vault.sol";

contract DeployVault is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address token0 = 0x0000000000000000000000000000000000000000;
        address token1 = 0x0000000000000000000000000000000000000000;
        address positionManager = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;

        vm.startBroadcast(deployerPrivateKey);
        new TreasuryVault(token0, token1, positionManager);
        vm.stopBroadcast();
    }
}
