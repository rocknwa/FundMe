// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

/// @title  FundMe
/// @author Therock Ani
/// @notice This contract allows users to fund it in ETH, enforcing a minimum USD amount via Chainlink price feeds.
/// @dev    Utilizes a library for conversion rates, a custom error for owner checks, and optimal gas patterns.
error FundMe_NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    // ──────────────────────────────────────────────────
    // State Variables
    // ──────────────────────────────────────────────────

    /// @notice Minimum USD value (in wei) required to fund
    uint256 public constant MINIMUM_USD = 5 * 10**18;

    /// @notice Owner of the contract (set once, cheaper than mutable)
    address private immutable i_owner;

    /// @notice List of all funder addresses
    address[] private s_funders;

    /// @notice Mapping of address to amount funded
    mapping(address => uint256) private s_addressToAmountFunded;

    /// @notice Chainlink price feed interface for ETH/USD conversions
    AggregatorV3Interface private s_priceFeed;

    // ──────────────────────────────────────────────────
    // Modifiers
    // ──────────────────────────────────────────────────

    /// @notice Restricts function to owner only
    modifier onlyOwner() {
        if (msg.sender != i_owner) revert FundMe_NotOwner();
        _;
    }

    // ──────────────────────────────────────────────────
    // Constructor
    // ──────────────────────────────────────────────────

    /// @param priceFeed The address of the Chainlink ETH/USD price feed
    constructor(address priceFeed) {
        i_owner     = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    // ──────────────────────────────────────────────────
    // Receive / Fallback
    // ──────────────────────────────────────────────────

    /// @notice Fallback to accept ETH sent directly
    receive() external payable {
        fund();
    }
    fallback() external payable {
        fund();
    }

    // ──────────────────────────────────────────────────
    // External Functions
    // ──────────────────────────────────────────────────

    /// @notice Allows a user to send ETH meeting the minimum USD requirement
    /// @dev    Uses PriceConverter library to check conversion; reverts if below threshold
    function fund() public payable {
        // Convert msg.value to USD; require it meets the minimum
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "FundMe: insufficient ETH"
        );
        // Record funding amount and funder
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    /// @notice Withdraw all ETH from contract (only owner)
    /// @dev    Resets funder balances and empties funder list before transferring
    function withdraw() external onlyOwner {
        // Reset each funder's contributed amount
        for (uint256 idx = 0; idx < s_funders.length; idx++) {
            address funder = s_funders[idx];
            s_addressToAmountFunded[funder] = 0;
        }
        // Reset the funders array
        s_funders = new address;

        // Transfer full balance to owner
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success, "FundMe: withdraw failed");
    }

    /// @notice Optimized withdrawal variant that minimizes gas by caching array
    function cheaperWithdraw() external onlyOwner {
        address[] memory funders = s_funders;
        // Reset mapping balances
        for (uint256 idx = 0; idx < funders.length; idx++) {
            s_addressToAmountFunded[funders[idx]] = 0;
        }
        // Reset storage array
        s_funders = new address;

        // Transfer ETH
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success, "FundMe: withdraw failed");
    }

    // ──────────────────────────────────────────────────
    // Public / View Functions
    // ──────────────────────────────────────────────────

    /// @notice Gets the amount funded by a specific address
    /// @param fundingAddress The address to query
    /// @return The total ETH amount funded (in wei)
    function getAddressToAmountFunded(address fundingAddress)
        external
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[fundingAddress];
    }

    /// @notice Returns the version number of the Chainlink price feed
    function getVersion() external view returns (uint256) {
        return s_priceFeed.version();
    }

    /// @notice Retrieves a funder’s address by index
    /// @param index The funder list index (0-based)
    /// @return The address of the funder
    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    /// @notice Returns the contract owner
    function getOwner() external view returns (address) {
        return i_owner;
    }

    /// @notice Gets the Chainlink price feed interface
    function getPriceFeed() external view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}
