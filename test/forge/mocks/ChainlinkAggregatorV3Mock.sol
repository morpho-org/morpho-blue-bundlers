// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IChainlinkAggregatorV3} from "contracts/oracles/adapters/interfaces/IChainlinkAggregatorV3.sol";

contract ChainlinkAggregatorV3Mock is IChainlinkAggregatorV3 {
    string public description = "desciption";
    uint256 public version = 1;
    uint8 public decimals;
    int256 internal _answer;
    uint256 internal _startedAt;

    constructor(string memory newDescription) {
        description = newDescription;
    }

    function setDecimals(uint8 newDecimals) external {
        decimals = newDecimals;
    }

    function setAnswer(int256 newAnswer) external {
        _answer = newAnswer;
    }

    function setStartedAt(uint8 newStartedAt) external {
        _startedAt = newStartedAt;
    }

    function getRoundData(uint80)
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (uint80(block.number), _answer, _startedAt, _startedAt, uint80(block.number));
    }

    function latestRoundData()
        external
        view
        returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound)
    {
        return (uint80(block.number), _answer, _startedAt, _startedAt, uint80(block.number));
    }
}
