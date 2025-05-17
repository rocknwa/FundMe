// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {ChainFund} from "../src/ChainFund.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";

/// @title  Interaction Scripts for ChainFund
/// @notice Contains two scripts—one to fund and one to withdraw from the most recently deployed ChainFund contract
/// @dev    Uses Forge’s Script.sol for on-chain broadcasts and foundry-devops’ DevOpsTools to locate deployments
contract FundChainFund is Script {
    uint256 public constant SEND_VALUE = 0.1 ether;

    function fundChainFund(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        ChainFund(payable(mostRecentlyDeployed)).fund{value: SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded ChainFund with %s", SEND_VALUE);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("ChainFund", block.chainid);
        fundChainFund(mostRecentlyDeployed);
    }
}

contract WithdrawChainFund is Script {
    function withdrawChainFund(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        ChainFund(payable(mostRecentlyDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdrew ChainFund balance!");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("ChainFund", block.chainid);
        withdrawChainFund(mostRecentlyDeployed);
    }
}
