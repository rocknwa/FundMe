// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {DeployChainFund} from "../../script/DeployChainFund.s.sol";
import {ChainFund} from "../../src/ChainFund.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

/// @title  Unit Tests for ChainFund Contract
/// @notice Deploys ChainFund, validates funding logic and withdrawals in various scenarios
/// @dev    Uses Forge’s StdCheats for account control and Test for assertions
contract ChainFundTest is StdCheats, Test {
    ChainFund public chainFund;
    HelperConfig public helperConfig;

    uint256 public constant SEND_VALUE = 0.1 ether;
    uint256 public constant STARTING_USER_BALANCE = 10 ether;
    uint256 public constant GAS_PRICE = 1;
    address public constant USER = address(1);

    function setUp() external {
        DeployChainFund deployer = new DeployChainFund();
        (ChainFund deployedChainFund, HelperConfig config) = deployer.run();
        chainFund = deployedChainFund;
        helperConfig = config;

        vm.deal(USER, STARTING_USER_BALANCE);
    }

    function testPriceFeedSetCorrectly() public view {
        address retrievedPriceFeed = address(chainFund.getPriceFeed());
        address expectedPriceFeed = helperConfig.activeNetworkConfig();
        assertEq(retrievedPriceFeed, expectedPriceFeed, "Price feed mismatch");
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();
        chainFund.fund{value: 0}();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.startPrank(USER);
        chainFund.fund{value: SEND_VALUE}();
        vm.stopPrank();

        uint256 amountFunded = chainFund.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE, "Mapped funding amount incorrect");
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.startPrank(USER);
        chainFund.fund{value: SEND_VALUE}();
        vm.stopPrank();

        address funder = chainFund.getFunder(0);
        assertEq(funder, USER, "Funder not recorded in array");
    }

    modifier funded() {
        vm.prank(USER);
        chainFund.fund{value: SEND_VALUE}();
        assert(address(chainFund).balance > 0, "Funding failed in modifier");
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();
        chainFund.withdraw();
    }

    function testWithdrawFromASingleFunder() public funded {
        uint256 startingChainFundBalance = address(chainFund).balance;
        uint256 startingOwnerBalance = chainFund.getOwner().balance;

        vm.startPrank(chainFund.getOwner());
        chainFund.withdraw();
        vm.stopPrank();

        uint256 endingChainFundBalance = address(chainFund).balance;
        uint256 endingOwnerBalance = chainFund.getOwner().balance;
        assertEq(endingChainFundBalance, 0, "Contract balance should be zero");
        assertEq(
            startingChainFundBalance + startingOwnerBalance,
            endingOwnerBalance,
            "Owner did not receive correct amount"
        );
    }

    function testWithdrawFromMultipleFunders() public funded {
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 2;

        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            hoax(address(i), STARTING_USER_BALANCE);
            chainFund.fund{value: SEND_VALUE}();
        }

        uint256 startingChainFundBalance = address(chainFund).balance;
        uint256 startingOwnerBalance = chainFund.getOwner().balance;

        vm.startPrank(chainFund.getOwner());
        chainFund.withdraw();
        vm.stopPrank();

        assertEq(address(chainFund).balance, 0, "Contract not emptied after withdraw");
        assertEq(
            startingChainFundBalance + startingOwnerBalance,
            chainFund.getOwner().balance,
            "Owner balance incorrect after multi-withdraw"
        );
        assertEq(
            (numberOfFunders + 1) * SEND_VALUE,
            chainFund.getOwner().balance - startingOwnerBalance,
            "Incorrect total withdrawal amount"
        );
    }
}

