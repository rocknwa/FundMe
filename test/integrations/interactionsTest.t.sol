// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {DeployChainFund} from "../../script/DeployChainFund.s.sol";
import {FundChainFund, WithdrawChainFund} from "../../script/interactions.s.sol";
import {ChainFund} from "../../src/ChainFund.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

/// @title  End-to-End Interaction Tests for ChainFund
/// @notice Deploys the ChainFund contract, performs on-chain fund and withdraw interactions,
///         and asserts final balances to ensure scripts work as expected.
/// @dev    Uses Forge’s StdCheats for chain manipulation and Test for assertions.
contract InteractionsTest is StdCheats, Test {
    ChainFund public chainFund;
    HelperConfig public helperConfig;

    uint256 public constant SEND_VALUE = 0.1 ether;
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant GAS_PRICE = 1;
    address public constant USER = address(1);

    function setUp() external {
        DeployChainFund deployer = new DeployChainFund();
        (chainFund, helperConfig) = deployer.run();

        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testUserCanFundAndOwnerWithdraw() public {
        FundChainFund fundChainFund = new FundChainFund();
        fundChainFund.fundChainFund(address(chainFund));

        WithdrawChainFund withdrawChainFund = new WithdrawChainFund();
        withdrawChainFund.withdrawChainFund(address(chainFund));

        assertEq(address(chainFund).balance, 0, "Contract balance should be zero after owner withdrawal");
    }
}

