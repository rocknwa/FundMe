// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundMe} from "../../src/FundMe.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {StdCheats} from "forge-std/StdCheats.sol";

/// @title  Unit Tests for FundMe Contract
/// @notice Deploys FundMe, validates funding logic and withdrawals in various scenarios
/// @dev    Uses Forge’s StdCheats for account control and Test for assertions
contract FundMeTest is StdCheats, Test {
    /// @notice Instance of the FundMe contract under test
    FundMe public fundMe;

    /// @notice HelperConfig provides network-specific settings (e.g., price feed address)
    HelperConfig public helperConfig;

    /// @notice Amount of ETH (in wei) that test USER will send when funding
    uint256 public constant SEND_VALUE = 0.1 ether;

    /// @notice Starting ETH balance for the test USER to ensure they can fund
    uint256 public constant STARTING_USER_BALANCE = 10 ether;

    /// @notice Simulated gas price (only used if measuring gas costs)
    uint256 public constant GAS_PRICE = 1;

    /// @notice Address representing a generic external user in tests
    address public constant USER = address(1);

    /// @notice Setup runs before each test case
    /// @dev    Deploys FundMe via script and allocates ETH to USER
    function setUp() external {
        DeployFundMe deployer = new DeployFundMe();
        // Run the deployment script and capture FundMe + config
        (fundMe, helperConfig) = deployer.run();
        // Give USER a starting balance for funding
        vm.deal(USER, STARTING_USER_BALANCE);
    }

    /// @notice Verifies that the price feed address was set correctly on deployment
    function testPriceFeedSetCorrectly() public view {
        address retrievedPriceFeed = address(fundMe.getPriceFeed());
        // The helper config returns the expected price feed for this network
        address expectedPriceFeed = helperConfig.activeNetworkConfig();
        assertEq(retrievedPriceFeed, expectedPriceFeed, "Price feed mismatch");
    }

    /// @notice Ensures funding fails when sent ETH is below the minimum threshold
    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert();      // Expect a revert due to insufficient ETH
        fundMe.fund{value: 0}(); // Call fund() with zero ETH
    }

    /// @notice Confirms that the mapping is updated correctly after funding
    function testFundUpdatesFundedDataStructure() public {
        // Impersonate USER and send SEND_VALUE ETH
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        // The contract should record exactly SEND_VALUE for USER
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE, "Mapped funding amount incorrect");
    }

    /// @notice Validates that funders are tracked in the array after funding
    function testAddsFunderToArrayOfFunders() public {
        vm.startPrank(USER);
        fundMe.fund{value: SEND_VALUE}();
        vm.stopPrank();

        // The first entry in the funders array should be USER
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER, "Funder not recorded in array");
    }

    // Reusable modifier to ensure the contract is already funded
    modifier funded() {
        // USER sends the minimum
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        // Sanity check: contract balance must be > 0
        assert(address(fundMe).balance > 0, "Funding failed in modifier");
        _;
    }

    /// @notice Ensures only the owner can call withdraw()
    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert();      // Non-owner withdraw should revert
        fundMe.withdraw();
    }

    /// @notice Tests full withdrawal flow for a single funder
    function testWithdrawFromASingleFunder() public funded {
        // Arrange: record starting balances
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance  = fundMe.getOwner().balance;

        // Act: owner calls withdraw()
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert: contract is empty, owner's balance increased by the contract balance
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance  = fundMe.getOwner().balance;
        assertEq(endingFundMeBalance, 0, "Contract balance should be zero");
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance,
            "Owner did not receive correct amount"
        );
    }

    /// @notice Tests withdrawal logic with multiple distinct funders
    function testWithdrawFromMultipleFunders() public funded {
        // Arrange: have 10 different addresses fund the contract
        uint160 numberOfFunders      = 10;
        uint160 startingFunderIndex  = 2; // skip USER=1 and start at 2
        for (uint160 i = startingFunderIndex; i < numberOfFunders + startingFunderIndex; i++) {
            // hoax sets both the prank and the ETH balance in one call
            hoax(address(i), STARTING_USER_BALANCE);
            fundMe.fund{value: SEND_VALUE}();
        }

        // Recompute starting balances after all funders
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance  = fundMe.getOwner().balance;

        // Act: owner withdraws all
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert: FundMe contract is emptied
        assertEq(address(fundMe).balance, 0, "Contract not emptied after withdraw");
        // Assert: Owner’s balance increased by total funded amount
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            fundMe.getOwner().balance,
            "Owner balance incorrect after multi-withdraw"
        );
        // Assert: Owner received exactly (numberOfFunders + USER) * SEND_VALUE
        assertEq(
            (numberOfFunders + 1) * SEND_VALUE,
            fundMe.getOwner().balance - startingOwnerBalance,
            "Incorrect total withdrawal amount"
        );
    }
}

