// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} 
    from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title  PriceConverter
/// @notice Library to fetch ETH/USD price and convert ETH amounts to USD using Chainlink
/// @dev    All functions are internal & view; using a library avoids deployment and allows inlining
library PriceConverter {
    /// @notice Retrieves the latest ETH/USD price from a Chainlink Aggregator
    /// @param priceFeed The Chainlink price feed contract interface
    /// @return price ETH/USD price scaled to 18 decimals
    function getPrice(AggregatorV3Interface priceFeed) 
        internal 
        view 
        returns (uint256 price) 
    {
        // latestRoundData returns: roundId, answer, startedAt, updatedAt, answeredInRound
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        // Chainlink's answer has 8 decimals; scale to 18 for uniformity
        return uint256(answer * 1e10);
    }

    /// @notice Converts a given ETH amount to its USD equivalent
    /// @param ethAmount Amount of ETH in wei
    /// @param priceFeed The Chainlink price feed contract interface
    /// @return ethAmountInUsd USD value of the ETH amount, scaled to 18 decimals
    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) 
        internal 
        view 
        returns (uint256 ethAmountInUsd) 
    {
        // Fetch ETH/USD price (18 decimals)
        uint256 ethPrice = getPrice(priceFeed);
        // Multiply by amount and normalize by 1e18 (wei factor)
        ethAmountInUsd = (ethPrice * ethAmount) / 1e18;
    }
}

