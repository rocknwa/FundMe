// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {ChainFund} from "../src/ChainFund.sol";

/// @title  DeployChainFund Script
/// @notice Automates the deployment of the ChainFund contract using network-specific configuration
/// @dev  Uses Forge’s Script for transaction broadcasting and HelperConfig for price-feed addresses
contract DeployChainFund is Script {
    /// @notice Deploys ChainFund and returns both the deployed contract and its configuration helper
    /// @return chainFund     The newly deployed ChainFund contract instance
    /// @return helperConfig  The HelperConfig instance containing network settings
    function run() external returns (ChainFund chainFund, HelperConfig helperConfig) {
        // 1. Instantiate HelperConfig to determine which price feed to use on this network
        helperConfig = new HelperConfig();

        // 2. Read the active price-feed address from the helper
        address priceFeed = helperConfig.activeNetworkConfig();

        // 3. Begin broadcasting transactions using the private key provided to Forge
        vm.startBroadcast();

        // 4. Deploy the ChainFund contract, passing in the resolved price-feed address
        chainFund = new ChainFund(priceFeed);

        // 5. Stop broadcasting; Forge will sign and send the transaction above
        vm.stopBroadcast();

        // 6. Return the deployed ChainFund instance and its config for downstream scripts/tests
        return (chainFund, helperConfig);
    }
}

