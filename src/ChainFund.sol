// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

/// @title  ChainFund
/// @author Therock Ani
/// @notice This contract allows users to fund it in ETH, enforcing a minimum USD amount via Chainlink price feeds.
/// @dev    Utilizes a library for conversion rates, a custom error for owner checks, and optimal gas patterns.
error ChainFund_NotOwner();

contract ChainFund {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5 * 10**18;

    address private immutable i_owner;
    address[] private s_funders;
    mapping(address => uint256) private s_addressToAmountFunded;
    AggregatorV3Interface private s_priceFeed;

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert ChainFund_NotOwner();
        _;
    }

    constructor(address priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "ChainFund: insufficient ETH"
        );
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function withdraw() external onlyOwner {
        for (uint256 idx = 0; idx < s_funders.length; idx++) {
            s_addressToAmountFunded[s_funders[idx]] = 0;
        }
        s_funders = new address ;

        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success, "ChainFund: withdraw failed");
    }

    function cheaperWithdraw() external onlyOwner {
        address[] memory funders = s_funders;
        for (uint256 idx = 0; idx < funders.length; idx++) {
            s_addressToAmountFunded[funders[idx]] = 0;
        }
        s_funders = new address ;

        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success, "ChainFund: withdraw failed");
    }

    function getAddressToAmountFunded(address fundingAddress)
        external
        view
        returns (uint256)
    {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getVersion() external view returns (uint256) {
        return s_priceFeed.version();
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getPriceFeed() external view returns (AggregatorV3Interface) {
        return s_priceFeed;
    }
}

