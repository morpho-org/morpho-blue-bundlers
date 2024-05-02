// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.0;

import "../../../../lib/morpho-blue/src/interfaces/IMorpho.sol";

struct Config {
    uint256 chainId;
    uint256 forkBlockNumber;
    MarketParams market;
    address DAI;
    address USDC;
    address USDT;
    address LINK;
    address WBTC;
    address WETH;
    address ST_ETH;
    address WST_ETH;
    address CB_ETH;
    address R_ETH;
    address S_DAI;
    address AAVE_V2_POOL;
    address AAVE_V3_POOL;
    address AAVE_V3_OPTIMIZER;
    address COMPTROLLER;
    address C_DAI_V2;
    address C_ETH_V2;
    address C_USDC_V2;
    address C_WETH_V3;
}

contract Configs {
    Config public ethereumConfig = Config({
        chainId: 1,
        forkBlockNumber: 18_500_000,
        market: MarketParams({
            loanToken: 0x6B175474E89094C44Da98b954EedeAC495271d0F,
            collateralToken: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
            lltv: 800000000000000000,
            oracle: 0x0000000000000000000000000000000000000000,
            irm: 0x0000000000000000000000000000000000000000
        }),
        DAI: 0x6B175474E89094C44Da98b954EedeAC495271d0F,
        USDC: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
        USDT: 0xdAC17F958D2ee523a2206206994597C13D831ec7,
        LINK: 0x514910771AF9Ca656af840dff83E8264EcF986CA,
        WBTC: 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599,
        WETH: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
        ST_ETH: 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84,
        WST_ETH: 0x7f39C581F595B53c5cb19bD0b3f8dA6c935E2Ca0,
        CB_ETH: 0xBe9895146f7AF43049ca1c1AE358B0541Ea49704,
        R_ETH: 0xae78736Cd615f374D3085123A210448E74Fc6393,
        S_DAI: 0x83F20F44975D03b1b09e64809B757c47f942BEeA,
        AAVE_V2_POOL: 0x7d2768dE32b0b80b7a3454c06BdAc94A69DDc7A9,
        AAVE_V3_POOL: 0x87870Bca3F3fD6335C3F4ce8392D69350B4fA4E2,
        AAVE_V3_OPTIMIZER: 0x33333aea097c193e66081E930c33020272b33333,
        COMPTROLLER: 0x3d9819210A31b4961b30EF54bE2aeD79B9c9Cd3B,
        C_DAI_V2: 0x5d3a536E4D6DbD6114cc1Ead35777bAB948E3643,
        C_ETH_V2: 0x4Ddc2D193948926D02f9B1fE9e1daa0718270ED5,
        C_USDC_V2: 0x39AA39c021dfbaE8faC545936693aC917d5E7563,
        C_WETH_V3: 0xA17581A9E3356d9A858b789D68B4d866e593aE94
    });

    function getConfig(uint256 chainId) public view returns (Config memory) {
        if (chainId == 1) {
            return ethereumConfig;
        } else {
            revert("no config for this chain");
        }
    }
}
