// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

/// @title  HelperConfig
/// @notice Deploys or returns the appropriate Chainlink ETH/USD price feed address per network
/// @dev    On Sepolia/Mainnet, returns hardcoded feeds; on local Anvil, deploys a mock aggregator
contract HelperConfig is Script {
    /// @notice Current active network configuration struct
    NetworkConfig public activeNetworkConfig;

    /// @notice Decimal precision for the mock price feed
    uint8 public constant DECIMALS = 8;

    /// @notice Initial mock price (e.g. $2,000 represented with 8 decimals)
    int256 public constant INITIAL_PRICE = 2000e8;

    /// @notice Configuration bundle for a network
    struct NetworkConfig {
        /// @notice Address of the ETH/USD price feed
        address priceFeed;
    }

    /// @notice On deployment, set `activeNetworkConfig` based on `chainid`
    constructor() {
        if (block.chainid == 11155111) {
            // Sepolia testnet
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            // Ethereum mainnet
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            // Local Anvil or unknown chain
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    /// @notice Returns the hardcoded Sepolia ETH/USD feed address
    /// @return NetworkConfig with `priceFeed` set to Sepolia address
    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
    }

    /// @notice Returns the hardcoded Mainnet ETH/USD feed address
    /// @return NetworkConfig with `priceFeed` set to Mainnet address
    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        return NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
    }

    /// @notice Deploys a `MockV3Aggregator` on local Anvil and returns its address
    /// @dev    Uses Forge’s `vm.startBroadcast` / `vm.stopBroadcast` to send transactions
    /// @return NetworkConfig with `priceFeed` set to the mock’s address
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // If already set (e.g. reentrancy), skip redeploy
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        // Broadcast to local network to deploy the mock
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        return NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });
    }
}

