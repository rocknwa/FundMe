// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {AggregatorV3Interface}
    from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/// @title  MockV3Aggregator
/// @notice A simple mock of Chainlink’s AggregatorV3Interface for testing
/// @dev    Allows manual control of rounds, timestamps, and answers without relying on an external feed
contract MockV3Aggregator is AggregatorV3Interface {
    /// @notice The protocol version, matching AggregatorV3Interface
    uint256 public constant version = 4;

    /// @notice Number of decimals the aggregator uses (e.g., 8 for 1e8 scaling)
    uint8 public decimals;
    /// @notice Most recent answer value
    int256 public latestAnswer;
    /// @notice Timestamp of the most recent answer
    uint256 public latestTimestamp;
    /// @notice ID of the most recent round
    uint256 public latestRound;

    /// @notice Mapping from round ID to the answer for that round
    mapping(uint256 => int256) public getAnswer;
    /// @notice Mapping from round ID to the timestamp when it was updated
    mapping(uint256 => uint256) public getTimestamp;
    /// @notice Mapping from round ID to when it was started
    mapping(uint256 => uint256) private getStartedAt;

    /// @param _decimals      Number of decimals the feed should report
    /// @param _initialAnswer Initial answer to seed the mock aggregator
    constructor(uint8 _decimals, int256 _initialAnswer) {
        decimals = _decimals;
        // Initialize with the first answer
        updateAnswer(_initialAnswer);
    }

    /// @notice Updates the aggregator with a new answer and advances to the next round
    /// @param _answer The new answer value to record
    function updateAnswer(int256 _answer) public {
        latestAnswer    = _answer;
        latestTimestamp = block.timestamp;
        latestRound    += 1; // increment round
        getAnswer[latestRound]    = _answer;
        getTimestamp[latestRound] = block.timestamp;
        getStartedAt[latestRound] = block.timestamp;
    }

    /// @notice Allows manual setting of all round data fields
    /// @param _roundId    The round ID to set
    /// @param _answer     The answer value for the round
    /// @param _timestamp  The timestamp when the answer was updated
    /// @param _startedAt  The timestamp when the round started
    function updateRoundData(
        uint80 _roundId,
        int256 _answer,
        uint256 _timestamp,
        uint256 _startedAt
    ) public {
        latestRound       = _roundId;
        latestAnswer      = _answer;
        latestTimestamp   = _timestamp;
        getAnswer[_roundId]    = _answer;
        getTimestamp[_roundId] = _timestamp;
        getStartedAt[_roundId] = _startedAt;
    }

    /// @inheritdoc AggregatorV3Interface
    /// @param _roundId The round ID to query
    function getRoundData(uint80 _roundId)
        external
        view
        override
        returns (
            uint80  roundId,
            int256  answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80  answeredInRound
        )
    {
        return (
            _roundId,
            getAnswer[_roundId],
            getStartedAt[_roundId],
            getTimestamp[_roundId],
            _roundId
        );
    }

    /// @inheritdoc AggregatorV3Interface
    function latestRoundData()
        external
        view
        override
        returns (
            uint80  roundId,
            int256  answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80  answeredInRound
        )
    {
        roundId           = uint80(latestRound);
        answer            = getAnswer[latestRound];
        startedAt         = getStartedAt[latestRound];
        updatedAt         = getTimestamp[latestRound];
        answeredInRound   = uint80(latestRound);
    }

    /// @inheritdoc AggregatorV3Interface
    function description() external pure override returns (string memory) {
        return "v0.6/test/mock/MockV3Aggregator.sol";
    }
}

