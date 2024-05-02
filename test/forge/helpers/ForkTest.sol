// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.0;

import "./BaseTest.sol";
import "../ethereum/helpers/Configs.sol";

abstract contract ForkTest is BaseTest {
    using SafeTransferLib for ERC20;

    MarketParams[] allMarketParams;

    Config internal config;
    address[] internal allAssets;
    address internal DAI;
    address internal USDC;
    address internal USDT;
    address internal LINK;
    address internal WBTC;
    address internal WETH;
    address internal ST_ETH;
    address internal WST_ETH;
    address internal CB_ETH;
    address internal R_ETH;
    address internal S_DAI;
    address internal AAVE_V2_POOL;
    address internal AAVE_V3_POOL;
    address internal AAVE_V3_OPTIMIZER;
    address internal COMPTROLLER;
    address internal C_DAI_V2;
    address internal C_ETH_V2;
    address internal C_USDC_V2;
    address internal C_WETH_V3;

    // Setup.

    function setUp() public virtual override {
        Configs configs = new Configs();
        config = configs.getConfig(block.chainid);

        _setVariables();
        _fork();

        super.setUp();

        MarketParams memory configMarket = config.market;
        MarketParams memory marketParams = MarketParams({
            collateralToken: configMarket.collateralToken,
            loanToken: configMarket.loanToken,
            oracle: address(oracle),
            irm: address(irm),
            lltv: configMarket.lltv
        });

        vm.startPrank(OWNER);
        if (!morpho.isLltvEnabled(marketParams.lltv)) morpho.enableLltv(marketParams.lltv);
        morpho.createMarket(marketParams);
        vm.stopPrank();

        allMarketParams.push(marketParams);
    }

    function _setVariables() internal {
        DAI = config.DAI;
        USDC = config.USDC;
        USDT = config.USDT;
        LINK = config.LINK;
        WBTC = config.WBTC;
        WETH = config.WETH;
        ST_ETH = config.ST_ETH;
        WST_ETH = config.WST_ETH;
        CB_ETH = config.CB_ETH;
        R_ETH = config.R_ETH;
        S_DAI = config.S_DAI;
        COMPTROLLER = config.COMPTROLLER;
        AAVE_V2_POOL = config.AAVE_V2_POOL;
        AAVE_V3_POOL = config.AAVE_V3_POOL;
        AAVE_V3_OPTIMIZER = config.AAVE_V3_OPTIMIZER;
        C_DAI_V2 = config.C_DAI_V2;
        C_ETH_V2 = config.C_ETH_V2;
        C_USDC_V2 = config.C_USDC_V2;
        C_WETH_V3 = config.C_WETH_V3;
    }

    function _fork() internal {
        vm.createSelectFork(getChain(block.chainid).rpcUrl, config.forkBlockNumber);
    }

    // Modifiers.

    // For tests that must be run only on Ethereum.
    modifier onlyEthereum() {
        vm.skip(block.chainid != 1);
        _;
    }

    // Utils.

    function deal(address asset, address recipient, uint256 amount) internal virtual override {
        if (asset == WETH) super.deal(WETH, WETH.balance + amount); // Refill WETH in ETH.

        if (asset == ST_ETH) {
            if (amount == 0) return;

            deal(recipient, amount);

            vm.prank(recipient);
            uint256 stEthAmount = IStEth(ST_ETH).submit{value: amount}(address(0));

            vm.assume(stEthAmount != 0);

            return;
        }

        return super.deal(asset, recipient, amount);
    }

    function _randomMarketParams(uint256 seed) internal view returns (MarketParams memory) {
        return allMarketParams[seed % allMarketParams.length];
    }
}
