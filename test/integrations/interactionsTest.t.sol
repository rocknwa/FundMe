// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/interactions.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

/// @title  End-to-End Interaction Tests for FundMe
/// @notice Deploys the FundMe contract, performs on-chain fund and withdraw interactions,
///         and asserts final balances to ensure scripts work as expected.
/// @dev    Uses Forge’s StdCheats for chain manipulation and Test for assertions.
contract InteractionsTest is StdCheats, Test {
    /// @notice Instance of the deployed FundMe contract
    FundMe public fundMe;

    /// @notice Configuration helper, contains network-specific addresses
    HelperConfig public helperConfig;

    /// @notice Amount of ETH each test user will send when funding
    uint256 public constant SEND_VALUE = 0.1 ether;

    /// @notice Starting ETH balance for the test user
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    /// @notice Simulated gas price (for gas cost assertions, if needed)
    uint256 public constant GAS_PRICE = 1;

    /// @notice Address used to represent an arbitrary external user
    address public constant USER = address(1);

    /// @notice Sets up a fresh deployment before each test
    /// @dev    DeployFundMe script returns both the contract and its configuration
    function setUp() external {
        // Deploy the FundMe contract via script
        DeployFundMe deployer = new DeployFundMe();
        (fundMe, helperConfig) = deployer.run();

        // Give our USER enough ETH to perform funding interactions
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    /// @notice Tests that a user can fund and then the owner can successfully withdraw
    /// @dev    Runs both FundFundMe and WithdrawFundMe scripts in sequence,
    ///         then asserts the contract balance is zero.
    function testUserCanFundAndOwnerWithdraw() public {
        // 1) Instantiate and run the funding interaction script as USER
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        // 2) Instantiate and run the withdrawal interaction script as contract owner
        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));

        // 3) Assert that all ETH has been withdrawn and contract balance is zero
        assertEq(address(fundMe).balance, 0, "Contract balance should be zero after owner withdrawal");
    }
}

