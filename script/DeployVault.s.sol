// SPDX-License-Identifier: MIT
pragma solidity ^0.8.35;

import {Script} from "forge-std/Script.sol";
import {TreasuryVault} from "../src/Vault.sol";

contract DeployVault is Script {
    // Sepolia addresses
    address constant TOKEN0 = 0x7b79995e5f793A07Bc00c21412e50Ecae098E7f9;
    address constant TOKEN1 = 0xf08A50178dfcDe18524640EA6618a1f965821715;
    address constant POSITION_MANAGER = 0x1238536071e1c677a632429E3655c898B27528c3;
    address constant ETH_USD_PRICE_FEED = 0x694AA1769357215DE4FAC081bf1f309aDC325306;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        address priceFeedAddress = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
        new TreasuryVault(TOKEN0, TOKEN1, POSITION_MANAGER, priceFeedAddress);

        vm.stopBroadcast();
    }
}
