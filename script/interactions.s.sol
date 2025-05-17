// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

/// @title  Interaction Scripts for FundMe
/// @notice Contains two scripts—one to fund and one to withdraw from the most recently deployed FundMe contract
/// @dev    Uses Forge’s Script.sol for on-chain broadcasts and foundry-devops’ DevOpsTools to locate deployments
contract FundFundMe is Script {
    /// @notice Amount of ETH to send when funding
    uint256 public constant SEND_VALUE = 0.1 ether;

    /// @notice Calls `fund()` on the most recent FundMe deployment with `SEND_VALUE` ETH
    /// @param mostRecentlyDeployed The address of the FundMe contract to fund
    function fundFundMe(address mostRecentlyDeployed) public {
        // Begin broadcasting transactions from the caller’s private key :contentReference[oaicite:0]{index=0}
        vm.startBroadcast(); :contentReference[oaicite:1]{index=1}

        // Invoke the fund() function, forwarding SEND_VALUE wei :contentReference[oaicite:2]{index=2}
        FundMe(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}(); 

        // Stop broadcasting; transactions have been queued/sent :contentReference[oaicite:3]{index=3}
        vm.stopBroadcast(); :contentReference[oaicite:4]{index=4}

        // Log to console for visibility (Hardhat-style logging) :contentReference[oaicite:5]{index=5}
        console.log("Funded FundMe with %s", SEND_VALUE);
    }

    /// @notice Entry point for `forge script`—automatically called if no signature is provided :contentReference[oaicite:6]{index=6}
    function run() external {
        // Look up the most recent on-chain deployment named "FundMe" on the active chain :contentReference[oaicite:7]{index=7}
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        // Perform the funding interaction :contentReference[oaicite:8]{index=8}
        fundFundMe(mostRecentlyDeployed);
    }
}

/// @title  Withdrawal Script for FundMe
/// @notice Withdraws all ETH from the most recently deployed FundMe contract as its owner
/// @dev    Follows the same pattern as the funding script but calls `withdraw()` instead
contract WithdrawFundMe is Script {
    /// @notice Calls `withdraw()` on the most recent FundMe deployment
    /// @param mostRecentlyDeployed The address of the FundMe contract to withdraw from
    function withdrawFundMe(address mostRecentlyDeployed) public {
        // Start broadcasting the withdrawal transaction :contentReference[oaicite:9]{index=9}
        vm.startBroadcast(); :contentReference[oaicite:10]{index=10}

        // Invoke the withdraw() function; requires msg.sender to be owner :contentReference[oaicite:11]{index=11}
        FundMe(payable(mostRecentlyDeployed)).withdraw();

        // Stop broadcasting :contentReference[oaicite:12]{index=12}
        vm.stopBroadcast(); :contentReference[oaicite:13]{index=13}

        // Log to console for confirmation :contentReference[oaicite:14]{index=14}
        console.log("Withdraw FundMe balance!");
    }

    /// @notice Entry point for `forge script` withdrawal :contentReference[oaicite:15]{index=15}
    function run() external {
        // Resolve the latest deployment address for "FundMe" :contentReference[oaicite:16]{index=16}
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);

        // Execute the withdrawal :contentReference[oaicite:17]{index=17}
        withdrawFundMe(mostRecentlyDeployed);
    }
}
