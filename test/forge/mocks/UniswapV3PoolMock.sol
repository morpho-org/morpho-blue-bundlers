// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {IUniswapV3Pool} from "@uniswap/v3-core/interfaces/IUniswapV3Pool.sol";

contract UniswapV3PoolMock is IUniswapV3Pool {
    address public factory;
    address public token0;
    address public token1;
    uint24 public fee;
    int24 public tickSpacing;
    uint128 public maxLiquidityPerTick;
    uint256 public feeGrowthGlobal0X128;
    uint256 public feeGrowthGlobal1X128;
    uint128 public liquidity;
    mapping(int16 => uint256) public tickBitmap;

    int56[] internal _tickCumulatives;

    constructor(address newToken0, address newToken1) {
        token0 = newToken0;
        token1 = newToken1;
    }

    function setTickCumulatives(int56[] memory newTickCumulatives) public {
        _tickCumulatives = newTickCumulatives;
    }

    function setTickCumulatives(int56 tickCumulatives0, int56 tickCumulatives1) external {
        int56[] memory newTickCumulatives = new int56[](2);
        newTickCumulatives[0] = tickCumulatives0;
        newTickCumulatives[1] = tickCumulatives1;
        _tickCumulatives = newTickCumulatives;
    }

    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s)
    {
        tickCumulatives = new int56[](secondsAgos.length);
        secondsPerLiquidityCumulativeX128s = new uint160[](secondsAgos.length);
        for (uint256 i = 0; i < secondsAgos.length; i++) {
            tickCumulatives[i] = _tickCumulatives[i];
        }
    }

    function slot0() external pure returns (uint160, int24, uint16, uint16, uint16, uint8, bool) {
        return (0, 0, 0, 0, 0, 0, false);
    }

    function protocolFees() external pure returns (uint128, uint128) {
        return (0, 0);
    }

    function ticks(int24) external pure returns (uint128, int128, uint256, uint256, int56, uint160, uint32, bool) {
        return (0, 0, 0, 0, 0, 0, 0, false);
    }

    function positions(bytes32) external pure returns (uint128, uint256, uint256, uint128, uint128) {
        return (0, 0, 0, 0, 0);
    }

    function observations(uint256) external pure returns (uint32, int56, uint160, bool) {
        return (0, 0, 0, false);
    }

    function snapshotCumulativesInside(int24, int24) external pure returns (int56, uint160, uint32) {
        return (0, 0, 0);
    }

    function initialize(uint160) external {}

    function mint(address, int24, int24, uint128, bytes calldata) external pure returns (uint256, uint256) {
        return (0, 0);
    }

    function collect(address, int24, int24, uint128, uint128) external pure returns (uint128, uint128) {
        return (0, 0);
    }

    function burn(int24, int24, uint128) external pure returns (uint256, uint256) {
        return (0, 0);
    }

    function swap(address, bool, int256, uint160, bytes calldata) external pure returns (int256, int256) {
        return (0, 0);
    }

    function flash(address, uint256, uint256, bytes calldata) external {}

    function increaseObservationCardinalityNext(uint16) external {}

    function setFeeProtocol(uint8, uint8) external {}

    function collectProtocol(address, uint128, uint128) external pure returns (uint128, uint128) {
        return (0, 0);
    }
}
